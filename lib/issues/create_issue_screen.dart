import 'package:flutter/material.dart';
import 'package:messapp/issues/issue_repository.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/extensions.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class CreateIssueScreen extends StatelessWidget {
  const CreateIssueScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Create Issue',
      selectedTabIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _Guidelines(
            guidelines: [
              'Ensure a similar issue doesn\'t already exist',
              'Do not mention your mess. Your issue will be automatically associated with your mess.',
              'Do not provide feedback about specific items. Use the ratings feature instead.',
              'Do not post random content.',
            ],
          ),
          SizedBox(height: 16.0),
          _IssueEntry(),
        ],
      ),
    );
  }
}

class _Guidelines extends StatelessWidget {
  const _Guidelines({
    @required this.guidelines,
    Key key,
  }) : super(key: key);

  final List<String> guidelines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFE0A4),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0.0, 3.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.0),
          Center(
            child: Text(
              'Guidelines',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          for (var guideline in guidelines) _Guideline(content: guideline)
        ],
      ),
    );
  }
}

class _Guideline extends StatelessWidget {
  const _Guideline({
    @required this.content,
    Key key,
  }) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•',
              style: TextStyle(fontSize: 12.0, color: AppColors.textDark)),
          SizedBox(width: 4.0),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _IssueEntry extends StatefulWidget {
  const _IssueEntry({
    Key key,
  }) : super(key: key);

  @override
  _IssueEntryState createState() => _IssueEntryState();
}

class _IssueEntryState extends State<_IssueEntry> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF8F6F1),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(0.0, 3.0),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        children: [
          _IssueField(controller: _controller),
          SizedBox(height: 12.0),
          RaisedButton(
            color: Color(0xFF766B6B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Create',
              style: TextStyle(fontSize: 12.0, color: Colors.white),
            ),
            onPressed: _onCreatePressed,
          ),
        ],
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    FocusScope.of(context).unfocus();

    final title = _controller.text;

    if (title.isEmpty) {
      'Issues cannot have an empty body'.showSnackBar(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      await Provider.of<IssueRepository>(context).createIssue(title);
      'Issue created successfully'.showSnackBar(context);
    } on Exception {
      'Could not create issue....'.showSnackBar(context);
    } finally {
      Navigator.pop(context);
    }
  }
}

class _IssueField extends StatelessWidget {
  const _IssueField({
    @required TextEditingController controller,
    Key key,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Describe the issue in 70 characters',
        hintStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w300,
          color: Color(0xFFBFB0A3),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(fontSize: 14.0, color: AppColors.textDark),
      textInputAction: TextInputAction.done,
      controller: _controller,
      minLines: 2,
      maxLines: 2,
      maxLength: 70,
      maxLengthEnforced: true,
    );
  }
}
