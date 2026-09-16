import 'package:flutter/material.dart';

import '../app/theme/colors.dart';
import '../app/theme/text_styles.dart';

/// Marca Flowly: glifo de 4 barras (verde + ámbar) y wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  static const List<double> _barHeights = [11, 19, 26, 15];
  static const double _barWidth = 5;
  static const double _barGap = 2;
  static const double _barRadius = 1.5;

  @override
  Widget build(BuildContext context) {
    final bars = <Widget>[
      for (var i = 0; i < _barHeights.length; i++)
        Positioned(
          left: i * (_barWidth + _barGap),
          bottom: 0,
          child: Container(
            width: _barWidth,
            height: _barHeights[i],
            decoration: BoxDecoration(
              color: i == 2 ? AppColors.amber : AppColors.pine,
              borderRadius: BorderRadius.circular(_barRadius),
            ),
          ),
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 4 * _barWidth + 3 * _barGap,
          height: 26,
          child: Stack(alignment: Alignment.bottomCenter, children: bars),
        ),
        const SizedBox(width: 10),
        const Text('Flowly', style: AppTextStyles.wordmark),
      ],
    );
  }
}
