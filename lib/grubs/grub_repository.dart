import 'dart:convert';

import 'package:messapp/grubs/grub_details.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:messapp/util/time_keeper.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';

class GrubRepository extends SimpleRepository {
  GrubRepository({
    @required Database database,
    @required NiceClient client,
    @required TimeKeeper keeper,
  })  : this._db = database,
        this._client = client,
        this._keeper = keeper;

  final Database _db;
  final NiceClient _client;
  final TimeKeeper _keeper;
  List<GrubListing> _cache = [];

  Future<List<GrubListing>> get grubListings async {
    if (_cache.isEmpty) {
      await _populateCache();
    }

    if (_cache.isEmpty || await _keeper.isDue(PrefKeys.grubsRefresh)) {
      await refresh();
    }

    return _cache;
  }

  Future<GrubDetails> grubDetails({
    @required int grubId,
  }) async {
    return await _db.transaction((txn) async {
      final grubRow = (await txn.rawQuery('''
        SELECT id, name, organizer, date, signUpDeadline, cancelDeadline, audience
          FROM Grub
         WHERE id == ?
      ''', [grubId]))[0];

      final offeringRows = await txn.rawQuery('''
        SELECT o.id AS oid, o.name, o.items, o.slotATime, o.slotBTime, o.venue, o.price, t.id AS tid, t.slot
          FROM Offering o
               LEFT JOIN Ticket t ON o.id == t.offeringId
         WHERE o.grubId == ?
      ''', [grubId]);

      final offerings = offeringRows
          .map((r) => Offering(
                id: r['oid'],
                name: r['name'],
                items: r['items'].split('~'),
                price: r['price'],
              ))
          .toList();

      final signedOfferingRow =
          offeringRows.firstWhere((r) => r['tid'] != null, orElse: () => null);

      final isSigned = signedOfferingRow != null;

      if (isSigned) {
        return SignedUpGrubDetails(
          id: grubRow['id'],
          name: grubRow['name'],
          organizer: grubRow['organizer'],
          date: Date.parse(grubRow['date']),
          cancelDeadline: Date.parse(grubRow['cancelDeadline']),
          time: signedOfferingRow['slot'] == 0
              ? signedOfferingRow['slotATime']
              : signedOfferingRow['slotBTime'],
          venue: signedOfferingRow['venue'],
          offerings: offerings,
          signedOfferingName: signedOfferingRow['name'],
        );
      } else {
        return UnsignedGrubDetails(
          id: grubRow['id'],
          name: grubRow['name'],
          organizer: grubRow['organizer'],
          date: Date.parse(grubRow['date']),
          signUpDeadline: Date.parse(grubRow['signUpDeadline']),
          audience: Audience.values[grubRow['audience']],
          offerings: offerings,
        );
      }
    });
  }

  Future<void> signUp({
    @required int offeringId,
  }) async {
    final reqBody = json.encode({
      'ids': [offeringId],
    });
    final res = await _client.post('/grubs/user/view/', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }

    await refresh();
  }

  Future<void> cancel({
    @required int grubId,
  }) async {
    final row = (await _db.rawQuery('''
      SELECT t.id AS tid
        FROM Grub g
             INNER JOIN Offering o ON g.id == o.grubId
             INNER JOIN Ticket t ON o.id == t.offeringId
       WHERE g.id == ?
    ''', [grubId]))[0];

    final reqBody = json.encode({
      'id': row['tid'],
    });
    final res = await _client.post('/grubs/user/cancel/', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }

    await refresh();
  }

  Future<void> refresh() async {
    final res1 = await _client.get('/grubs/view');

    if (res1.statusCode != 200) {
      throw res1.toException();
    }

    final grubsJson = json.decode(res1.body) as List<dynamic>;

    final res2 = await _client.get('/grubs/user/view');

    if (res2.statusCode != 200) {
      throw res2.toException();
    }

    final ticketsJson = json.decode(res2.body) as List<dynamic>;

    await _db.transaction((txn) async {
      await txn.rawDelete('''
        DELETE
          FROM Grub
      ''');

      await txn.rawDelete('''
        DELETE
          FROM Offering
      ''');

      await txn.rawDelete('''
        DELETE
          FROM Ticket
      ''');

      for (var grubJson in grubsJson) {
        final offeringsJson = grubJson['menues'];

        var forHerbivores = false;
        var forCarnivores = false;

        for (var offeringJson in offeringsJson) {
          if (offeringJson['category'] == 'Veg') {
            forHerbivores = true;
          }
          if (offeringJson['category'] == 'Non-veg') {
            forCarnivores = true;
          }
        }

        Audience audience;

        if (forHerbivores && forCarnivores) {
          audience = Audience.Omnivorous;
        } else if (forHerbivores) {
          audience = Audience.Herbivorous;
        } else if (forCarnivores) {
          audience = Audience.Carnivorous;
        } else {
          continue;
        }

        await txn.rawInsert('''
          INSERT
            INTO Grub (id, name, organizer, date, signUpDeadline, cancelDeadline, audience)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', [
          grubJson['id'],
          grubJson['name'],
          grubJson['assoc'],
          grubJson['date'],
          grubJson['purchase_deadline'],
          grubJson['cancellation_deadline'],
          audience.index,
        ]);

        for (var offeringJson in offeringsJson) {
          await txn.rawInsert('''
            INSERT
              INTO Offering (id, grubId, name, items, slotATime, slotBTime, venue, price)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''', [
            offeringJson['id'],
            grubJson['id'],
            offeringJson['category'],
            offeringJson['items'].map((i) => i['name']).join('~'),
            offeringJson['batch_allocated'] ? offeringJson['slot_a'] : 'TBA',
            offeringJson['batch_allocated'] ? offeringJson['slot_b'] : 'TBA',
            offeringJson['mess_name'],
            offeringJson['app_price'],
          ]);
        }
      }

      for (var ticketJson in ticketsJson) {
        await txn.rawInsert('''
          INSERT
            INTO Ticket (id, offeringId, slot)
          VALUES (?, ?, ?)
        ''', [
          ticketJson['id'],
          ticketJson['grub'],
          ticketJson['slot'] == 'A' ? 0 : 1,
        ]);
      }
    });

    await _keeper.reset(PrefKeys.grubsRefresh);

    await _populateCache();
  }

  Future<void> _populateCache() async {
    _cache.clear();

    await _db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT id, name, organizer, date, signUpDeadline, cancelDeadline, audience
          FROM Grub g
      ''');

      final signedGrubIds = (await txn.rawQuery('''
        SELECT o.grubId
          FROM Offering o
               INNER JOIN Ticket t ON o.id == t.offeringId
      ''')).map((r) => r['grubId']).toList();

      for (var row in rows) {
        _cache.add(GrubListing(
          id: row['id'],
          name: row['name'],
          organizer: row['organizer'],
          date: Date.parse(row['date']),
          signUpDeadline: Date.parse(row['signUpDeadline']),
          cancelDeadline: Date.parse(row['cancelDeadline']),
          audience: Audience.values[row['audience']],
          isSigned: signedGrubIds.contains(row['id']),
        ));
      }
    });
  }
}
