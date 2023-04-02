import 'package:qareeb/controller/auth_controller.dart';
import 'package:qareeb/controller/banner_controller.dart';
import 'package:qareeb/controller/campaign_controller.dart';
import 'package:qareeb/controller/category_controller.dart';
import 'package:qareeb/controller/location_controller.dart';
import 'package:qareeb/controller/notification_controller.dart';
import 'package:qareeb/controller/item_controller.dart';
import 'package:qareeb/controller/parcel_controller.dart';
import 'package:qareeb/controller/store_controller.dart';
import 'package:qareeb/controller/splash_controller.dart';
import 'package:qareeb/controller/user_controller.dart';
import 'package:qareeb/helper/responsive_helper.dart';
import 'package:qareeb/helper/route_helper.dart';
import 'package:qareeb/util/dimensions.dart';
import 'package:qareeb/util/images.dart';
import 'package:qareeb/util/styles.dart';
import 'package:qareeb/view/base/item_view.dart';
import 'package:qareeb/view/base/menu_drawer.dart';
import 'package:qareeb/view/base/paginated_list_view.dart';
import 'package:qareeb/view/base/web_menu_bar.dart';
import 'package:qareeb/view/screens/home/theme1/theme1_home_screen.dart';
import 'package:qareeb/view/screens/home/web_home_screen.dart';
import 'package:qareeb/view/screens/home/widget/filter_view.dart';
import 'package:qareeb/view/screens/home/widget/popular_item_view.dart';
import 'package:qareeb/view/screens/home/widget/item_campaign_view.dart';
import 'package:qareeb/view/screens/home/widget/popular_store_view.dart';
import 'package:qareeb/view/screens/home/widget/banner_view.dart';
import 'package:qareeb/view/screens/home/widget/category_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/view/screens/home/widget/module_view.dart';
import 'package:qareeb/view/screens/parcel/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {

  static Future<void> loadData(bool reload) async {
    if(Get.find<SplashController>().module != null && !Get.find<SplashController>().configModel.moduleConfig.module.isParcel) {
      Get.find<BannerController>().getBannerList(reload);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<ItemController>().getPopularItemList(reload, 'all', false);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<ItemController>().getReviewedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
    }
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      if(Get.find<AuthController>().isLoggedIn()) {
        Get.find<LocationController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel.moduleConfig.module.isParcel) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    HomeScreen.loadData(false);
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      bool _showMobileModule = !ResponsiveHelper.isDesktop(context) &&
          splashController.module == null &&
          splashController.configModel.module == null;
      bool _isParcel = splashController.module != null &&
          splashController.configModel.moduleConfig.module.isParcel;

      return Scaffold(

        appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
        endDrawer: MenuDrawer(),
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Color(0xffffffff)
            : splashController.module == null
            ? Color(0xffffffff)
            : null,
        body: _isParcel
            ? ParcelCategoryScreen()
            : SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              if (Get.find<SplashController>().module != null) {
                await Get.find<BannerController>().getBannerList(true);
                await Get.find<CategoryController>()
                    .getCategoryList(true);
                await Get.find<StoreController>()
                    .getPopularStoreList(true, 'all', false);
                await Get.find<CampaignController>()
                    .getItemCampaignList(true);
                await Get.find<ItemController>()
                    .getPopularItemList(true, 'all', false);
                await Get.find<StoreController>()
                    .getLatestStoreList(true, 'all', false);
                await Get.find<ItemController>()
                    .getReviewedItemList(true, 'all', false);
                await Get.find<StoreController>().getStoreList(1, true);
                if (Get.find<AuthController>().isLoggedIn()) {
                  await Get.find<UserController>().getUserInfo();
                  await Get.find<NotificationController>()
                      .getNotificationList(true);
                }
              } else {
                await Get.find<BannerController>().getFeaturedBanner();
                await Get.find<SplashController>().getModules();
                if (Get.find<AuthController>().isLoggedIn()) {
                  await Get.find<LocationController>().getAddressList();
                }
                await Get.find<StoreController>().getFeaturedStoreList();
              }
            },
            child: ResponsiveHelper.isDesktop(context)
                ? WebHomeScreen(
              scrollController: _scrollController,
            )
                : (Get.find<SplashController>().module != null &&
                Get.find<SplashController>().module.themeId == 2)
                ? Theme1HomeScreen(
              scrollController: _scrollController,
              splashController: splashController,
              showMobileModule: _showMobileModule,
            )
                : CustomScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar

               SliverAppBar(

                  floating: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor:Theme.of(context).primaryColor,
                  title: Center(
                      child: Container(
                        width: Dimensions.WEB_MAX_WIDTH,
                        height: 60,
                     decoration: BoxDecoration(
                       color: Theme.of(context).primaryColor,

                     ),
                        child: Row(children: [
                          (splashController.module != null &&
                              splashController
                                  .configModel.module ==
                                  null)
                              ? InkWell(
                            onTap: () => splashController
                                .removeModule(),
                            child: Image.asset(
                                Images.module_icon,
                                height: 22,
                                width: 22,
                                color:Theme.of(context).secondaryHeaderColor),
                          )
                              : SizedBox(),
                          SizedBox(
                              width: (splashController.module !=
                                  null &&
                                  splashController
                                      .configModel.module ==
                                      null)
                                  ? Dimensions
                                  .PADDING_SIZE_EXTRA_SMALL
                                  : 0),
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                      RouteHelper.getAccessLocationRoute(
                                          'home'));
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical:
                                    Dimensions.PADDING_SIZE_DEFAULT,
                                    horizontal: ResponsiveHelper
                                        .isDesktop(context)
                                        ? Dimensions.PADDING_SIZE_SMALL
                                        : 0,
                                  ),
                                  child: GetBuilder<LocationController>(
                                      builder: (locationController) {
                                        return Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                Get.toNamed(
                                                    RouteHelper.getAccessLocationRoute(
                                                        'home','true'));
                                              },
                                              child: Icon(
                                                locationController
                                                    .getUserAddress()
                                                    .addressType ==
                                                    'home'
                                                    ? Icons.home_filled
                                                    : locationController
                                                    .getUserAddress()
                                                    .addressType ==
                                                    'office'
                                                    ? Icons.work
                                                    : Icons.location_on_rounded,
                                                size: 25,
                                                color:Theme.of(context).secondaryHeaderColor
                                              ),
                                            ),
                                            SizedBox(width: 95),
                                            InkWell(
                                              // onTap: (){
                                              //   Get.toNamed(
                                              //       RouteHelper.getAccessLocationRoute(
                                              //           'home',));
                                              // },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    locationController
                                                        .getUserAddress()
                                                        .address,
                                                    style:TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),

                                          ],
                                        );
                                      }),
                                ),
                              )),
                          InkWell(
                            child:
                            GetBuilder<NotificationController>(
                                builder:
                                    (notificationController) {
                                  return Stack(children: [
                                    Icon(Icons.notifications,
                                        size: 25,
                                        color:Theme.of(context).secondaryHeaderColor),
                                    notificationController
                                        .hasNotification
                                        ? Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: 1,
                                                color: Theme.of(
                                                    context)
                                                    .cardColor),
                                          ),
                                        ))
                                        : SizedBox(),
                                  ]);
                                }),
                            onTap: () => Get.toNamed(
                                RouteHelper.getNotificationRoute()),
                          ),
                        ]),
                      )),
                  actions: [SizedBox()],
                ),

                // Search Button

                !_showMobileModule
                    ? SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                      child: Center(
                          child: Container(
                            height: 70,
                            width: Dimensions.WEB_MAX_WIDTH,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions
                                    .PADDING_SIZE_SMALL),
                            child: InkWell(
                              onTap: () => Get.toNamed(
                                  RouteHelper.getSearchRoute()),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Dimensions
                                        .PADDING_SIZE_SMALL),
                                decoration: BoxDecoration(
                                  color:
                                  Theme.of(context).cardColor,
                                  borderRadius:
                                  BorderRadius.circular(
                                      Dimensions
                                          .RADIUS_SMALL),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[
                                        Get.isDarkMode
                                            ? 800
                                            : 200],
                                        spreadRadius: 1,
                                        blurRadius: 5)
                                  ],
                                ),
                                child: Row(children: [
                                  Icon(
                                    Icons.search,
                                    size: 25,
                                    color: Theme.of(context)
                                        .primaryColor,
                                  ),
                                  SizedBox(
                                      width: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  Expanded(
                                      child: Text(
                                        Get.find<SplashController>()
                                            .configModel
                                            .moduleConfig
                                            .module
                                            .showRestaurantText
                                            ? 'search_food_or_restaurant'
                                            .tr
                                            : 'search_item_or_store'
                                            .tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions
                                              .fontSizeSmall,
                                          color: Theme.of(context)
                                              .hintColor,
                                        ),
                                      )),
                                ]),
                              ),
                            ),
                          ))),
                )
                    : SliverToBoxAdapter(),

                SliverToBoxAdapter(
                  child: Center(
                      child: SizedBox(
                        width: Dimensions.WEB_MAX_WIDTH,
                        child: !_showMobileModule
                            ? Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                             BannerView(isFeatured: false),
                             CategoryView(),
                              PopularStoreView(
                                  isPopular: true,
                                  isFeatured: false),
                              ItemCampaignView(),
                              PopularItemView(
                                  isPopular: true),
                              PopularStoreView(
                                  isPopular: false,
                                  isFeatured: false),
                              PopularItemView(
                                  isPopular: false),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    10, 15, 0, 5),
                               child: Row(children: [
                                  Expanded(
                                      child: Text(
                                        Get.find<SplashController>()
                                            .configModel
                                            .moduleConfig
                                            .module
                                            .showRestaurantText
                                            ? 'all_restaurants'.tr
                                            : 'all_stores'.tr,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions
                                                .fontSizeLarge),
                                      )),
                                  FilterView(),
                                ]),
                              ),
                              GetBuilder<StoreController>(
                                  builder: (storeController) {
                                    return PaginatedListView(
                                      scrollController:
                                      _scrollController,
                                      totalSize: storeController
                                          .storeModel !=
                                          null
                                          ? storeController
                                          .storeModel
                                          .totalSize
                                          : null,
                                      offset: storeController
                                          .storeModel !=
                                          null
                                          ? storeController
                                          .storeModel.offset
                                          : null,
                                      onPaginate: (int
                                      offset) async =>
                                      await storeController
                                          .getStoreList(
                                          offset, false),
                                      itemView: ItemsView(
                                        isStore: true,
                                        items: null,
                                        stores: storeController
                                            .storeModel !=
                                            null
                                            ? storeController
                                            .storeModel.stores
                                            : null,
                                        padding:
                                        EdgeInsets.symmetric(
                                          horizontal: ResponsiveHelper
                                              .isDesktop(
                                              context)
                                              ? Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL
                                              : Dimensions
                                              .PADDING_SIZE_SMALL,
                                          vertical: ResponsiveHelper
                                              .isDesktop(
                                              context)
                                              ? Dimensions
                                              .PADDING_SIZE_EXTRA_SMALL
                                              : 0,
                                        ),
                                      ),
                                    );
                                  }),
                            ])
                            : ModuleView(
                            splashController: splashController),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({@required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 ||
        oldDelegate.minExtent != 50 ||
        child != oldDelegate.child;
  }
}
