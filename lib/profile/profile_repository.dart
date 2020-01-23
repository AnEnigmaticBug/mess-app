import 'package:flutter/cupertino.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {

  ProfileRepository({
    @required SharedPreferences preferences
  }): this._sharedPreferences = preferences;

  final SharedPreferences _sharedPreferences;

  Future<Profile> get profileInfo async {
    return Profile(
        name: await _sharedPreferences.get(PrefKeys.userName) ?? "Error getting Name",
        bitsId: await _sharedPreferences.get(PrefKeys.bitsId) ?? "Error getting ID",
        room: await _sharedPreferences.get(PrefKeys.userRoom) ?? "Error getting room",
        qrCode: await _sharedPreferences.get(PrefKeys.qrCode) ?? "Error"
    );
  }

  Future<void> refresh() {
    return null;
  }

  Future<void> logout() {
    return null;
  }

}