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
import 'package:qr_flutter/qr_flutter.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Profile',
      selectedTabIndex: 0,
      child: Consumer<ProfilePresenter>(
          // ignore: missing_return
          builder: (_, presenter, __) {
        final state = presenter.state;

        if (state is Loading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is Success) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(children: [
              Column(
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            AppColors.profileGradient1,
                            AppColors.profileGradient2
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x6EDD5435),
                            offset: Offset(3.0, 8.0),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Field(
                          name: 'Name',
                          value: ((state as Success).data as Profile).name,
                          fontWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            _Field(
                                name: 'BITS ID',
                                value: ((state as Success).data as Profile)
                                    .bitsId),
                            Spacer(),
                            _Field(
                              name: 'Hostel & Room',
                              value: ((state as Success).data as Profile).room,
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            offset: Offset(0.0, 3.0),
                            blurRadius: 6.0,
                          )
                        ],
                        color: AppColors.bottomNavBackground,
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x29000000),
                                    offset: Offset(3.0, 6.0),
                                    blurRadius: 6.0,
                                  )
                                ]),
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                color: Colors.white,
                              ),
                              child: QrImage(
                                data:
                                    ((state as Success).data as Profile).qrCode,
                                version: QrVersions.auto,
                                size: 160.0,
                              ),
                            ),
                          ),
                        ),
                        RaisedButton(
                          color: Color(0xFF766B6B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Refresh',
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.white),
                          ),
                          onPressed: presenter.refreshQr,
                        ),
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Button(
                    label: 'Logout',
                    onPressed: () async {
                      await presenter.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login', ModalRoute.withName('/'));
                    },
                  ),
                ),
              )
            ]),
          );
        }

        if (state is Failure) {
          return ErrorMessage(
              message: (state as Failure).message, onRetry: presenter.restart);
        }
      }),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    @required this.name,
    @required this.value,
    this.fontWeight = FontWeight.w500,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    Key key,
  }) : super(key: key);

  final String name;
  final String value;
  final FontWeight fontWeight;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFBE2D6),
          ),
        ),
        SizedBox(height: 6.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: fontWeight,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
