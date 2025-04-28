import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/config/game_config.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/l10n/l10n.dart';
import 'package:mission_launch/loading/cubit/cubit.dart';
import 'package:mission_launch/rocket_workshop/cubit/rocket_workshop_cubit.dart';
import 'package:nes_ui/nes_ui.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const GamePage());
  }

  @override
  Widget build(BuildContext context) {
    final rocketWorkshopState = context.read<RocketWorkshopCubit>().state;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return AudioCubit(audioCache: context.read<PreloadCubit>().audio);
          },
        ),
        BlocProvider(
          create: (context) => GameBloc(
            config: GameConfig.normal().copyWith(
              totalMissionDuration: 600 - (rocketWorkshopState.speed * 25.0),
              maxDrones: rocketWorkshopState.speed + 6,
              maxAliens: rocketWorkshopState.speed + 4,
              maxAsteroids: rocketWorkshopState.health + 5,
              maxRocketHealth: rocketWorkshopState.health,
              maxRocketSpeed: (rocketWorkshopState.speed * 25.0) + 160,
              coolBulletCooldown: rocketWorkshopState.bulletSpeed / 10,
            ),
          ),
        ),
      ],
      child: const Scaffold(body: SafeArea(child: GameView())),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, this.game});

  final FlameGame? game;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  FlameGame? _game;

  late final Bgm bgm;

  @override
  void initState() {
    super.initState();
    bgm = context.read<AudioCubit>().bgm;
    // bgm.play(Assets.audio.background);
  }

  @override
  void dispose() {
    bgm.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white,
          fontSize: 4,
        );

    _game ??= widget.game ??
        MissionLaunch(
          l10n: context.l10n,
          effectPlayer: context.read<AudioCubit>().effectPlayer,
          textStyle: textStyle,
          images: context.read<PreloadCubit>().images,
          gameBloc: context.read<GameBloc>(),
        );
    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(
            game: _game!,
            overlayBuilderMap: {
              'game_over': (context, game) => const GameOverOverlay(),
              'success': (context, game) => const SuccessOverlay(),
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: BlocBuilder<AudioCubit, AudioState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.volume == 0 ? Icons.volume_off : Icons.volume_up,
                ),
                onPressed: () => context.read<AudioCubit>().toggleVolume(),
              );
            },
          ),
        ),
        Align(
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.progressPercent}%',
                      style: TextTheme.of(context).displayLarge!.copyWith(
                            color: Colors.white.withOpacity(0.4),
                          ),
                    ),
                    Text(
                      '${state.rocketHealth} / ${state.maxRocketHealth}',
                      style: TextTheme.of(context).displayLarge!.copyWith(
                            color: Colors.white.withOpacity(0.4),
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: NesBlinker(
              child: Text(
                'Mission Failed',
                style: TextTheme.of(context).displayLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessOverlay extends StatelessWidget {
  const SuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: NesBlinker(
              child: Text(
                'Mission Successful',
                style: TextTheme.of(context).displayLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
