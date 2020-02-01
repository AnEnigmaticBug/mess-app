import 'package:flutter/material.dart';
import 'package:messapp/login/login_repository.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          colors: [
            Color(0xFFF49B65),
            Color(0xFFD9492D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x6EDD5435),
              offset: Offset(3.0, 8.0),
              blurRadius: 10.0),
        ],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _Content(),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    Key key,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Spacer(flex: 2),
          Text(
            'SSMS',
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'Official',
            style: TextStyle(
              fontSize: 29.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Spacer(flex: 3),
          Button(
            label: 'Login using BITS Mail',
            onPressed: () async {
              final repo = Provider.of<LoginRepository>(context);
              try {
                final idToken = await repo.signInWithGoogle();
                setState(() {
                  _isLoading = true;
                });
                await repo.login(idToken);
                Navigator.of(context).pushReplacementNamed('/onboarding');
              } on Exception catch (e) {
                e.prettify().showSnackBar(context);
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          SizedBox(height: 48.0),
        ],
      ),
    );
  }
}
