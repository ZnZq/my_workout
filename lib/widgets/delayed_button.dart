import 'package:flutter/material.dart';
import 'package:my_workout/utils.dart';

class DelayedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final int delaySec;

  const DelayedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.delaySec = 5,
  });

  @override
  State<DelayedButton> createState() => _DelayedButtonState();
}

class _DelayedButtonState extends State<DelayedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool isCanceled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.delaySec),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPressed();
        setState(() {
          isCanceled = true;
        });
      }
    });

    _startProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startProgress() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  void _cancelProgress() {
    if (isCanceled) {
      return;
    }

    if (_controller.isAnimating) {
      _controller.stop();
    }

    _controller.reset();
    setState(() {
      isCanceled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? baseColor = Theme.of(context).colorScheme.surfaceContainerLow;
    Color progressColor = lighten(baseColor);

    return InkWell(
      onTap: widget.onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.child,
            ),
            if (!isCanceled)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.timer_off_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 16,
                    ),
                    onPressed: _cancelProgress,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
