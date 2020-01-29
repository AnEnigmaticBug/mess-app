import 'dart:convert';

import 'package:messapp/profile/profile.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  ProfileRepository({
    @required SharedPreferences preferences,
    @required NiceClient client,
  })  : this._sPrefs = preferences,
        this._client = client;

  final SharedPreferences _sPrefs;
  final NiceClient _client;

  Future<Profile> get profile async {
    return Profile(
      name: await _sPrefs.get(PrefKeys.userName) ?? 'Error getting Name',
      bitsId: await _sPrefs.get(PrefKeys.bitsId) ?? 'Error getting ID',
      room: await _sPrefs.get(PrefKeys.userRoom) ?? 'Error getting room',
      qrCode: await _sPrefs.get(PrefKeys.qrCode) ?? 'Error',
    );
  }

  Future<void> refreshQr() async {
    final response = await _client.get('/refresh/qr');

    if (response.statusCode != 200) {
      return response.toException();
    }

    final qrJson = json.decode(response.body);
    await _sPrefs.setString(PrefKeys.qrCode, qrJson['QR']);
  }

  Future<void> logout() async {
    await _sPrefs.clear();
  }
}
