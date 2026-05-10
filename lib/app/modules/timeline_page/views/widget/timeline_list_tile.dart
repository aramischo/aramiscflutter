import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:aramisc/app/data/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/core/model/timeline/Timeline.dart';

class TimeLineView extends StatelessWidget {
  final String progress;
  final Timeline timeline;

  final Function() onDownloadTap;

  const TimeLineView(
      {super.key,
      required this.progress,
      required this.timeline,
      required this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: Colors.deepPurple.shade300,
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),
            // Content card
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                  border: Border.all(color: Colors.deepPurple.shade50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            timeline.title ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.deepPurple.shade700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Date chip
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13.sp, color: Colors.deepPurple.shade300),
                        SizedBox(width: 4.w),
                        Text(
                          formatDate(timeline.date ?? ''),
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.deepPurple.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Divider(
                        color: Colors.deepPurple.shade50,
                        thickness: 1,
                        height: 1),
                    SizedBox(height: 10.h),
                    // Description
                    Text(
                      timeline.description??"",
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                    ),
                    // Download button
                    if (timeline.file != null && timeline.file != "")
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: InkWell(
                          onTap: onDownloadTap,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border:
                                  Border.all(color: Colors.deepPurple.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: Colors.deepPurple.shade600,
                                    size: 18.sp),
                                SizedBox(width: 6.w),
                                Text(
                                  "Download".tr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontSize: 13.sp,
                                        color: Colors.deepPurple.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMMM, yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }
}
