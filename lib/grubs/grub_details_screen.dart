import 'package:flutter/material.dart';
import 'package:messapp/grubs/grub_details.dart';
import 'package:messapp/grubs/grub_details_presenter.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/date.dart';
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
        builder: (_, presenter, __) {
          final state = presenter.state;

          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Success) {
            final details = (state as Success).data;

            return ListView(
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
