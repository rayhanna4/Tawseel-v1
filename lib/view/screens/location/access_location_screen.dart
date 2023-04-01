import 'package:qareeb/controller/auth_controller.dart';
import 'package:qareeb/controller/location_controller.dart';
import 'package:qareeb/controller/splash_controller.dart';
import 'package:qareeb/data/model/response/address_model.dart';
import 'package:qareeb/data/model/response/zone_response_model.dart';
import 'package:qareeb/helper/responsive_helper.dart';
import 'package:qareeb/helper/route_helper.dart';
import 'package:qareeb/util/dimensions.dart';
import 'package:qareeb/util/images.dart';
import 'package:qareeb/util/styles.dart';
import 'package:qareeb/view/base/custom_app_bar.dart';
import 'package:qareeb/view/base/custom_button.dart';
import 'package:qareeb/view/base/custom_loader.dart';
import 'package:qareeb/view/base/custom_snackbar.dart';
import 'package:qareeb/view/base/footer_view.dart';
import 'package:qareeb/view/base/menu_drawer.dart';
import 'package:qareeb/view/base/no_data_screen.dart';
import 'package:qareeb/view/screens/address/widget/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/view/screens/location/widget/web_landing_page.dart';

import '../../../data/model/response/zone_model.dart';

class AccessLocationScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromIcon;
  final bool fromHome;
  final String route;
  AccessLocationScreen(
      {@required this.fromSignUp,
        @required this.fromHome,
        @required this.fromIcon,
        @required this.route});

  @override
  State<AccessLocationScreen> createState() => _AccessLocationScreenState();
}

