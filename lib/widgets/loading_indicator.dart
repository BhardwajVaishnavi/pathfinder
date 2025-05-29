import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart'; // Removed for build
import '../utils/utils.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = AppColors.primary,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              message!,
              style: AppTextStyles.subtitle2.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
