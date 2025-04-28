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
        'Asalam o Alaikum, $playerName',
        'Welcome to the PASA! A passion company for space exploration.',
        'I am the boss of this company. I started this company for my daughter, KAKA. She is a loves rockets and I love her.',
        'Anyways nowadays, everyone is talking about the moon.',
        'I have a mission for you.',
        'You need to go to the moon and collect some samples.',
        'Are you ready?',
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
                flex: 3,
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
                            speed: 0.04,
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
                              speed: 0.04,
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
