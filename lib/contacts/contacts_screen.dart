import 'package:flutter/material.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/simple_presenter.dart';
import 'package:messapp/util/ui_state.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'SSMS GC',
      selectedTabIndex: 4,
      child: Consumer<SimplePresenter<ContactRepository, List<Contact>>>(
        builder: (context, presenter, _) {
          final state = presenter.state;

          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Success) {
            return RefreshIndicator(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 80.0),
                itemCount: state.data.length,
                itemBuilder: (_, i) {
                  return _ContactTile(contact: state.data[i]);
                },
                separatorBuilder: (_, i) => SizedBox(height: 10.0),
              ),
              onRefresh: () async {
                try {
                  await presenter.refresh();
                } on Exception catch (e) {
                  e.prettify().showSnackBar(context);
                }
              },
            );
          }

          if (state is Failure) {
            return ErrorMessage(
              message: state.message,
              onRetry: presenter.restart,
            );
          }
        },
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    Key key,
    @required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(contact.photoUrl),
              radius: 32.0,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.post,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.0),
              Text(
                contact.name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.0),
              GestureDetector(
                child: Text(
                  contact.mobileNo,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFE56B44),
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final url = 'tel:${contact.mobileNo}';

                  if (!await canLaunch(url)) {
                    'Your device is stopping the call'.showSnackBar(context);
                    return;
                  }

                  await launch(url);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
