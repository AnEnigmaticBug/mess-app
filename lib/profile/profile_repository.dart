import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:nice/nice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:messapp/util/http_exceptions.dart';

class ProfileRepository {

  ProfileRepository({
    @required NiceClient client,
    @required SharedPreferences preferences
  }): this._sharedPreferences = preferences,
      this._niceClient = client;

  final SharedPreferences _sharedPreferences;
  final NiceClient _niceClient;

  Future<Profile> get profileInfo async {
    return Profile(
        name: await _sharedPreferences.get(PrefKeys.userName) ?? 'Error getting Name',
        bitsId: await _sharedPreferences.get(PrefKeys.bitsId) ?? 'Error getting ID',
        room: await _sharedPreferences.get(PrefKeys.userRoom) ?? 'Error getting room',
        qrCode: await _sharedPreferences.get(PrefKeys.qrCode) ?? 'Error'
    );
  }

  Future<void> refreshQr() async {
    final response = await _niceClient.get('/refresh/qr');

    if(response.statusCode != 200){
      return response.toException();
    }

    final qrJson = json.decode(response.body);
    await _sharedPreferences.setString(PrefKeys.qrCode, qrJson['QR']);

  }

  Future<void> logout() async {
    await _sharedPreferences.clear();
  }

}