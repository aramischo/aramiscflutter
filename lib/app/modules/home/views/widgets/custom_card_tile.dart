import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aramisc/app/utilities/extensions/widget.extensions.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_dimens.dart';
import '../../../../data/constants/app_text_style.dart';
import '../../../../utilities/widgets/common_widgets/custom_divider.dart';

class CustomCardTile extends StatelessWidget {
  final String icon;
  final String title;
  final Color? iconColor;
  final bool isSelected;
  final Function() onTap;
  final double? height;
  final double? width;

  const CustomCardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.iconColor,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        height: height ?? 60.h,   // utilise le paramètre, sinon valeur par défaut
        width: width ?? 60.w,
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.cardColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: AppColors.boxBorderColor,
            ),
            borderRadius: BorderRadius.circular(AppDimens.radius5.w),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: ShapeDecoration(
                    color: isSelected ? Colors.white : AppColors.smallCardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radius3.w),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      icon,
                      height: 30.w,
                      // width: 35,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              5.w.verticalSpacing,
              CustomDivider(
                height: 1,
                width: 110.w,
              ),
              7.w.verticalSpacing,
              Text(
                title.toUpperCase(),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: isSelected
                    ? AppTextStyle.cardTextStyle14WhiteW500
                    : AppTextStyle.cardTextStyle14PurpleW500,
              )
            ],
          ),
        ),
      ),
    );
  }
}
