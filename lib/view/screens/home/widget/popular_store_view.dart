import 'package:qareeb/controller/auth_controller.dart';
import 'package:qareeb/controller/store_controller.dart';
import 'package:qareeb/controller/splash_controller.dart';
import 'package:qareeb/controller/theme_controller.dart';
import 'package:qareeb/controller/wishlist_controller.dart';
import 'package:qareeb/data/model/response/module_model.dart';
import 'package:qareeb/data/model/response/store_model.dart';
import 'package:qareeb/helper/route_helper.dart';
import 'package:qareeb/util/app_constants.dart';
import 'package:qareeb/util/dimensions.dart';
import 'package:qareeb/util/styles.dart';
import 'package:qareeb/view/base/custom_image.dart';
import 'package:qareeb/view/base/custom_snackbar.dart';
import 'package:qareeb/view/base/discount_tag.dart';
import 'package:qareeb/view/base/not_available_widget.dart';
import 'package:qareeb/view/base/rating_bar.dart';
import 'package:qareeb/view/base/title_widget.dart';
import 'package:qareeb/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class PopularStoreView extends StatelessWidget {
  final bool isPopular;
  final bool isFeatured;
  PopularStoreView({@required this.isPopular, @required this.isFeatured});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      List<Store> _storeList = isFeatured
          ? storeController.featuredStoreList
          : isPopular
              ? storeController.popularStoreList
              : storeController.latestStoreList;

      return (_storeList != null && _storeList.length == 0)
          ? SizedBox()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, isPopular ? 2 : 15, 10, 10),
                  child: TitleWidget(
                    title: isFeatured
                        ? 'featured_stores'.tr
                        : isPopular
                            ? Get.find<SplashController>()
                                    .configModel
                                    .moduleConfig
                                    .module
                                    .showRestaurantText
                                ? 'popular_restaurants'.tr
                                : 'popular_stores'.tr
                            : '${'new_on'.tr}',
                    onTap: () =>
                        Get.toNamed(RouteHelper.getAllStoreRoute(isFeatured
                            ? 'featured'
                            : isPopular
                                ? 'popular'
                                : 'latest')),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: _storeList != null
                      ? ListView.builder(
                          controller: ScrollController(),
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(
                              left: Dimensions.PADDING_SIZE_SMALL),
                          itemCount:
                              _storeList.length > 10 ? 10 : _storeList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: Dimensions.PADDING_SIZE_SMALL,
                                  bottom: 5),
                              child: InkWell(
                                onTap: () {
                                  if (isFeatured &&
                                      Get.find<SplashController>().moduleList !=
                                          null) {
                                    for (ModuleModel module
                                        in Get.find<SplashController>()
                                            .moduleList) {
                                      if (module.id ==
                                          _storeList[index].moduleId) {
                                        Get.find<SplashController>()
                                            .setModule(module);
                                        break;
                                      }
                                    }
                                  }
                                  Get.toNamed(
                                    RouteHelper.getStoreRoute(
                                        _storeList[index].id,
                                        isFeatured ? 'module' : 'store'),
                                    arguments: StoreScreen(
                                        store: _storeList[index],
                                        fromModule: isFeatured),
                                  );
                                },
                                child: Container(
                                  height: 150,
                                  width: 192,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    // borderRadius: BorderRadius.only(
                                    //  bottomLeft: Radius.circular(100),
                                    // bottomRight: Radius.circular(100)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[
                                            Get.find<ThemeController>()
                                                    .darkTheme
                                                ? 800
                                                : 500],
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Stack(children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(
                                                    Dimensions.RADIUS_EXTRA_LARGE)),
                                            child: CustomImage(
                                              image:
                                                  '${Get.find<SplashController>().configModel.baseUrls.storeCoverPhotoUrl}'
                                                  '/${_storeList[index].coverPhoto}',
                                              height: 150,
                                              width: 250,
                                              fit: BoxFit.cover,

                                            ),
                                          ),
                                          DiscountTag(
                                            discount: storeController
                                                .getDiscount(_storeList[index]),
                                            discountType:
                                                storeController.getDiscountType(
                                                    _storeList[index]),
                                            freeDelivery:
                                                _storeList[index].freeDelivery,
                                          ),
                                          storeController
                                                  .isOpenNow(_storeList[index])
                                              ? SizedBox()
                                              : NotAvailableWidget(
                                                  isStore: true),
                                          Positioned(
                                            top: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL,
                                            left: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL,
                                            child:
                                                GetBuilder<WishListController>(
                                                    builder: (wishController) {
                                              bool _isWished = wishController
                                                  .wishStoreIdList
                                                  .contains(
                                                      _storeList[index].id);
                                              return InkWell(
                                                onTap: () {
                                                  if (Get.find<AuthController>()
                                                      .isLoggedIn()) {
                                                    _isWished
                                                        ? wishController
                                                            .removeFromWishList(
                                                                _storeList[
                                                                        index]
                                                                    .id,
                                                                true)
                                                        : wishController
                                                            .addToWishList(
                                                                null,
                                                                _storeList[
                                                                    index],
                                                                true);
                                                  } else {
                                                    showCustomSnackBar(
                                                        'you_are_not_logged_in'
                                                            .tr);
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(Dimensions
                                                      .PADDING_SIZE_EXTRA_SMALL),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .RADIUS_SMALL),
                                                  ),
                                                  child: Icon(
                                                    _isWished
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 15,
                                                    color: _isWished
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .disabledColor,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ]),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _storeList[index].name ??
                                                        '',
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    _storeList[index].address ??
                                                        '',
                                                    style: robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .disabledColor),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            );
                          },
                        )
                      : PopularStoreShimmer(storeController: storeController),
                ),
              ],
            );
    });
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  PopularStoreShimmer({@required this.storeController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          height: 150,
          width: 200,
          margin:
              EdgeInsets.only(right: Dimensions.PADDING_SIZE_SMALL, bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300], blurRadius: 10, spreadRadius: 1)
              ]),
          child: Shimmer(
            duration: Duration(seconds: 2),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 90,
                width: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimensions.RADIUS_SMALL)),
                    color: Colors.grey[300]),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 10, width: 100, color: Colors.grey[300]),
                        SizedBox(height: 5),
                        Container(
                            height: 10, width: 130, color: Colors.grey[300]),
                        SizedBox(height: 5),
                        RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                      ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
