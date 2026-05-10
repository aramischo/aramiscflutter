import 'package:flutter/cupertino.dart';
import 'package:aramisc/app/data/constants/app_text.dart';
import 'package:aramisc/app/utilities/api_urls.dart';
import 'package:aramisc/app/utilities/message/snack_bars.dart';
import 'package:aramisc/app/utilities/widgets/loader/loading.controller.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/domain/base_client/base_client.dart';
import 'package:aramisc/domain/core/model/teacher/teacher_academic_model/teacher_academic_subject_list_response_model.dart';
import 'package:get/get.dart';

class TeSubjectsController extends GetxController {
  LoadingController loadingController = Get.find();

  RxList<TeacherAcademicSubjectData> teacherSubjectList =
      <TeacherAcademicSubjectData>[].obs;

  Future<TeacherAcademicSubjectResponseModel> getTeacherSubjectList() async {
    try {
      teacherSubjectList.clear();
      loadingController.isLoading = true;

      final response = await BaseClient().getData(
          url: AramiscApi.getTeacherSubjectList, header: GlobalVariable.header);

      TeacherAcademicSubjectResponseModel teacherAcademicSubjectResponseModel =
          TeacherAcademicSubjectResponseModel.fromJson(response);

      if (teacherAcademicSubjectResponseModel.success == true) {
        loadingController.isLoading = false;

        if (teacherAcademicSubjectResponseModel.data!.isNotEmpty) {
          for (var element in teacherAcademicSubjectResponseModel.data!) {
            teacherSubjectList.add(element);
          }
        }
      } else {
        loadingController.isLoading = false;
        showBasicFailedSnackBar(
          message: teacherAcademicSubjectResponseModel.message ??
              AppText.somethingWentWrong.tr,
        );
      }
    } catch (e, t) {
      loadingController.isLoading = false;
      debugPrint('$e');
      debugPrint('$t');
    } finally {
      loadingController.isLoading = false;
    }

    return TeacherAcademicSubjectResponseModel();
  }

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTeacherSubjectList();
    });

    super.onInit();
  }
}
