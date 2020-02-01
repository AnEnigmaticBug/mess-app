import 'dart:io';

import 'package:flutter/material.dart';
import 'package:messapp/util/http_exceptions.dart';
import 'package:sqflite/sqflite.dart';

extension SnackBarDisplay on String {
  void showSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        this,
        style: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w500),
      ),
    ));
  }
}

extension FormatException on Exception {
  String prettify() {
    final e = this;

    if (e is SocketException && e.osError.errorCode == 7) {
      if (e.osError.errorCode == 7) {
        return 'You are not connected to internet';
      }
      return e.message ?? 'Could not connect to the server';
    }
    if (e is Http5xxException) {
      return 'Server error, please contact the tech team';
    }
    if (e is Http4xxException) {
      if (e.statusCode == 401) {
        return 'Please logout and then login again';
      }

      return e.message ?? 'Something went wrong: (${e.statusCode})';
    }
    if (e is DatabaseException) {
      return 'Please clear your app data or re-install the app';
    }

    return e.toString();
  }
}
