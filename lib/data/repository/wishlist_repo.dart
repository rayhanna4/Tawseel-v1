import 'package:qareeb/data/api/api_client.dart';
import 'package:qareeb/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class WishListRepo {
  final ApiClient apiClient;
  WishListRepo({@required this.apiClient});

  Future<Response> getWishList() async {
    return await apiClient.getData(AppConstants.WISH_LIST_GET_URI);
  }

  Future<Response> addWishList(int id, bool isStore) async {
    return await apiClient.postData('${AppConstants.ADD_WISH_LIST_URI}${isStore ? 'store_id=' : 'item_id='}$id', null);
  }

  Future<Response> removeWishList(int id, bool isStore) async {
    return await apiClient.deleteData('${AppConstants.REMOVE_WISH_LIST_URI}${isStore ? 'store_id=' : 'item_id='}$id');
  }
}
