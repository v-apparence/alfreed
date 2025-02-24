import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

class ScreenSize {
  /// name this configuration
  String name;

  /// size configuration and pixel density
  double width, height, pixelDensity;

  ScreenSize(this.name, this.width, this.height, this.pixelDensity);
}

List<ScreenSize>? devicesScreenConfigs;

extension ScreenSizeManager on WidgetTester {
  Future<void> setScreenSize(ScreenSize screenSize) async {
    return this._setScreenSize(
        width: screenSize.width,
        height: screenSize.height,
        pixelDensity: screenSize.pixelDensity);
  }

  Future<void> _setScreenSize(
      {double width = 540,
      double height = 960,
      double pixelDensity = 1}) async {
    final size = Size(width, height);
    await this.binding.setSurfaceSize(size);
    this.binding.window.physicalSizeTestValue = size;
    this.binding.window.devicePixelRatioTestValue = pixelDensity;
  }

  // works for Iphone 11 max
  Future<void> setIphone11Max() =>
      this._setScreenSize(width: 414, height: 896, pixelDensity: 3);

  // works for iphones size : 6+, 6s, 7+, 8+
  Future<void> setIphone8Plus() =>
      this._setScreenSize(width: 414, height: 736, pixelDensity: 3);

  Future<void> setWeb1920() =>
      this._setScreenSize(width: 1920, height: 1200, pixelDensity: 3);

  Future<void> setWeb1280() =>
      this._setScreenSize(width: 1280, height: 1024, pixelDensity: 3);

  Future<void> setTablet() =>
      this._setScreenSize(width: 750, height: 400, pixelDensity: 3);
}
