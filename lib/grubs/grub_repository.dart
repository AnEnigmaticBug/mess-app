import 'dart:convert';

import 'package:messapp/grubs/grub_details.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/simple_repository.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:sqflite/sqflite.dart';

class GrubRepository extends SimpleRepository {
  GrubRepository({
    @required Database database,
    @required NiceClient client,
  })  : this._db = database,
        this._client = client;

  final Database _db;
  final NiceClient _client;
  List<GrubListing> _cache = [];

  Future<List<GrubListing>> get grubListings async {
    if (_cache.isNotEmpty) {
      return _cache;
    }

    await _populateCache();
    return _cache;
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
            INTO Grub (id, name, organizer, date, signUpDeadline, cancelDeadline, slotATime, slotBTime, audience)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
          grubJson['id'],
          grubJson['name'],
          grubJson['assoc'],
          grubJson['date'],
          grubJson['purchase_deadline'],
          grubJson['cancellation_deadline'],
          grubJson['slot_a'],
          grubJson['slot_b'],
          audience.index,
        ]);

        for (var offeringJson in offeringsJson) {
          await txn.rawInsert('''
            INSERT
              INTO Offering (id, grubId, name, items, venue, price)
            VALUES (?, ?, ?, ?, ?, ?)
          ''', [
            offeringJson['id'],
            grubJson['id'],
            offeringJson['category'],
            offeringJson['items'].map((i) => i['name']).join('~'),
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
