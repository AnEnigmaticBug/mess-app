import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:messapp/profile/profile.dart';
import 'package:messapp/profile/profile_presenter.dart';
import 'package:messapp/profile/profile_repository.dart';
import 'package:messapp/util/app_colors.dart';
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
        child: Consumer<ProfilePresenter>(
            // ignore: missing_return
            builder: (_, presenter, __){
              final state = presenter.state;
              presenter.getProfile();

              if(state is Loading){
                return Center(child: CircularProgressIndicator());
              }

              if(state is Success){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          margin: EdgeInsets.all(16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  AppColors.profileGradient1,
                                  AppColors.profileGradient2
                                ],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          child: Row(
                            children: <Widget>[
                              Text("Name"),
                              Text(((state as Success).data as Profile).name),
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text("BITS ID"),
                                      Text(((state as Success).data as Profile).bitsId)
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text("Hostel Room"),
                                      Text(((state as Success).data as Profile).room)
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Container(
                          margin: EdgeInsets.all(32.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.bottomNavBackground,
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          child: Row(
                            children: <Widget>[
                              RaisedButton(
                                onPressed: () async {
                                  await presenter.refreshQr();
                                },
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        RaisedButton(
                          onPressed: () async {
                            await presenter.logout();
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        )
                      ],
                    ),
                  ],
                );
              }

              if(state is Failure){
                return ErrorMessage(
                    message: (state as Failure).message,
                    onRetry: presenter.restart);
              }
            }
        ),
    );
  }
}