/// Canonical device profile for this project.
///
/// Primary dev device: generic Medium Phone (1080×2400, no display cutout).
abstract final class DeviceConfig {
  static const avdId = 'generic_phone';
  static const avdName = 'Generic Phone (Medium Phone)';

  /// Figma / React redesign canvas size.
  static const designWidth = 390.0;
  static const designHeight = 844.0;
}
