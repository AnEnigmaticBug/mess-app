import 'package:flutter/material.dart';
import 'package:messapp/grubs/grub_details.dart';
import 'package:messapp/grubs/grub_details_presenter.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class GrubDetailsScreen extends StatelessWidget {
  const GrubDetailsScreen({
    @required this.grubName,
    Key key,
  }) : super(key: key);

  final String grubName;

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: grubName,
      selectedTabIndex: 1,
      child: Consumer<GrubDetailsPresenter>(
        builder: (context, presenter, _) {
          final state = presenter.state;

          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Success) {
            final details = (state as Success).data;
            final shouldSign = details is UnsignedGrubDetails;

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 100.0),
                  children: [
                    if (details is UnsignedGrubDetails)
                      _UnsignedInfo(details: details),
                    if (details is SignedUpGrubDetails)
                      _SignedUpInfo(details: details),
                    SizedBox(height: 12.0),
                    for (var offering in details.offerings)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16.0),
                        child: _Offering(offering: offering),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Button(
                      label: shouldSign ? 'Sign up' : 'Cancel',
                      onPressed: () {
                        if (shouldSign) {
                          _signUp(
                            context: context,
                            presenter: presenter,
                            details: details,
                          );
                        } else {
                          _cancel(
                            context: context,
                            presenter: presenter,
                            details: details,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is Failure) {
            return ErrorMessage(
              message: (state as Failure).message,
              onRetry: presenter.restart,
            );
          }
        },
      ),
    );
  }

  Future<void> _signUp({
    @required BuildContext context,
    @required GrubDetailsPresenter presenter,
    @required UnsignedGrubDetails details,
  }) async {
    final offeringId = await showModalBottomSheet(
      context: context,
      builder: (_) => _SignUpSheet(details: details),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8.0),
        ),
      ),
    );

    if (offeringId == null) {
      return;
    }

    try {
      await presenter.signUp(offeringId: offeringId);
      'You have been signed up!'.showSnackBar(context);
    } on Exception catch (e) {
      e.toString().showSnackBar(context);
    }
  }

  Future<void> _cancel({
    @required BuildContext context,
    @required GrubDetailsPresenter presenter,
    @required SignedUpGrubDetails details,
  }) async {
    final shouldCancel = await showModalBottomSheet(
      context: context,
      builder: (_) => _CancelSheet(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8.0),
        ),
      ),
    );

    if (shouldCancel == null || !shouldCancel) {
      return;
    }

    try {
      await presenter.cancel();
      'Your ticket has been cancelled'.showSnackBar(context);
    } on Exception catch (e) {
      e.toString().showSnackBar(context);
    }
  }
}

class _UnsignedInfo extends StatelessWidget {
  const _UnsignedInfo({
    @required this.details,
    Key key,
  }) : super(key: key);

  final UnsignedGrubDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        children: [
          _FieldValue(
            field: 'Organizer',
            value: details.organizer,
          ),
          _FieldValue(
            field: 'Date',
            value: '${DateFormatter(details.date).month} ${details.date.day}',
          ),
          _FieldValue(
            field: 'Sign-up Deadline',
            value:
                '${DateFormatter(details.signUpDeadline).month} ${details.signUpDeadline.day}',
          ),
          _FieldValue(
            field: 'Grub Type',
            value: grubType,
          ),
        ],
      ),
    );
  }

  String get grubType {
    if (details.audience == Audience.Herbivorous) {
      return 'Veg';
    }
    if (details.audience == Audience.Carnivorous) {
      return 'Non-veg';
    }
    return 'Veg & Non-veg';
  }
}

class _SignedUpInfo extends StatelessWidget {
  const _SignedUpInfo({
    @required this.details,
    Key key,
  }) : super(key: key);

  final SignedUpGrubDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      child: Column(
        children: [
          _FieldValue(
            field: 'Organizer',
            value: details.organizer,
          ),
          _FieldValue(
            field: 'Date',
            value: '${DateFormatter(details.date).month} ${details.date.day}',
          ),
          _FieldValue(
            field: 'Cancellation Deadline',
            value:
                '${DateFormatter(details.cancelDeadline).month} ${details.cancelDeadline.day}',
          ),
          _FieldValue(
            field: 'Time',
            value: details.time,
          ),
          _FieldValue(
            field: 'Venue',
            value: details.venue,
          ),
          _FieldValue(
            field: 'Signed for',
            value: details.signedOfferingName,
          ),
        ],
      ),
    );
  }
}

class _FieldValue extends StatelessWidget {
  const _FieldValue({
    @required this.field,
    @required this.value,
    Key key,
  }) : super(key: key);

  final String field;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$field: ',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Offering extends StatelessWidget {
  const _Offering({
    @required this.offering,
    Key key,
  }) : super(key: key);

  final Offering offering;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(3.0, 8.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            offering.name,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 18.0),
          for (var item in offering.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
          SizedBox(height: 18.0),
          Text(
            'Price - ₹ ${offering.price}',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpSheet extends StatefulWidget {
  const _SignUpSheet({
    @required this.details,
    Key key,
  });

  final UnsignedGrubDetails details;

  @override
  _SignUpSheetState createState() => _SignUpSheetState();
}

class _SignUpSheetState extends State<_SignUpSheet> {
  int _offeringId;

  @override
  void initState() {
    super.initState();

    _offeringId = widget.details.offerings[0].id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24.0),
        Text(
          'Select the type of grub:',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 24.0),
        for (var offering in widget.details.offerings)
          _OfferingRadio(
            offering: offering,
            groupValue: _offeringId,
            onChanged: (value) {
              setState(() {
                _offeringId = value;
              });
            },
          ),
        SizedBox(height: 16.0),
        RaisedButton(
          color: Color(0xFF766B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            'Buy stub',
            style: TextStyle(fontSize: 12.0, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop(_offeringId);
          },
        ),
        SizedBox(height: 24.0),
      ],
    );
  }
}

class _OfferingRadio extends StatelessWidget {
  const _OfferingRadio({
    @required this.offering,
    @required this.groupValue,
    @required this.onChanged,
    Key key,
  }) : super(key: key);

  final Offering offering;
  final int groupValue;
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225.0,
      child: RadioListTile(
        title: Text(
          '${offering.name} (₹ ${offering.price})',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        activeColor: AppColors.textDark,
        dense: true,
        value: offering.id,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
    );
  }
}

class _CancelSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 40.0),
        Text(
          'Do you wish to cancel your signing?',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 32.0),
        RaisedButton(
          color: Color(0xFF766B6B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            'Yes, cancel',
            style: TextStyle(fontSize: 12.0, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        SizedBox(height: 24.0),
      ],
    );
  }
}
