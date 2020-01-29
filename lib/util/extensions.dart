import 'package:flutter/material.dart';

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
