// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:mission_launch/gen/assets.gen.dart';

/// A singleton audio manager that handles sound effects and background music
class AudioManager {
  /// Private constructor
  AudioManager._();

  /// The singleton instance
  static final AudioManager _instance = AudioManager._();

  /// Returns the singleton instance
  static AudioManager get instance => _instance;

  /// Background music player
  final AudioPlayer _bgmPlayer = AudioPlayer();

  /// Sound effect player for longer effects that don't need pools
  final AudioPlayer _effectPlayer = AudioPlayer();

  /// Audio pools for short, frequently used sound effects
  late final AudioPool _asteroidHitPool;
  late final AudioPool _asteroidExplodePool;
  late final AudioPool _spaceshipShootPool;
  late final AudioPool _enemyExplodePool;
  late final AudioPool _alienShootPool;
  late final AudioPool _droneShootPool;
  late final AudioPool _hitPool;
  late final AudioPool _dronePool;

  /// Audio stream players for continuous sounds
  late final AudioPlayer _alienFlyingPlayer;
  late final AudioPlayer _droneFlyingPlayer;

  /// Indicates if sound is enabled
  bool _soundEnabled = true;

  /// Indicates if music is enabled
  bool _musicEnabled = true;

  /// Get sound enabled state
  bool get isSoundEnabled => _soundEnabled;

  /// Get music enabled state
  bool get isMusicEnabled => _musicEnabled;

  /// Current music volume from 0.0 to 1.0
  double _musicVolume = 0.5;

  /// Current sound effects volume from 0.0 to 1.0
  double _soundVolume = 0.7;

  /// Initialize the audio manager
  Future<void> initialize() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _effectPlayer.setReleaseMode(ReleaseMode.release);

    // Initialize stream players
    _alienFlyingPlayer = AudioPlayer();
    _droneFlyingPlayer = AudioPlayer();

    await _alienFlyingPlayer.setReleaseMode(ReleaseMode.loop);
    await _droneFlyingPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Preload all audio assets
  Future<void> preloadAssets() async {
    // Create audio pools with appropriate max simultaneous sounds
    _asteroidHitPool = await AudioPool.create(
      source: AssetSource(Assets.audio.asteriodHit.replaceAll('assets/', '')),
      maxPlayers: 6,
    )
      ..start(volume: 0);

    _asteroidExplodePool = await AudioPool.create(
      source:
          AssetSource(Assets.audio.asteriodExplode.replaceAll('assets/', '')),
      maxPlayers: 4,
    )
      ..start(volume: 0);

    _spaceshipShootPool = await AudioPool.create(
      source:
          AssetSource(Assets.audio.spaceshipShoot.replaceAll('assets/', '')),
      maxPlayers: 8,
    )
      ..start(volume: 0);

    _enemyExplodePool = await AudioPool.create(
      source: AssetSource(Assets.audio.enemyExplode.replaceAll('assets/', '')),
      maxPlayers: 6,
    )
      ..start(volume: 0);

    _alienShootPool = await AudioPool.create(
      source: AssetSource(Assets.audio.alienShoot.replaceAll('assets/', '')),
      maxPlayers: 10,
    )
      ..start(volume: 0);

    _hitPool = await AudioPool.create(
      source: AssetSource(Assets.audio.hit.replaceAll('assets/', '')),
      maxPlayers: 8,
    )
      ..start(volume: 0);

    _dronePool = await AudioPool.create(
      source: AssetSource(Assets.audio.droneFlying.replaceAll('assets/', '')),
      maxPlayers: 4,
    )
      ..start(volume: 0);

    _droneShootPool = await AudioPool.create(
      source: AssetSource(Assets.audio.droneShoot.replaceAll('assets/', '')),
      maxPlayers: 4,
    )
      ..start(volume: 0);

    // Pre-cache other audio files
    await FlameAudio.audioCache.loadAll([
      Assets.audio.asteriodHit,
      Assets.audio.asteriodExplode,
      Assets.audio.spaceshipShoot,
      Assets.audio.enemyExplode,
      Assets.audio.alienShoot,
      Assets.audio.hit,
      Assets.audio.droneFlying,
      Assets.audio.droneShoot,
      Assets.audio.background,
      Assets.audio.effect,
      Assets.audio.alienFlying,
    ]);
  }

