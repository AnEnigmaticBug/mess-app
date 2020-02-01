import 'package:flutter/material.dart';
import 'package:messapp/util/widgets.dart';

class OnboardingScreen extends StatelessWidget {
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
          end: Alignment.centerRight,
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
          //main body
          child: _Content(),
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: 4,
      itemBuilder: (_, i) {
        if (i == 0)
          return _OnboardingScreen(
            text1: 'Swipe to change date',
            text2: 'Rate the mess menu',
            buttonText: 'Next',
            imageAsset1: 'assets/images/onboarding-swipe.png',
            imageAsset2: 'assets/images/onboarding-like.png',
            screenImageAsset: 'assets/images/onboarding-menu-screen.png',
            onButtonPressed: _nextPage,
          );
        else if (i == 1)
          return _OnboardingScreen(
            text1: 'Upvote relevant issues',
            text2: 'Flag inappropriate ones',
            buttonText: 'Next',
            imageAsset1: 'assets/images/onboarding-upvote.png',
            imageAsset2: 'assets/images/onboarding-flag.png',
            screenImageAsset: 'assets/images/onboarding-issues-screen.png',
            onButtonPressed: _nextPage,
          );
        else if (i == 2)
          return _OnboardingScreen(
            text1: 'Sign/Cancel grub tickets',
            text2: 'View grub related details',
            buttonText: 'Next',
            imageAsset1: 'assets/images/onboarding-grub.png',
            imageAsset2: 'assets/images/onboarding-details.png',
            screenImageAsset: 'assets/images/onboarding-grubs-screen.png',
            onButtonPressed: _nextPage,
          );
        else if (i == 3)
          return _OnboardingScreen(
            text1: 'Pull to refresh the content',
            text2: 'Get push notifications',
            buttonText: 'Let\'s dine',
            imageAsset1: 'assets/images/onboarding-refresh.png',
            imageAsset2: 'assets/images/onboarding-notification.png',
            screenImageAsset: 'assets/images/onboarding-notices-screen.png',
            onButtonPressed: () {
              Navigator.of(context).pop();
            },
          );
        else
          return Container();
      },
    );
  }

  void _nextPage() {
    _controller.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({
    @required this.text1,
    @required this.text2,
    @required this.buttonText,
    @required this.imageAsset1,
    @required this.imageAsset2,
    @required this.screenImageAsset,
    @required this.onButtonPressed,
    Key key,
  }) : super(key: key);

  final String text1;
  final String text2;
  final String buttonText;
  final String imageAsset1;
  final String imageAsset2;
  final String screenImageAsset;
  final VoidCallback onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          _OnboardingTile(text: text1, imageAsset: imageAsset1),
          SizedBox(height: 40.0),
          _OnboardingTile(text: text2, imageAsset: imageAsset2),
          Spacer(),
          Expanded(
            flex: 7,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(screenImageAsset),
            ),
          ),
        ],
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 240.0,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            //stops: [0.3, 0.3, 0.3],
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Button(
            label: buttonText,
            onPressed: onButtonPressed,
          ),
        ),
      ),
    ]);
  }
}

class _OnboardingTile extends StatelessWidget {
  const _OnboardingTile(
      {@required this.text, @required this.imageAsset, Key key})
      : super(key: key);

  final String text;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageAsset),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ]);
  }
}
