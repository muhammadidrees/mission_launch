import 'dart:ui';

import 'package:flame/components.dart';

/// {@template hit_effect_component}
/// A component that creates a visual hit effect on an entity.
/// It briefly changes the entity color to white to indicate damage.
/// {@endtemplate}
class HitEffectComponent extends Component {
  /// {@macro hit_effect_component}
  HitEffectComponent({
    this.duration = 0.1,
    this.flashColor = const Color(0xFFFFFFFF),
  });

  /// The duration of the flash effect in seconds
  final double duration;

  /// The color to flash when hit
  final Color flashColor;

  /// The elapsed time since the effect started
  double _elapsedTime = 0;

  /// Whether the effect has been initialized
  bool _initialized = false;

  @override
  void update(double dt) {
    if (!_initialized) {
      _initialize();
    }

    _elapsedTime += dt;

    // Flash intensity based on remaining time
    final progress = _elapsedTime / duration;
    if (progress < 1.0) {
      // Calculate flash intensity - start strong, then fade out
      final intensity = 1.0 - progress;

      // Apply to all sprite components in the parent
      for (final component
          in parent!.children.whereType<SpriteAnimationComponent>()) {
        component.paint.colorFilter = ColorFilter.mode(
          flashColor.withOpacity(intensity * 0.7),
          BlendMode.srcATop,
        );
      }

      for (final component in parent!.children.whereType<SpriteComponent>()) {
        component.paint.colorFilter = ColorFilter.mode(
          flashColor.withOpacity(intensity * 0.7),
          BlendMode.srcATop,
        );
      }
    } else {
      // Restore original appearance and remove this component
      _restoreOriginal();
      removeFromParent();
    }

    super.update(dt);
  }

  /// Initialize the effect by capturing original paint state
  void _initialize() {
    _initialized = true;
    _elapsedTime = 0.0;
  }

  /// Restore the original appearance
  void _restoreOriginal() {
    // Remove any color filters we applied
    for (final component
        in parent!.children.whereType<SpriteAnimationComponent>()) {
      component.paint.colorFilter = null;
    }

    for (final component in parent!.children.whereType<SpriteComponent>()) {
      component.paint.colorFilter = null;
    }
  }
}
