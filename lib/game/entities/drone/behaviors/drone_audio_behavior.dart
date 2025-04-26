import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/game.dart';

/// A behavior that plays drone sound with basic immersive effects
class DroneAudioBehavior extends Behavior<Drone>
    with HasGameReference<MissionLaunch> {
  /// Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Flag to track if sound is currently playing
  bool _isPlaying = false;

  /// Base volume for the drone sound
  static const double _baseVolume = 0.4;

  /// How much the balance can be adjusted (0.0 to 1.0)
  static const double _maxBalance = 0.7;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _playSound();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Only update audio effects if the drone is active and sound is playing
    if (!parent.isDestroyed && _isPlaying) {
      _updateAudioEffects();
    }
  }

  @override
  void onRemove() {
    _stopSound();
    _audioPlayer.dispose();
    super.onRemove();
  }

  /// Plays the drone sound
  void _playSound() {
    if (!_isPlaying) {
      try {
        _audioPlayer
          ..play(
            AssetSource('audio/drone-flying.mp3'),
            volume: _baseVolume,
          )
          ..setReleaseMode(ReleaseMode.loop);
        _isPlaying = true;
      } catch (e) {
        log('Error playing drone sound: $e');
      }
    }
  }

  /// Stops the drone sound
  void _stopSound() {
    if (_isPlaying) {
      _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  /// Updates audio effects based on the drone's position
  void _updateAudioEffects() {
    if (!_isPlaying || game.size.x == 0) return;

    // Calculate horizontal position for stereo panning effect
    final screenWidth = game.size.x;
    final relativeX = parent.position.x / screenWidth;

    // Convert to balance value (-1.0 to 1.0)
    // Where -1.0 is fully left, 0.0 is center, 1.0 is fully right
    final balance = ((relativeX * 2) - 1) * _maxBalance;

    // Adjust volume based on vertical position (closer = louder)
    final distanceFromBottom = game.size.y - parent.position.y;
    final verticalFactor = distanceFromBottom / game.size.y;
    final adjustedVolume = _baseVolume * (0.7 + (verticalFactor * 0.3));

    // Apply the audio effects
    _audioPlayer
      ..setBalance(balance)
      ..setVolume(adjustedVolume);
  }
}
