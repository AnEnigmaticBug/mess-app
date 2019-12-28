import 'package:flutter/material.dart';
import 'package:messapp/contacts/contact.dart';
import 'package:messapp/contacts/contact_info.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'SSMS GC',
      selectedTabIndex: 4,
      child: Consumer<ContactInfo>(
        builder: (_, contactInfo, __) {
          final state = contactInfo.state;
          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is Success) {
            return RefreshIndicator(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 80.0),
                itemCount: state.contacts.length,
                itemBuilder: (_, i) => _ContactTile(contact: state.contacts[i]),
                separatorBuilder: (_, i) => SizedBox(height: 10.0),
              ),
              onRefresh: () async {
                await contactInfo.refresh();
              },
            );
          }
          return Center(child: Text((state as Failure).error));
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
              Text(
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
            ],
          ),
        ],
      ),
    );
  }
}
