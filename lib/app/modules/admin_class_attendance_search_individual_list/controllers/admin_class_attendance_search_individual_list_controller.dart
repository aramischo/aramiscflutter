import 'package:flutter/cupertino.dart';
import 'package:aramisc/app/data/constants/app_text.dart';
import 'package:aramisc/app/utilities/api_urls.dart';
import 'package:aramisc/app/utilities/message/snack_bars.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/domain/base_client/base_client.dart';
import 'package:aramisc/domain/core/model/admin/admin_attendance_model/admin_class_atten_search_individual_response_model.dart';
import 'package:get/get.dart';

class AdminClassAttendanceSearchIndividualListController
    extends GetxController {
  GlobalRxVariableController globalRxVariableController = Get.find();

  RxList<AdminStudentsIndividualData> adminStudentIndividualList =
      <AdminStudentsIndividualData>[].obs;

  RxInt classId = 0.obs;
  RxInt sectionId = 0.obs;
  RxString name = ''.obs;
  RxString rollNo = ''.obs;

  RxBool isLoading = false.obs;

  Future<AdminClassAttenSearchIndividualResponseModel>
      getAdminSearchIndividualStudentList({
    required int classId,
    required int sectionId,
    required String name,
    required String rollNo,
  }) async {
    try {
      isLoading.value = true;

      final response = await BaseClient().getData(
          url: globalRxVariableController.roleId.value == 1
              ? AramiscApi.getAdminSubAttenSearchIndividualList(
                  classId: classId,
                  sectionId: sectionId,
                  rollINo: rollNo,
                  name: name,
                )
              : AramiscApi.getTeacherSubAttenSearchIndividualList(
                  classId: classId,
                  sectionId: sectionId,
                  rollINo: rollNo,
                  name: name,
                ),
          header: GlobalVariable.header);

      AdminClassAttenSearchIndividualResponseModel
          adminClassAttenSearchIndividualResponseModel =
          AdminClassAttenSearchIndividualResponseModel.fromJson(response);

      if (adminClassAttenSearchIndividualResponseModel.success == true) {
        isLoading.value = false;
        if (adminClassAttenSearchIndividualResponseModel
            .data!.students!.isNotEmpty) {
          for (int i = 0;
              i <
                  adminClassAttenSearchIndividualResponseModel
                      .data!.students!.length;
              i++) {
            adminStudentIndividualList.add(
                adminClassAttenSearchIndividualResponseModel
                    .data!.students![i]);
          }
        }
      } else {
        showBasicFailedSnackBar(
          message: adminClassAttenSearchIndividualResponseModel.message ??
              AppText.somethingWentWrong.tr,
        );
      }
    } catch (e, t) {
      isLoading.value = false;
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      isLoading.value = false;
    }

    return AdminClassAttenSearchIndividualResponseModel();
  }

  @override
  void onInit() {
    classId.value = Get.arguments['class_id'];
    sectionId.value = Get.arguments['section_id'];
    name.value = Get.arguments['name'];
    rollNo.value = Get.arguments['roll_no'];

    getAdminSearchIndividualStudentList(
        classId: classId.value,
        sectionId: sectionId.value,
        name: name.value,
        rollNo: rollNo.value);

    super.onInit();
  }
}
