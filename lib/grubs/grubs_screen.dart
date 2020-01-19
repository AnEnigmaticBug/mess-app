import 'package:flutter/material.dart';
import 'package:messapp/grubs/grub_listing.dart';
import 'package:messapp/grubs/grub_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class Data {
  const Data({
    @required this.upcomingGrubs,
    @required this.signedUpGrubs,
  });

  final List<GrubListing> upcomingGrubs;
  final List<GrubListing> signedUpGrubs;
}

class GrubsScreen extends StatelessWidget {
  const GrubsScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SimplePresenter<GrubRepository, Data>>(
      builder: (_, presenter, __) {
        final state = presenter.state;

        if (state is Loading) {
          return Screen(
            title: 'Grubs',
            selectedTabIndex: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Success) {
          return TabbedScreen(
            title: 'Grubs',
            selectedTabIndex: 1,
            tabs: ['Upcoming', 'Signed Up'],
            children: [
              _ListingTab(
                listings: state.data.upcomingGrubs,
                forSignedUp: false,
              ),
              _ListingTab(
                listings: state.data.signedUpGrubs,
                forSignedUp: true,
              ),
            ],
          );
        }

        if (state is Failure) {
          return Screen(
            title: 'Grubs',
            selectedTabIndex: 1,
            child: ErrorMessage(
              message: state.message,
              onRetry: presenter.restart,
            ),
          );
        }
      },
    );
  }
}

class _ListingTab extends StatelessWidget {
  const _ListingTab({
    @required this.listings,
    @required this.forSignedUp,
    Key key,
  }) : super(key: key);

  final List<GrubListing> listings;
  final bool forSignedUp;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 100.0),
        itemCount: listings.length,
        itemBuilder: (_, i) => _Listing(
          listing: listings[i],
          forSignedUp: forSignedUp,
        ),
        separatorBuilder: (_, i) => SizedBox(height: 12.0),
      ),
      onRefresh: () async {
        try {
          final presenter =
              Provider.of<SimplePresenter<GrubRepository, Data>>(context);
          await presenter.refresh();
        } on Exception catch (e) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
        }
      },
    );
  }
}

class _Listing extends StatelessWidget {
  const _Listing({
    @required this.listing,
    @required this.forSignedUp,
    Key key,
  }) : super(key: key);

  final GrubListing listing;
  final bool forSignedUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.name,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            listing.organizer,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 12.0),
          Row(
            children: [
              Text(
                '${DateFormatter(listing.date).month} ${listing.date.day}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
              Spacer(),
              _AudienceIndicator(audience: listing.audience),
            ],
          ),
          if (forSignedUp)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Cancellation Deadline: ${DateFormatter(listing.cancelDeadline).month} ${listing.cancelDeadline.day}',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudienceIndicator extends StatelessWidget {
  const _AudienceIndicator({
    Key key,
    @required this.audience,
  }) : super(key: key);

  final Audience audience;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24.0,
      child: Row(
        children: [
          if (audience == Audience.Herbivorous ||
              audience == Audience.Omnivorous)
            _Tag(
              color: Color(0xFFFFE0A4),
              label: Text(
                'Veg',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textDark,
                ),
              ),
            ),
          if (audience == Audience.Carnivorous ||
              audience == Audience.Omnivorous)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _Tag(
                color: Color(0xFFEC8455),
                label: Text(
                  'Non-Veg',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    @required this.color,
    @required this.label,
    Key key,
  }) : super(key: key);

  final Color color;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: label,
      ),
    );
  }
}
