import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsKeys {
  UserPrefsKeys._();

  static const jwt = 'USER_JWT';
  static const id = 'USER_ID';
  static const name = 'USER_NAME';
  static const room = 'USER_ROOM';
  static const bitsId = 'USER_BITS_ID';
  static const qrCode = 'USER_QR_CODE';
}

class LoginRepository {
  LoginRepository({
    @required SharedPreferences preferences,
    @required NiceClient client,
  })  : this._sPrefs = preferences,
        this._client = client;

  final SharedPreferences _sPrefs;
  final NiceClient _client;
  final _signIn = GoogleSignIn(
    scopes: ['email'],
    hostedDomain: 'pilani.bits-pilani.ac.in',
  );

  Future<String> signInWithGoogle() async {
    await _signIn.signOut();
    final account = await _signIn.signIn();
    return (await account.authentication).idToken;
  }

  Future<void> login(String idToken) async {
    final reqBody = json.encode({'id_token': idToken});
    final res = await _client.post('/login', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }

    final userJson = json.decode(res.body);

    await _sPrefs.setString(UserPrefsKeys.jwt, userJson['JWT']);
    await _sPrefs.setInt(UserPrefsKeys.id, userJson['id']);
    await _sPrefs.setString(UserPrefsKeys.name, userJson['name']);
    await _sPrefs.setString(UserPrefsKeys.room, userJson['room']);
    await _sPrefs.setString(UserPrefsKeys.bitsId, userJson['bits_id']);
    await _sPrefs.setString(UserPrefsKeys.qrCode, userJson['qr_code']);
  }
}
