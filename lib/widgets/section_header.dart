import 'package:flutter/material.dart';
import '../utils/utils.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({
    Key? key,
    required this.title,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.paddingS),
            ],
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        Container(
          height: 2,
          width: 100,
          color: AppColors.primary,
        ),
      ],
    );
  }
}
