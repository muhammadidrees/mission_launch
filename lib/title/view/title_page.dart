import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_launch/boss_office/boss_office.dart';
import 'package:mission_launch/rocket_workshop/rocket_workshop.dart';
import 'package:nes_ui/nes_ui.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TitlePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: TitleView()),
    );
  }
}

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mission Launch',
            style: TextTheme.of(context).displayLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Space race to the moon',
            style: TextTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 56),
          NesButton.text(
            type: NesButtonType.normal,
            onPressed: () async {
              // Navigator.of(context).push(GamePage.route());
              final name = await NesInputDialog.show(
                context: context,
                message: 'Please enter your name:',
              );

              if (name == null || name.isEmpty) {
                return;
              }

              if (!context.mounted) return;

              context.read<RocketWorkshopCubit>().setPlayerName(name);

              await Navigator.of(context).push(BossOfficePage.route());
            },
            text: 'Start Game',
          ),
        ],
      ),
    );
  }
}
