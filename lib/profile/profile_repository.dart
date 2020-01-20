import 'package:flutter/cupertino.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {

  ProfileRepository({
    @required SharedPreferences preferences
  }): this._sharedPreferences = preferences;

  final SharedPreferences _sharedPreferences;
  Profile _cache = Profile(name: null, bitsId: null, room: null, qrCode: null);

  Future<Profile> get profileInfo async {

//    if(_cache.name != null){
//      return _cache;
//    }
//
//    _cache = await getCache();
//    return _cache;

    return Profile(
        name: await _sharedPreferences.get(PrefKeys.userName) ?? "Error getting Name",
        bitsId: await _sharedPreferences.get(PrefKeys.bitsId) ?? "Error getting ID",
        room: await _sharedPreferences.get(PrefKeys.userRoom) ?? "Error getting room",
        qrCode: await _sharedPreferences.get(PrefKeys.qrCode) ?? "Error"
    );

  }

//  Future<Profile> getCache() async {
//    return Profile(
//        name: await _sharedPreferences.get(PrefKeys.userName) ?? "Error getting Name",
//        bitsId: await _sharedPreferences.get(PrefKeys.bitsId) ?? "Error getting ID",
//        room: await _sharedPreferences.get(PrefKeys.userRoom) ?? "Error getting room",
//        qrCode: await _sharedPreferences.get(PrefKeys.qrCode) ?? "Error"
//    );
//  }

  Future<void> refresh() {
    // TODO: implement refresh
    return null;
  }

  Future<void> logout() {
    return null;
  }

}