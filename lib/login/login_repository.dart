import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:messapp/util/pref_keys.dart';
import 'package:meta/meta.dart';
import 'package:nice/nice.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepository {
  LoginRepository({
    @required SharedPreferences preferences,
    @required NiceClient client,
    @required FirebaseMessaging messaging,
  })  : this._sPrefs = preferences,
        this._client = client,
        this._messaging = messaging;

  final SharedPreferences _sPrefs;
  final NiceClient _client;
  final FirebaseMessaging _messaging;
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
    await _messaging.subscribeToTopic('notices');

    final reqBody = json.encode({
      'id_token': idToken,
      'reg_token': await _messaging.getToken(),
    });
    final res = await _client.post('/login', body: reqBody);

    if (res.statusCode != 200) {
      throw res.toException();
    }

    final userJson = json.decode(res.body);

    await _sPrefs.setString(PrefKeys.jwt, userJson['JWT']);
    await _sPrefs.setInt(PrefKeys.userId, userJson['id']);
    await _sPrefs.setString(PrefKeys.userName, userJson['name']);
    await _sPrefs.setString(PrefKeys.userRoom, userJson['room']);
    await _sPrefs.setString(PrefKeys.bitsId, userJson['bits_id']);
    await _sPrefs.setString(PrefKeys.qrCode, userJson['qr_code']);

    _client.headers.addAll({'Authorization': userJson['JWT']});
  }
}
