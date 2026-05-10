import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:aramisc/app/modules/timeline_page/views/widget/timeline_list_tile.dart';

import '../../../../config/app_config.dart';
import '../../../data/constants/app_text.dart';
import '../../../utilities/widgets/common_widgets/alert_dialog.dart';
import '../../../utilities/widgets/common_widgets/custom_background.dart';
import '../../../utilities/widgets/common_widgets/custom_scaffold_widget.dart';
import '../../../utilities/widgets/no_data_available/no_data_available_widget.dart';
import '../../../utilities/widgets/permission_check/permission_check.dart';
import '../controllers/timeline_page_controller.dart';

class TimelinePageView extends GetView<TimelinePageController> {
  const TimelinePageView({super.key});
  @override
  Widget build(BuildContext context) {
    return AramiscEduScaffold(
      title: 'Timeline'.tr,
      body: CustomBackground(
        customWidget: Column(
          children: [

            20.verticalSpace,

            Expanded(
                child: Obx((){

                  if(controller.isLoading.value){
                    return const Center(child: CircularProgressIndicator());
                  }else if(controller.timelines.isEmpty){
                    return const Center(child: NoDataAvailableWidget());
                  }else{
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.timelines.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final timeline = controller.timelines[index];
                        return TimeLineView(
                          progress: "",
                          timeline: timeline,

                          onDownloadTap: ()async {
                            await PermissionCheck()
                                .checkPermissions(Get.context!);
                            Get.dialog(
                              CustomPopupDialogue(
                                onYesTap: () {
                                  Get.back();

                                  controller.fileDownload(
                                      url: "${AppConfig.domainName}/${timeline.file}",
                                      title: timeline.title ?? '');
                                },
                                title: 'Confirmation'.tr,
                                subTitle: AppText.downloadMessage.tr,
                                noText: 'No'.tr,
                                yesText: 'Download'.tr,
                              ),
                            );
                          }
                        );
                      },
                    );
                  }


                })
            ),

            20.verticalSpace,


          ],
        ),
      ),
    );
  }
}
