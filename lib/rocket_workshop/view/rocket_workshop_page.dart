// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mission_launch/game/game.dart';
import 'package:mission_launch/gen/assets.gen.dart';
import 'package:mission_launch/rocket_workshop/rocket_workshop.dart';
import 'package:nes_ui/nes_ui.dart';

class RocketWorkshopPage extends StatelessWidget {
  const RocketWorkshopPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RocketWorkshopPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: RocketWorkshopView());
  }
}

class RocketWorkshopView extends StatelessWidget {
  const RocketWorkshopView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Row(
        children: [
          const Expanded(child: WorkStation()),
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: Image.asset(
                Assets.images.rocketWorkshop.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkStation extends StatelessWidget {
  const WorkStation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RocketWorkshopCubit, RocketWorkshopState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rocket Workshop',
                style: TextTheme.of(context).titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'This is the rocket workshop. Here you can improve your rocket by adding health and speed bars.',
                style: TextTheme.of(context).titleSmall,
              ),
              const SizedBox(height: 32),
              NesContainer(
                child: Column(
                  children: [
                    BarSelector(
                      title: 'Rocket Health',
                      information:
                          'Select the number of health bars for your rocket.',
                      totalOptions: 6,
                      defaultSelection: 1,
                      maxAllowedSelection: state.maxHealth,
                      pricePerBar: kHealthPrice,
                      onSelectionChanged: (selectedValue, totalPrice) {
                        context
                            .read<RocketWorkshopCubit>()
                            .setRocketHealth(selectedValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    BarSelector(
                      title: 'Rocket Speed',
                      information:
                          'Select the number of speed bars for your rocket.',
                      totalOptions: 6,
                      defaultSelection: 1,
                      maxAllowedSelection: state.maxSpeed,
                      pricePerBar: kSpeedPrice,
                      onSelectionChanged: (selectedValue, totalPrice) {
                        context
                            .read<RocketWorkshopCubit>()
                            .setRocketSpeed(selectedValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    BarSelector(
                      title: 'Bullet Speed',
                      information:
                          'Select the number of speed bars for your rocket.',
                      totalOptions: 4,
                      defaultSelection: 1,
                      maxAllowedSelection: state.maxBulletSpeed,
                      pricePerBar: kBulletSpeedPrice,
                      onSelectionChanged: (selectedValue, totalPrice) {
                        context
                            .read<RocketWorkshopCubit>()
                            .setBulletSpeed(selectedValue);
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(height: 32),
              Text(
                'Remaining budget: \$${state.remainingMoney}',
                style: TextTheme.of(context).titleMedium,
              ),
              const SizedBox(height: 32),
              NesButton.text(
                type: NesButtonType.normal,
                onPressed: () {
                  Navigator.of(context).pushReplacement<void, void>(
                    GamePage.route(),
                  );
                },
                text: 'Start Mission',
              ),
            ],
          ),
        );
      },
    );
  }
}

class BarSelector extends StatefulWidget {
  const BarSelector({
    required this.title,
    required this.totalOptions,
    required this.information,
    required this.defaultSelection,
    required this.maxAllowedSelection,
    required this.pricePerBar,
    super.key,
    this.onSelectionChanged,
  });

  final String title;
  final String information;
  final int totalOptions;
  final int defaultSelection;
  final int maxAllowedSelection;
  final double pricePerBar;
  final void Function(int selectedValue, double totalPrice)? onSelectionChanged;

  @override
  State<BarSelector> createState() => _BarSelectorState();
}

class _BarSelectorState extends State<BarSelector> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.defaultSelection;
  }

  void _selectBar(int index) {
    if (index < widget.defaultSelection) return; // Can't deselect default
    if (index > widget.maxAllowedSelection) return; // Exceeds max allowed

    setState(() {
      _selectedValue = index;
      widget.onSelectionChanged?.call(_selectedValue, _calculatePrice());
    });
  }

  double _calculatePrice() {
    // Only charge for bars selected above the default
    final extraBars = _selectedValue - widget.defaultSelection;
    return extraBars > 0 ? extraBars * widget.pricePerBar : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 8),
            NesTooltip(
              message: widget.information,
              arrowDirection: NesTooltipArrowDirection.bottom,
              arrowPlacement: NesTooltipArrowPlacement.left,
              child: NesIcon(iconData: NesIcons.questionMarkBlock),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth / widget.totalOptions) - 20;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.totalOptions,
                  (index) {
                    final barIndex = index + 1;
                    final isSelected = barIndex <= _selectedValue;
                    final isDefault = barIndex <= widget.defaultSelection;
                    final isDisabled = barIndex > widget.maxAllowedSelection;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: isDisabled ? null : () => _selectBar(barIndex),
                        child: NesContainer(
                          width: itemWidth.clamp(40.0, 100.0),
                          height: 36,
                          backgroundColor: isSelected
                              ? Colors.white
                              : isDefault
                                  ? Colors.grey
                                  : isDisabled
                                      ? Colors.black54
                                      : Colors.blueGrey,
                          child: Center(
                            child: Text(
                              '$barIndex',
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Price: \$${widget.pricePerBar} x ${_selectedValue - widget.defaultSelection} = \$${_calculatePrice().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
