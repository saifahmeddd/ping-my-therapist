import 'package:flutter/material.dart';

import 'package:ping_my_therapist/core/device/device_config.dart';

/// Scales spacing and sizes from the 390×844 design canvas to the current screen.
extension DeviceLayout on BuildContext {
  Size get layoutSize => MediaQuery.sizeOf(this);

  double get layoutWidthScale =>
      (layoutSize.width / DeviceConfig.designWidth).clamp(0.9, 1.12);

  double get layoutHeightScale =>
      (layoutSize.height / DeviceConfig.designHeight).clamp(0.9, 1.12);

  /// Horizontal scale (padding, widths, radii tied to width).
  double w(double designValue) => designValue * layoutWidthScale;

  /// Vertical scale (heights, vertical spacing).
  double h(double designValue) => designValue * layoutHeightScale;

  EdgeInsets insets({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.fromLTRB(w(left), h(top), w(right), h(bottom));
  }

  EdgeInsets symmetricInsets({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: w(horizontal), vertical: h(vertical));
  }

  BorderRadius radius(double designRadius) {
    final scaled = w(designRadius);
    return BorderRadius.circular(scaled);
  }
}
