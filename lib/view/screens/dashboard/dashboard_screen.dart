import 'dart:async';

import 'package:qareeb/controller/splash_controller.dart';
import 'package:qareeb/helper/responsive_helper.dart';
import 'package:qareeb/util/dimensions.dart';
import 'package:qareeb/view/base/cart_widget.dart';
import 'package:qareeb/view/screens/cart/cart_screen.dart';
import 'package:qareeb/view/screens/dashboard/widget/bottom_nav_item.dart';
import 'package:qareeb/view/screens/favourite/favourite_screen.dart';
import 'package:qareeb/view/screens/home/home_screen.dart';
import 'package:qareeb/view/screens/menu/menu_screen.dart';
import 'package:qareeb/view/screens/order/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  DashboardScreen({@required this.pageIndex});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController _pageController;
  int _pageIndex = 0;
  List<Widget> _screens;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomeScreen(),
      FavouriteScreen(),
      CartScreen(fromNav: true),
      OrderScreen(),
      Container(),
    ];

    Future.delayed(Duration(seconds: 1), () {
      setState(() {});
    });

    /*if(GetPlatform.isMobile) {
      NetworkInfo.checkConnectivity(_scaffoldKey.currentContext);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          if (!ResponsiveHelper.isDesktop(context) &&
              Get.find<SplashController>().module != null &&
              Get.find<SplashController>().configModel.module == null) {
            Get.find<SplashController>().setModule(null);
            return false;
          } else {
            if (_canExit) {
              return true;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('back_press_again_to_exit'.tr,
                    style: TextStyle(color: Colors.white)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              ));
              _canExit = true;
              Timer(Duration(seconds: 2), () {
                _canExit = false;
              });
              return false;
            }
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
       /* floatingActionButton: ResponsiveHelper.isDesktop(context)
            ? null
            : FloatingActionButton(
          elevation: 5,
          backgroundColor: _pageIndex == 2
              ? Colors.white
              : Theme.of(context).cardColor,
          onPressed: () => _setPage(2),
          child: CartWidget(
              color: _pageIndex == 2
                  ? Theme.of(context).cardColor
                  : Theme.of(context).disabledColor,
              size: 30),
        ),*/
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ResponsiveHelper.isDesktop(context)
            ? SizedBox()
            : BottomAppBar(
          color: Theme.of(context).primaryColor,
          elevation: 5,
          notchMargin: 5,
          clipBehavior: Clip.antiAlias,
          shape: CircularNotchedRectangle(),
          child: Padding(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
            child: Row(children: [
              BottomNavItem(
                  iconData: Icons.home,

                  isSelected: _pageIndex == 0,
                  onTap: () => _setPage(0)),
              BottomNavItem(
                  iconData: Icons.favorite_rounded,
                  isSelected: _pageIndex == 1,
                  onTap: () => _setPage(1)),
             // Expanded(child: SizedBox()),
              BottomNavItem(
                  iconData: Icons.history,
                  isSelected: _pageIndex == 3,
                  onTap: () => _setPage(3)),
              BottomNavItem(
                  iconData: Icons.settings,
                  isSelected: _pageIndex == 4,
                  onTap: () {
                    Get.bottomSheet(MenuScreen(),
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true);
                  }),
            ]),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
