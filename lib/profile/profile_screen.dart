import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_presenter.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Screen(
        title: "Profile",
        selectedTabIndex: 0,
        child: _Profile(),
    );
  }
}

class _Profile extends StatefulWidget{
  const _Profile({
    Key key
  }): super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<_Profile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfilePresenter>(
        // ignore: missing_return
        builder: (_, presenter, __){
          final state = presenter.state;

          if(state is Loading){
            return Center(child: CircularProgressIndicator());
          }

          if(state is Success){
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 8.0,
                ),
                Container(

                ),
                SizedBox(
                  height: 8.0,
                ),
                Container(

                ),
                Spacer(),
                RaisedButton(
                  onPressed: () async {
                  },
                ),
                SizedBox(
                  height: 10.0,
                )
              ],
            );
          }

          if(state is Failure){
            return ErrorMessage(
                message: state.message,
                onRetry: presenter.restart);
          }
        }
    );
  }
}