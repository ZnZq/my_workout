import 'package:flutter/material.dart';
import 'dart:math' as math;

class WorkoutExpansion extends StatefulWidget {
  final String title;
  final String displayValue;
  final Widget child;
  final List<Widget> actions;

  const WorkoutExpansion({
    super.key,
    required this.title,
    required this.child,
    this.displayValue = '',
    this.actions = const [],
  });

  @override
  State<WorkoutExpansion> createState() => _WorkoutExpansionState();
}

class _WorkoutExpansionState extends State<WorkoutExpansion>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _expanded = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    super.initState();
  }

  void _expandChanged() {
    if (_expanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    _expanded = !_expanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(widget.displayValue.isEmpty
                ? widget.title
                : '${widget.title}: ${widget.displayValue}'),
            Spacer(),
            ...widget.actions,
            AnimatedBuilder(
              animation: _animationController,
              child: IconButton(
                onPressed: _expandChanged,
                icon: Icon(Icons.keyboard_arrow_down_sharp),
                iconSize: 16,
              ),
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _animationController.value * math.pi,
                  child: child,
                );
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SizeTransition(
                  sizeFactor: _animationController,
                  child: child,
                );
              },
              child: widget.child,
            ),
          ],
        )
      ],
    );
  }
}
