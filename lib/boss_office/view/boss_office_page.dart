// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_launch/gen/assets.gen.dart';
import 'package:mission_launch/rocket_workshop/rocket_workshop.dart';
import 'package:nes_ui/nes_ui.dart';

class BossOfficePage extends StatelessWidget {
  const BossOfficePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const BossOfficePage());
  }

  @override
  Widget build(BuildContext context) {
    return const BossOfficeView();
  }
}

class BossOfficeView extends StatelessWidget {
  const BossOfficeView({super.key});

  @override
  Widget build(BuildContext context) {
    final playerName = context.read<RocketWorkshopCubit>().state.playerName;
    return InterpretorWidget(
      image: Assets.images.bossOffice.path,
      dialogs: [
        'Asalam o Alaikum, $playerName!',
        'Welcome to PASA — a company built with love and passion for space exploration.',
        'I started PASA for my daughter, KAKA. She dreams of rockets and reaching the stars — and I want to make that dream a reality.',
        "That's why this mission is so important, $playerName. I want our company to be the FIRST to reach the Moon!",
        'But... we are running on a **very tight budget**, so you must build carefully.',
        "And it won't be easy — rival companies are sending **drones** to sabotage us.",
        'There are also asteroids... and some even whisper about **aliens** in deep space.',
        'Stay sharp, plan smart, and make us proud.\nGood luck, $playerName. KAKA and I are counting on you!',
      ],
      onNextButtonPressed: () {
        Navigator.of(context)
            .pushReplacement<void, void>(RocketWorkshopPage.route());
      },
      nextButtonText: 'Go to the rocket workshop',
    );
  }
}

class InterpretorWidget extends StatefulWidget {
  const InterpretorWidget({
    required this.image,
    required this.dialogs,
    required this.onNextButtonPressed,
    required this.nextButtonText,
    this.showSkipButton = true,
    this.isFullScreen = true,
    super.key,
  });

  final String image;
  final List<String> dialogs;
  final String nextButtonText;
  final VoidCallback onNextButtonPressed;
  final bool showSkipButton;
  final bool isFullScreen;

  @override
  State<InterpretorWidget> createState() => _InterpretorWidgetState();
}

class _InterpretorWidgetState extends State<InterpretorWidget> {
  int currentDialogIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.isFullScreen
        ? Column(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(widget.image, fit: BoxFit.cover),
                ),
              ),
              Expanded(
                child: NesContainer(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: NesRunningText(
                            speed: 0.03,
                            text: widget.dialogs[currentDialogIndex],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          if (widget.showSkipButton) ...[
                            NesButton.text(
                              type: NesButtonType.normal,
                              onPressed: () {
                                widget.onNextButtonPressed();
                              },
                              text: 'Skip',
                            ),
                            const SizedBox(width: 16),
                          ],
                          NesButton.text(
                            type: NesButtonType.primary,
                            onPressed: () {
                              if (currentDialogIndex <
                                  widget.dialogs.length - 1) {
                                setState(() {
                                  currentDialogIndex++;
                                });
                              } else {
                                widget.onNextButtonPressed();
                              }
                            },
                            text: currentDialogIndex < widget.dialogs.length - 1
                                ? 'Next'
                                : widget.nextButtonText,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : SizedBox(
            height: 300,
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: NesContainer(
                    child: SizedBox.expand(
                      child: Image.asset(widget.image, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: NesContainer(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: NesRunningText(
                              speed: 0.03,
                              text: widget.dialogs[currentDialogIndex],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            if (widget.showSkipButton) ...[
                              NesButton.text(
                                type: NesButtonType.normal,
                                onPressed: () {
                                  widget.onNextButtonPressed();
                                },
                                text: 'Skip',
                              ),
                              const SizedBox(width: 16),
                            ],
                            NesButton.text(
                              type: NesButtonType.primary,
                              onPressed: () {
                                if (currentDialogIndex <
                                    widget.dialogs.length - 1) {
                                  setState(() {
                                    currentDialogIndex++;
                                  });
                                } else {
                                  widget.onNextButtonPressed();
                                }
                              },
                              text:
                                  currentDialogIndex < widget.dialogs.length - 1
                                      ? 'Next'
                                      : widget.nextButtonText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
