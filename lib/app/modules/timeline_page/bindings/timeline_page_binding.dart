import 'package:get/get.dart';

import '../controllers/timeline_page_controller.dart';

class TimelinePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TimelinePageController>(
      TimelinePageController(),
    );
  }
}
