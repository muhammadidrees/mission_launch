import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/cache.dart';
import 'package:flutter/widgets.dart';
import 'package:mission_launch/audio/audio_manager.dart';
import 'package:mission_launch/gen/assets.gen.dart';

part 'preload_state.dart';

class PreloadCubit extends Cubit<PreloadState> {
  PreloadCubit(
    this.images,
    this.audio,
    this.context,
  ) : super(const PreloadState.initial());

  final Images images;
  final AudioCache audio;
  final BuildContext context;

  /// Load items sequentially allows display of what is being loaded
  Future<void> loadSequentially() async {
    final phases = [
      PreloadPhase(
        'manager',
        () => AudioManager.instance.preloadAssets(),
      ),
      PreloadPhase(
        'audio',
        () => audio.loadAll([
          Assets.audio.background,
          Assets.audio.effect,
          Assets.audio.asteriodHit,
          Assets.audio.asteriodExplode,
          Assets.audio.spaceshipShoot,
          Assets.audio.enemyExplode,
          Assets.audio.alienFlying,
          Assets.audio.alienShoot,
          Assets.audio.droneFlying,
          Assets.audio.alienShoot,
          Assets.audio.hit,
          Assets.audio.explosion,
          Assets.audio.success,
        ]),
      ),
      PreloadPhase(
        'images',
        () => images.loadAll([
          Assets.images.unicornAnimation.path,
          Assets.images.spaceshipIdle.path,
          Assets.images.spaceshipLeft.path,
          Assets.images.spaceshipRight.path,
          Assets.images.spaceshipBroken.path,
          Assets.images.asteroid1.path,
          Assets.images.asteroid2.path,
          Assets.images.asteroid3.path,
          Assets.images.drone.path,
          Assets.images.droneBroken.path,
          Assets.images.explode.path,
          Assets.images.alien.path,
          Assets.images.alienBroken.path,
          Assets.images.background1.path,
          Assets.images.background2.path,
          Assets.images.background3.path,
        ]),
      ),
      PreloadPhase(
        'static',
        () async {
          final images = [
            Assets.images.bossOffice.path,
            Assets.images.bossHappy.path,
            Assets.images.rocketWorkshop.path,
            Assets.images.goodNews.path,
            Assets.images.badNews.path,
            Assets.images.bacground.path,
          ];

          await Future.wait(
            images.map(
              (e) => precacheImage(AssetImage(e), context),
            ),
          );
        },
      ),
    ];

    await AudioManager.instance.initialize();

    emit(state.copyWith(totalCount: phases.length));
    for (final phase in phases) {
      emit(state.copyWith(currentLabel: phase.label));
      // Throttle phases to take at least 1/5 seconds
      await Future.wait([
        Future.delayed(Duration.zero, phase.start),
        Future<void>.delayed(const Duration(milliseconds: 200)),
      ]);
      emit(state.copyWith(loadedCount: state.loadedCount + 1));
    }
  }
}

@immutable
class PreloadPhase {
  const PreloadPhase(this.label, this.start);

  final String label;
  final ValueGetter<Future<void>> start;
}
