/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsAudioGen {
  const $AssetsAudioGen();

  /// File path: assets/audio/alien-flying.mp3
  String get alienFlying => 'assets/audio/alien-flying.mp3';

  /// File path: assets/audio/alien-shoot.mp3
  String get alienShoot => 'assets/audio/alien-shoot.mp3';

  /// File path: assets/audio/asteriod-explode.mp3
  String get asteriodExplode => 'assets/audio/asteriod-explode.mp3';

  /// File path: assets/audio/asteriod-hit.mp3
  String get asteriodHit => 'assets/audio/asteriod-hit.mp3';

  /// File path: assets/audio/background.mp3
  String get background => 'assets/audio/background.mp3';

  /// File path: assets/audio/drone-flying.mp3
  String get droneFlying => 'assets/audio/drone-flying.mp3';

  /// File path: assets/audio/drone-shoot.mp3
  String get droneShoot => 'assets/audio/drone-shoot.mp3';

  /// File path: assets/audio/effect.mp3
  String get effect => 'assets/audio/effect.mp3';

  /// File path: assets/audio/enemy-explode.mp3
  String get enemyExplode => 'assets/audio/enemy-explode.mp3';

  /// File path: assets/audio/hit.wav
  String get hit => 'assets/audio/hit.wav';

  /// File path: assets/audio/spaceship-shoot.mp3
  String get spaceshipShoot => 'assets/audio/spaceship-shoot.mp3';

  /// List of all assets
  List<String> get values => [
    alienFlying,
    alienShoot,
    asteriodExplode,
    asteriodHit,
    background,
    droneFlying,
    droneShoot,
    effect,
    enemyExplode,
    hit,
    spaceshipShoot,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/alien-broken.png
  AssetGenImage get alienBroken =>
      const AssetGenImage('assets/images/alien-broken.png');

  /// File path: assets/images/alien.png
  AssetGenImage get alien => const AssetGenImage('assets/images/alien.png');

  /// File path: assets/images/asteroid-1.png
  AssetGenImage get asteroid1 =>
      const AssetGenImage('assets/images/asteroid-1.png');

  /// File path: assets/images/asteroid-2.png
  AssetGenImage get asteroid2 =>
      const AssetGenImage('assets/images/asteroid-2.png');

  /// File path: assets/images/asteroid-3.png
  AssetGenImage get asteroid3 =>
      const AssetGenImage('assets/images/asteroid-3.png');

  /// File path: assets/images/drone-broken.png
  AssetGenImage get droneBroken =>
      const AssetGenImage('assets/images/drone-broken.png');

  /// File path: assets/images/drone.png
  AssetGenImage get drone => const AssetGenImage('assets/images/drone.png');

  /// File path: assets/images/explode.png
  AssetGenImage get explode => const AssetGenImage('assets/images/explode.png');

  /// File path: assets/images/spaceship-broken.png
  AssetGenImage get spaceshipBroken =>
      const AssetGenImage('assets/images/spaceship-broken.png');

  /// File path: assets/images/spaceship-left.png
  AssetGenImage get spaceshipLeft =>
      const AssetGenImage('assets/images/spaceship-left.png');

  /// File path: assets/images/spaceship-right.png
  AssetGenImage get spaceshipRight =>
      const AssetGenImage('assets/images/spaceship-right.png');

  /// File path: assets/images/spaceship_idle.png
  AssetGenImage get spaceshipIdle =>
      const AssetGenImage('assets/images/spaceship_idle.png');

  /// File path: assets/images/unicorn_animation.png
  AssetGenImage get unicornAnimation =>
      const AssetGenImage('assets/images/unicorn_animation.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    alienBroken,
    alien,
    asteroid1,
    asteroid2,
    asteroid3,
    droneBroken,
    drone,
    explode,
    spaceshipBroken,
    spaceshipLeft,
    spaceshipRight,
    spaceshipIdle,
    unicornAnimation,
  ];
}

class $AssetsLicensesGen {
  const $AssetsLicensesGen();

  /// Directory path: assets/licenses/poppins
  $AssetsLicensesPoppinsGen get poppins => const $AssetsLicensesPoppinsGen();
}

class $AssetsLicensesPoppinsGen {
  const $AssetsLicensesPoppinsGen();

  /// File path: assets/licenses/poppins/OFL.txt
  String get ofl => 'assets/licenses/poppins/OFL.txt';

  /// List of all assets
  List<String> get values => [ofl];
}

class Assets {
  const Assets._();

  static const $AssetsAudioGen audio = $AssetsAudioGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLicensesGen licenses = $AssetsLicensesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