class _AccessLocationScreenState extends State<AccessLocationScreen> {
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  int index = -1;
  bool select = false;
  @override
  void initState() {
    super.initState();
    print("widget.route");
    print(widget.route);
    print(widget.fromHome);
    print(widget.fromSignUp);
    // print(Get.find<LocationController>().getUserAddress());
    if (!widget.fromHome &&
        Get.find<LocationController>().getUserAddress() != null) {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.dialog(CustomLoader(), barrierDismissible: false);
        Get.find<LocationController>().autoNavigate(
          Get.find<LocationController>().getUserAddress(),
          widget.fromSignUp,
          widget.route,
          widget.route != null,
          ResponsiveHelper.isDesktop(context),
        );
      });
    }
    if(!widget.fromHome||!widget.fromIcon){
      select = true;
    }
    if (_isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }
    if (Get.find<SplashController>().configModel.module == null &&
        Get.find<SplashController>().moduleList == null) {
      Get.find<SplashController>().getModules();
    }
    Get.find<AuthController>().getZonesList();
    print("widget.route2");
  }

  @override
  Widget build(BuildContext context) {
    print("widget.route3");
    return Scaffold(
      appBar:
      CustomAppBar(title: 'set_location'.tr, backButton: widget.fromHome),
      endDrawer: MenuDrawer(),
      body: SafeArea(
          child: Padding(
            padding: ResponsiveHelper.isDesktop(context)
                ? EdgeInsets.zero
                : EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: GetBuilder<LocationController>(builder: (locationController) {
              print("widget.route4");
              return (ResponsiveHelper.isDesktop(context) &&
                  locationController.getUserAddress() == null)
                  ? WebLandingPage(
                fromSignUp: widget.fromSignUp,
                fromHome: widget.fromHome,
                route: widget.route,
              )
                  : _isLoggedIn
                  ? Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                      child: FooterView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if(select)li(context, locationController),
                                if(!select)locationController.addressList != null
                                    ? locationController.addressList.length > 0
                                    ? ListView.builder(
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: locationController
                                      .addressList.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                        child: SizedBox(
                                            width: 700,
                                            child: AddressWidget(
                                              address:
                                              locationController
                                                  .addressList[
                                              index],
                                              fromAddress: false,
                                              onTap: () {
                                                Get.dialog(
                                                    CustomLoader(),
                                                    barrierDismissible:
                                                    false);
                                                AddressModel _address =
                                                locationController
                                                    .addressList[
                                                index];
                                                locationController
                                                    .saveAddressAndNavigate(
                                                  _address,
                                                  widget.fromSignUp,
                                                  widget.route,
                                                  widget.route != null,
                                                  ResponsiveHelper
                                                      .isDesktop(
                                                      context),
                                                );
                                              },
                                            )));
                                  },
                                )
                                    : select?li(context, locationController):NoDataScreen(
                                    text: 'no_saved_address_found'.tr)
                                    : Center(child: CircularProgressIndicator()),
                                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                                // if(
                                //     !ResponsiveHelper.isDesktop(context)&&!select
                                // )
                                //   CustomButton(
                                //       buttonText: 'user_current_location'.tr,
                                //       onPressed:  () {
                                //         setState(() {
                                //           select = true;
                                //         });
                                //       }
                                //     )
                                //       else SizedBox(),
                              ])),
                    )),
                if(
                !ResponsiveHelper.isDesktop(context)&&!select
                )BottomButton(
                    locationController: locationController,
                    fromSignUp: widget.fromSignUp,
                    route: widget.route),
              ])
                  : Center(
                  child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: FooterView(
                        child: li(context, locationController),
                      )));
            }),
          )),
    );
  }
  Widget li(context,locationController){
    print("widget.route5");
    return SizedBox(
      width: 700,
      // child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Image.asset(Images.delivery_location,
      //           height: 220),
      //       SizedBox(
      //           height: Dimensions.PADDING_SIZE_LARGE),
      //       Text(
      //           'find_stores_and_items'
      //               .tr
      //               .toUpperCase(),
      //           textAlign: TextAlign.center,
      //           style: robotoMedium.copyWith(
      //               fontSize:
      //                   Dimensions.fontSizeExtraLarge)),
      //       Padding(
      //         padding: EdgeInsets.all(
      //             Dimensions.PADDING_SIZE_LARGE),
      //         child: Text(
      //           'by_allowing_location_access'.tr,
      //           textAlign: TextAlign.center,
      //           style: robotoRegular.copyWith(
      //               fontSize: Dimensions.fontSizeSmall,
      //               color: Theme.of(context)
      //                   .disabledColor),
      //         ),
      //       ),
      //       SizedBox(
      //           height: Dimensions.PADDING_SIZE_LARGE),
      //       BottomButton(
      //           locationController: locationController,
      //           fromSignUp: widget.fromSignUp,
      //           route: widget.route),
      //     ]),
      child: GetBuilder<AuthController>(builder: (authController){
        if(authController.zonesList.isEmpty){
          return Center(child: CircularProgressIndicator());
        }else{
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...List.generate(authController.zonesList.length, (i) {
                ZoneModel z = authController.zonesList[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      child: Row(
                        children: [
                          Text(z.name,style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),),
                          Spacer(),
                          if(i==index)CircleAvatar(
                            radius: 8,backgroundColor: Colors.green
                              .withOpacity(0.6),),
                          SizedBox(width: 20,),
                        ],
                      ),
                      onTap: (){
                        setState(() {
                          index = i;
                        });
                      },
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: List.generate(30, (i) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width*0.9)/30,
                            child: Divider(endIndent: 1,indent: 1,thickness:
                            MediaQuery.of(context).size.height*0.0015,
                              color: Colors.grey.shade300,),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              }),
              if(authController.zonesList.length==3)SizedBox(
                height: MediaQuery.of(context).size.height/3,
              ),
              if(authController.zonesList.length<=2)SizedBox(
                height: MediaQuery.of(context).size.height/2,
              ),
              if(authController.zonesList.length>3)SizedBox(
                height: MediaQuery.of(context).size.height*0.2,
              ),
              CustomButton(
                buttonText: index==-1?'pick_location'.tr:'confirm'.tr,
                onPressed:  () {
                  if(index!=-1){
                    AddressModel _address = AddressModel(
                      latitude: authController.zonesList[index].coordinates.coordinates.first.latitude.toString(),
                      longitude: authController.zonesList[index].coordinates.coordinates.first.latitude.toString(),
                      addressType: 'others', address: authController.zonesList[index].name,
                    );
                    locationController.saveAddressAndNavigate(
                        _address, widget.fromSignUp, widget.route == null ?
                    RouteHelper.accessLocation : widget.route, widget.route!=null,
                        ResponsiveHelper.isDesktop(context),
                        fromPick: true,
                        id: authController.zonesList[index].id
                    );
                  }
                },
              ),            ],
          );
        }
      },
      ),);
  }
}

class BottomButton extends StatelessWidget {
  final LocationController locationController;
  final bool fromSignUp;
  final String route;
  BottomButton(
      {@required this.locationController,
        @required this.fromSignUp,
        @required this.route});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            width: 700,
            child: Column(children: [
              CustomButton(
                buttonText: 'user_current_location'.tr,
                onPressed: () async {
                  // String _color = '0xFFAA6843';
                  // String _color1 = '0xFFc7794c';
                  // Get.find<ThemeController>().changeTheme(Color(int.parse(_color)), Color(int.parse(_color1)));
                  Get.find<LocationController>().checkPermission(() async {
                    Get.dialog(CustomLoader(), barrierDismissible: false);
                    AddressModel _address = await Get.find<LocationController>()
                        .getCurrentLocation(true);
                    ZoneResponseModel _response = await locationController
                        .getZone(_address.latitude, _address.longitude, false);
                    if (_response.isSuccess) {
                      locationController.saveAddressAndNavigate(
                        _address,
                        fromSignUp,
                        route,
                        route != null,
                        ResponsiveHelper.isDesktop(context),
                      );
                    } else {
                      Get.back();
                      Get.toNamed(RouteHelper.getPickMapRoute(
                          route == null ? RouteHelper.accessLocation : route,
                          route != null));
                      showCustomSnackBar(
                          'service_not_available_in_current_location'.tr);
                    }
                  });
                },
                icon: Icons.my_location,
              ),
            ])));
  }
}
