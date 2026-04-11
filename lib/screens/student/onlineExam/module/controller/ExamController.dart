import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:aramisc/controller/user_controller.dart';
import 'package:aramisc/screens/student/onlineExam/module/model/ActiveOnlineModel.dart';
import 'package:http/http.dart' as http;
import 'package:aramisc/utils/Utils.dart';
import 'package:aramisc/utils/apis/Apis.dart';

import '../../../../../utils/model/StudentRecord.dart';

class ExamController extends GetxController {
  final UserController _userController = Get.put(UserController());

  Rx<ActiveOnlineModel> exams = ActiveOnlineModel().obs;

  RxBool isLoading = false.obs;

  Future getAllActiveExam(var id, int recordId) async {
    try {
      log("URL => ${AramiscApi.getOnlineExamModule(id, recordId, _userController.schoolId.value)}");
      isLoading(true);
      final response = await http.get(
          Uri.parse(AramiscApi.getOnlineExamModule(
              id, recordId, _userController.schoolId.value)),
          headers: Utils.setHeader(_userController.token.value.toString()));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        exams.value = ActiveOnlineModel.fromJson(jsonData);

        isLoading(false);
        return exams.value;
      } else {
        isLoading(false);
        throw Exception('Failed to load');
      }
    } catch (e) {
      isLoading(false);
      throw Exception(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    _userController.selectedRecord.value =
        _userController.studentRecord.value.records?.first ?? Record();
    super.onInit();
  }
}
