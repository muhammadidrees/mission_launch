import 'package:audioplayers/audioplayers.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:mission_launch/game/entities/drone/drone.dart';

/// A simplified behavior that plays drone sound to test basic audio functionality
class DroneAudioBehavior extends Behavior<Drone> {
  /// Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Flag to track if sound is currently playing
  bool _isPlaying = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Simple sound test - play the effect with basic settings
    _playSound();
  }

  @override
  void onRemove() {
    _stopSound();
    _audioPlayer.dispose();
    super.onRemove();
  }

  /// Simple method to play the drone sound
  void _playSound() {
    if (!_isPlaying) {
      try {
        print('Attempting to play drone sound');

        // Use a direct string path instead of Assets class to test
        _audioPlayer.play(
          AssetSource('audio/drone-flying.mp3'),
          volume: 0.5,
        );

        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _isPlaying = true;

        print('Sound play command issued successfully');
      } catch (e) {
        print('Error playing drone sound: $e');
      }
    }
  }

  /// Stop the sound when the drone is removed
  void _stopSound() {
    if (_isPlaying) {
      _audioPlayer.stop();
      _isPlaying = false;
    }
  }
}
