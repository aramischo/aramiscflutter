import 'package:flutter/material.dart';
import 'package:aramisc/app/data/constants/app_text.dart';
import 'package:aramisc/app/modules/admin_students_search/controllers/admin_students_search_controller.dart';
import 'package:aramisc/app/utilities/api_urls.dart';
import 'package:aramisc/app/utilities/message/snack_bars.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/domain/base_client/base_client.dart';
import 'package:aramisc/domain/core/model/teacher/teacher_academic_model/teacher_class_routine_list_response_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../routine/controllers/routine_controller.dart';

class TeSearchClassRoutineListController extends GetxController {
  AdminStudentsSearchController adminStudentsSearchController =
      Get.put(AdminStudentsSearchController());

  RxBool isLoading = false.obs;

  RxInt selectIndex =
      daysOfWeek.indexOf(DateFormat.E().format(DateTime.now())).obs;
  TabController? tabController;

  RxList<TeacherClassRoutines> teacherClassRoutineList =
      <TeacherClassRoutines>[].obs;

  // List<String> daysOfWeek = <String>[
  //   'Mon',
  //   'Tue',
  //   'Wed',
  //   'Thu',
  //   'Fri',
  //   'Sat',
  //   'Sun',
  // ];

  String formattedDate = DateFormat("dd MMMM yyyy").format(DateTime.now());
  // String today = DateFormat.E().format(DateTime.now());
  // void selectTab() {
  //   selectIndex.value = daysOfWeek.indexOf(today);
  // }

  Future<TeClassRoutineListResponseModel> getTeacherClassRoutineList(
      {required int classId, required int sectionId}) async {
    try {
      teacherClassRoutineList.clear();
      isLoading.value = true;

      final response = await BaseClient().getData(
        url: AramiscApi.getTeacherClassRoutineList(
            classId: classId, sectionId: sectionId),
        header: GlobalVariable.header,
      );

      TeClassRoutineListResponseModel teClassRoutineListResponseModel =
          TeClassRoutineListResponseModel.fromJson(response);

      if (teClassRoutineListResponseModel.success == true) {
        isLoading.value = false;
        if (teClassRoutineListResponseModel.data!.classRoutines!.isNotEmpty) {
          for (var element
              in teClassRoutineListResponseModel.data!.classRoutines!) {
            teacherClassRoutineList.add(element);
          }
        }
      } else {
        isLoading.value = false;
        showBasicFailedSnackBar(
          message: teClassRoutineListResponseModel.message ??
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

    return TeClassRoutineListResponseModel();
  }

  @override
  void onInit() {
    getTeacherClassRoutineList(
        classId: adminStudentsSearchController.studentClassId.value,
        sectionId: adminStudentsSearchController.studentSectionId.value);
    super.onInit();
  }
}
