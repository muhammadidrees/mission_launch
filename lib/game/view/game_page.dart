// ignore_for_file: lines_longer_than_80_chars

import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_launch/boss_office/view/view.dart';
import 'package:mission_launch/game/bloc/bloc.dart';
import 'package:mission_launch/game/config/game_config.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';
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
              totalMissionDuration: 500 - (rocketWorkshopState.speed * 25.0),
              // totalMissionDuration: 10,
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
    // AudioManager.instance.playBackgroundMusic();
    bgm = context.read<AudioCubit>().bgm;
    bgm.play(Assets.audio.background, volume: 0.5);
  }

  @override
  void dispose() {
    // AudioManager.instance.stopBackgroundMusic();
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
              'game_over': (context, game) => BlocProvider<GameBloc>.value(
                    value: context.read<GameBloc>(),
                    child: const GameOverOverlay(),
                  ),
              'success': (context, game) => BlocProvider<GameBloc>.value(
                    value: context.read<GameBloc>(),
                    child: const SuccessOverlay(),
                  ),
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
          alignment: Alignment.topLeft,
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: HealthIndicator(
                  currentHealth: state.rocketHealth,
                  maxHealth: state.maxRocketHealth,
                ),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: BlocBuilder<GameBloc, GameState>(
            builder: (context, state) {
              return VerticalProgressIndicator(
                progress: state.progress,
                progressColor: state.phaseColor,
              );
            },
          ),
        ),
      ],
    );
  }
}

class VerticalProgressIndicator extends StatelessWidget {
  const VerticalProgressIndicator({
    required this.progress,
    super.key,
    this.height = 500.0,
    this.width = 28.0,
    this.backgroundColor = Colors.blueGrey,
    this.progressColor = Colors.blueAccent,
    this.borderRadius = 8.0,
  });

  final double progress;
  final double height;
  final double width;
  final Color backgroundColor;
  final Color progressColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Assets.images.moon.path, height: 32),
          const SizedBox(height: 8),
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: height * progress,
                    width: width,
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(borderRadius - 2),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (index) => Container(
                          height: 2,
                          width: width - 10,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(Assets.images.earth.path, height: 40),
        ],
      ),
    );
  }
}

class HealthIndicator extends StatelessWidget {
  const HealthIndicator({
    required this.currentHealth,
    required this.maxHealth,
    super.key,
  });

  final int currentHealth;
  final int maxHealth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        maxHealth,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: NesIcon(
            iconData: NesIcons.heart,
            primaryColor: index < currentHealth ? Colors.red : Colors.blueGrey,
            size: const Size(32, 32),
          ),
        ),
      ),
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
                'Mission Failed!',
                style: TextTheme.of(context).displayLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          NesButton.text(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(NewsRoom.route(context.read<GameBloc>()));
            },
            text: 'Continue',
            type: NesButtonType.primary,
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
                'Mission Successful!',
                style: TextTheme.of(context).displayLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          NesButton.text(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(NewsRoom.route(context.read<GameBloc>()));
            },
            text: 'Continue',
            type: NesButtonType.primary,
          ),
        ],
      ),
    );
  }
}

class NewsRoom extends StatelessWidget {
  const NewsRoom({super.key});

  static Route<void> route(GameBloc gameBloc) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<GameBloc>.value(
        value: gameBloc,
        child: const NewsRoom(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const NewsRoomView();
  }
}

class NewsRoomView extends StatelessWidget {
  const NewsRoomView({super.key});

  List<String> successDialogs(String playerName) => [
        'BREAKING NEWS!',
        'PASA becomes the first private company to land a rocket on the Moon!',
        'Celebrations erupt worldwide as $playerName is hailed as a pioneer.',
        'However, some conspiracy theorists already claim it was all CGI.',
        'One old man claims he saw wires holding the rocket in one of the pictures.',
        'But we know the truth: $playerName is a hero!',
        "PASA's next mission is to Mars, and we are sure $playerName will be the one to lead it.",
      ];

  List<String> failureDialogs(String playerName) => [
        'BREAKING NEWS!',
        'PASA fails to land a rocket on the Moon.',
        'The mission was a disaster, and $playerName is being blamed.',
        'The company is facing severe backlash from investors and the public.',
        'PASA employees were seen applying for jobs at fast food chains.',
      ];

  List<String> normalDialogs(String playerName) => [
        'BREAKING NEWS!',
        'Another rocket touched down today — yawn.',
        'Everyone seems to be going to the Moon these days.',
        'CEO of PASA says he had high hopes for $playerName.',
        "Whos's official comment is: 'At least I made it.'",
      ];

  @override
  Widget build(BuildContext context) {
    final playerName = context.read<RocketWorkshopCubit>().state.playerName;
    final game = context.read<GameBloc>().state;

    if (game.isGameOver) {
      return InterpretorWidget(
        image: Assets.images.badNews.path,
        dialogs: failureDialogs(playerName),
        showSkipButton: false,
        onNextButtonPressed: () async => NesDialog.show(
          context: context,
          builder: (_) {
            return Text(
              'Thanks for playing! $playerName\nPlease reload the page to play again.',
              style: TextTheme.of(context).bodyLarge,
            );
          },
        ),
        nextButtonText: 'The End',
      );
    }

    if (game.missionComplete && game.config.maxRocketSpeed > 280) {
      return InterpretorWidget(
        image: Assets.images.goodNews.path,
        dialogs: successDialogs(playerName),
        showSkipButton: false,
        onNextButtonPressed: () async => NesDialog.show(
          context: context,
          builder: (_) {
            return Text(
              'Thanks for playing! $playerName\nPlease reload the page to play again.',
              style: TextTheme.of(context).bodyLarge,
            );
          },
        ),
        nextButtonText: 'The End',
      );
    }
    return InterpretorWidget(
      image: Assets.images.normalNews.path,
      dialogs: normalDialogs(playerName),
      showSkipButton: false,
      onNextButtonPressed: () async => NesDialog.show(
        context: context,
        builder: (_) {
          return Text(
            'Thanks for playing! $playerName\nPlease reload the page to play again.',
            style: TextTheme.of(context).bodyLarge,
          );
        },
      ),
      nextButtonText: 'The End',
    );
  }
}
