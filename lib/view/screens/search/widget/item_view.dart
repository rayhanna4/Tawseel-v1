import 'package:qareeb/controller/search_controller.dart';
import 'package:qareeb/util/dimensions.dart';
import 'package:qareeb/view/base/footer_view.dart';
import 'package:qareeb/view/base/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemView extends StatelessWidget {
  final bool isItem;
  ItemView({@required this.isItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SearchController>(builder: (searchController) {
        return SingleChildScrollView(
          child: FooterView(
            child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: ItemsView(
              isStore: isItem, items: searchController.searchItemList, stores: searchController.searchStoreList,
            )),
          ),
        );
      }),
    );
  }
}
