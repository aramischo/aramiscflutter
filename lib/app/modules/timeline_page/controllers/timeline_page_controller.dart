import 'dart:developer';
import 'package:get/get.dart';
import 'package:aramisc/app/utilities/widgets/loader/loading.controller.dart';
import '../../../../config/global_variable/global_variable_controller.dart';
import '../../../../domain/base_client/base_client.dart';
import '../../../../domain/core/model/timeline/Timeline.dart';
import '../../../utilities/api_urls.dart';
import '../../../utilities/file_downloader/file_download_utils.dart';
import '../../../utilities/message/snack_bars.dart';

class TimelinePageController extends GetxController {

  final count = 0.obs;
  @override
  void onInit() {
    getAllSubjectList();
    super.onInit();
  }

  GlobalRxVariableController globalRxVariableController = Get.find();

  RxBool isLoading = false.obs;

  RxList<Timeline> timelines = <Timeline>[].obs;


  void getAllSubjectList() async {

    log("timelineList ::: :::: call");
  
    try {
      isLoading.value = true;

      final response = await BaseClient().getData(
        url: AramiscApi.getStudentTimeline(globalRxVariableController.studentRecordId.value),
        header: GlobalVariable.header,
      );

      TimelineList timelineList = TimelineList.fromJson(response);

      timelines.value = timelineList.timelines;
      
      log("timelineList ::: ${timelineList.timelines.length}");
     
    } catch (e, t) {
      log('$e');
      log('$t');
    } finally {
      isLoading.value = false;
    }
  }



  void fileDownload({required String url, required String title}) {
    url == '' ? showBasicFailedSnackBar(message: 'No File Available'.tr,) : FileDownloadUtils().downloadFiles(url: url, title: title);
  }

  
}