  /// Play background music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;

    await _bgmPlayer.stop();
    await _bgmPlayer.setVolume(_musicVolume);
    await _bgmPlayer.setSource(AssetSource(Assets.audio.background));
    await _bgmPlayer.resume();
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _bgmPlayer.stop();
  }

  /// Play asteroid hit sound
  void playAsteroidHit() {
    if (!_soundEnabled) return;
    _asteroidHitPool.start(volume: _soundVolume);
  }

  /// Play asteroid explode sound
  void playAsteroidExplode() {
    if (!_soundEnabled) return;
    _asteroidExplodePool.start(volume: _soundVolume);
  }

  /// Play spaceship shoot sound
  void playSpaceshipShoot() {
    if (!_soundEnabled) return;
    _spaceshipShootPool.start(volume: _soundVolume);
  }

  /// Play enemy explode sound
  void playEnemyExplode() {
    if (!_soundEnabled) return;
    _enemyExplodePool.start(volume: _soundVolume);
  }

  /// Play alien shoot sound
  void playAlienShoot() {
    if (!_soundEnabled) return;
    _alienShootPool.start(volume: _soundVolume);
  }

  /// Play drone shoot sound
  void playDroneShoot() {
    if (!_soundEnabled) return;
    _droneShootPool.start(volume: _soundVolume);
  }

  /// Play hit sound
  void playHit() {
    if (!_soundEnabled) return;
    _hitPool.start(volume: _soundVolume);
  }

  /// Play drone sound
  void playDrone() {
    if (!_soundEnabled) return;
    _dronePool.start(volume: _soundVolume);
  }

  /// Play alien flying sound (continuous)
  Future<void> startAlienFlying() async {
    if (!_soundEnabled) return;
    await _alienFlyingPlayer.stop();
    await _alienFlyingPlayer.setVolume(_soundVolume * 0.6);
    await _alienFlyingPlayer.setSource(AssetSource(Assets.audio.alienFlying));
    await _alienFlyingPlayer.resume();
  }

  /// Stop alien flying sound
  Future<void> stopAlienFlying() async {
    await _alienFlyingPlayer.stop();
  }

  /// Play drone flying sound (continuous)
  Future<void> startDroneFlying() async {
    if (!_soundEnabled) return;
    await _droneFlyingPlayer.stop();
    await _droneFlyingPlayer.setVolume(_soundVolume * 0.5);
    await _droneFlyingPlayer.setSource(AssetSource(Assets.audio.droneFlying));
    await _droneFlyingPlayer.resume();
  }

  /// Stop drone flying sound
  Future<void> stopDroneFlying() async {
    await _droneFlyingPlayer.stop();
  }

  /// Play a generic effect sound
  Future<void> playEffect() async {
    if (!_soundEnabled) return;
    await _effectPlayer.stop();
    await _effectPlayer.setVolume(_soundVolume * 1.2);
    await _effectPlayer.setSource(AssetSource(Assets.audio.effect));
    await _effectPlayer.resume();
  }

  /// Set sound enabled state
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (!enabled) {
      _alienFlyingPlayer.stop();
      _droneFlyingPlayer.stop();
    }
  }

  /// Set music enabled state
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _bgmPlayer.stop();
    } else {
      playBackgroundMusic();
    }
  }

  /// Set sound volume
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_musicVolume);
  }

  /// Dispose all audio resources
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _effectPlayer.dispose();
    await _alienFlyingPlayer.dispose();
    await _droneFlyingPlayer.dispose();
  }
}
