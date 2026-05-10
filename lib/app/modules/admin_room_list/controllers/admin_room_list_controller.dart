import 'package:flutter/cupertino.dart';
import 'package:aramisc/app/utilities/api_urls.dart';
import 'package:aramisc/app/utilities/widgets/loader/loading.controller.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/domain/base_client/base_client.dart';
import 'package:aramisc/domain/core/model/admin/dormitory_model/dormitory_room_list_response_model.dart';
import 'package:get/get.dart';

class AdminRoomListController extends GetxController {
  LoadingController loadingController = Get.find();

  List<DormitoryRoomListData> dormitoryRoomList = [];

  Future<DormitoryRoomListResponseModel> getDormitoryRoomList() async {
    try {
      dormitoryRoomList.clear();
      loadingController.isLoading = true;

      final response = await BaseClient().getData(
        url: AramiscApi.dormitoryRoomList,
        header: GlobalVariable.header,
      );
      DormitoryRoomListResponseModel dormitoryRoomListResponseModel =
          DormitoryRoomListResponseModel.fromJson(response);

      if (dormitoryRoomListResponseModel.success == true) {
        if (dormitoryRoomListResponseModel.data!.isNotEmpty) {
          for (int i = 0;
              i < dormitoryRoomListResponseModel.data!.length;
              i++) {
            dormitoryRoomList.add(dormitoryRoomListResponseModel.data![i]);
          }
        }
      }
    } catch (e, t) {
      loadingController.isLoading = false;
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      loadingController.isLoading = false;
    }

    return DormitoryRoomListResponseModel();
  }

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDormitoryRoomList();
    });
    super.onInit();
  }
}
