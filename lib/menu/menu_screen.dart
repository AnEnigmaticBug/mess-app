import 'package:flutter/material.dart';
import 'package:messapp/menu/dish.dart';
import 'package:messapp/menu/meal.dart';
import 'package:messapp/menu/menu.dart';
import 'package:messapp/menu/menu_info.dart';
import 'package:messapp/util/app_colors.dart';
import 'package:messapp/util/app_icons.dart';
import 'package:messapp/util/date.dart';
import 'package:messapp/util/widgets.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: 'Menu',
      selectedTabIndex: 2,
      child: Consumer<MenuInfo>(
        builder: (_, menuInfo, __) {
          final state = menuInfo.state;

          if (state is Loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is Failure) {
            return Center(child: Text(state.error));
          }
          if (state is Success) {
            return _Success(state: state);
          }
        },
      ),
    );
  }
}

class _Success extends StatefulWidget {
  const _Success({
    Key key,
    @required this.state,
  }) : super(key: key);

  final Success state;

  @override
  _SuccessState createState() => _SuccessState();
}

class _SuccessState extends State<_Success> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    final initialPage =
        widget.state.menus.indexWhere((menu) => menu.date == Date.now());
    
    if (initialPage == -1) {
      _controller = PageController();
    } else {
      _controller = PageController(initialPage: initialPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: widget.state.menus.length,
      itemBuilder: (_, i) => _MenuPage(widget.state.menus[i]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MenuPage extends StatelessWidget {
  const _MenuPage(
    this.menu, {
    Key key,
  }) : super(key: key);

  final Menu menu;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _MenuDate(menu.date),
        RefreshIndicator(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 108.0, bottom: 28.0),
            itemCount: menu.meals.length,
            itemBuilder: (_, i) => _MealCard(menu.meals[i]),
            separatorBuilder: (_, __) => SizedBox(height: 22.0),
          ),
          onRefresh: Provider.of<MenuInfo>(context).refresh,
        ),
      ],
    );
  }
}

class _MenuDate extends StatelessWidget {
  const _MenuDate(
    this.date, {
    Key key,
  }) : super(key: key);

  final Date date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Month(date: date),
              SizedBox(height: 4.0),
              _WeekDay(date: date),
            ],
          ),
        ),
        SizedBox(width: 20.0),
        Container(color: AppColors.textDark, width: 1.0, height: 72.0),
        SizedBox(width: 20.0),
        Expanded(
          child: _DayOfMonth(date: date),
        ),
      ],
    );
  }
}

class _Month extends StatelessWidget {
  const _Month({
    @required this.date,
    Key key,
  }) : super(key: key);

  final Date date;

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormatter(date).month,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w300,
        color: AppColors.textDark,
      ),
      textAlign: TextAlign.right,
    );
  }
}

class _WeekDay extends StatelessWidget {
  const _WeekDay({
    @required this.date,
    Key key,
  }) : super(key: key);

  final Date date;

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormatter(date).weekDay,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      textAlign: TextAlign.right,
    );
  }
}

class _DayOfMonth extends StatelessWidget {
  const _DayOfMonth({
    @required this.date,
    Key key,
  }) : super(key: key);

  final Date date;

  @override
  Widget build(BuildContext context) {
    return Text(
      date.day.toString().padLeft(2, '0'),
      style: TextStyle(
        fontSize: 84.0,
        fontFamily: 'LibreBaskerville',
        color: AppColors.textDark,
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard(
    this.meal, {
    Key key,
  }) : super(key: key);

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
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
          SizedBox(height: 28.0),
          _MealName(meal: meal),
          SizedBox(height: 30.0),
          for (var dish in meal.dishes)
            ChangeNotifierProvider.value(value: dish, child: _DishTile()),
          SizedBox(height: 40.0),
        ],
      ),
    );
  }
}

class _MealName extends StatelessWidget {
  const _MealName({
    @required this.meal,
    Key key,
  }) : super(key: key);

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Text(
      meal.name,
      style: TextStyle(
        fontSize: 17.0,
        fontFamily: 'LibreBaskerville',
        color: Colors.white.withOpacity(0.75),
      ),
    );
  }
}

class _DishTile extends StatelessWidget {
  const _DishTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dish = Provider.of<Dish>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dish.name,
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
          _DishRater(
            rating: dish.rating,
            onRate: (rating) async {
              try {
                await dish.rate(rating);
              } on Exception catch (e) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(e.toString()),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DishRater extends StatelessWidget {
  const _DishRater({
    @required this.rating,
    @required this.onRate,
    Key key,
  }) : super(key: key);

  final Rating rating;
  final Function(Rating) onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RateButton(
          activeIconData: AppIcons.thumbs_up_solid,
          inactiveIconData: AppIcons.thumbs_up_outlined,
          isActive: rating == Rating.Positive,
          onPressed: () {
            if (rating == Rating.Positive) {
              onRate(Rating.NotRated);
            } else {
              onRate(Rating.Positive);
            }
          },
        ),
        SizedBox(width: 4.0),
        _RateButton(
          activeIconData: AppIcons.thumbs_down_solid,
          inactiveIconData: AppIcons.thumbs_down_outlined,
          isActive: rating == Rating.Negative,
          onPressed: () {
            if (rating == Rating.Negative) {
              onRate(Rating.NotRated);
            } else {
              onRate(Rating.Negative);
            }
          },
        ),
      ],
    );
  }
}

class _RateButton extends StatelessWidget {
  const _RateButton({
    @required this.activeIconData,
    @required this.inactiveIconData,
    @required this.isActive,
    @required this.onPressed,
    Key key,
  }) : super(key: key);

  final IconData activeIconData;
  final IconData inactiveIconData;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedCrossFade(
          firstChild: Icon(
            activeIconData,
            color: Color(0xFFFFE0A4),
          ),
          secondChild: Icon(
            inactiveIconData,
            color: Color(0xFFFFE0A4),
          ),
          crossFadeState:
              isActive ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 100),
        ),
      ),
      onTap: onPressed,
    );
  }
}
