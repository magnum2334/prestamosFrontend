import 'package:flutter/material.dart';

class AnimatedIconWidget extends StatefulWidget {
  final Color iconColor; // Parámetro para el color del ícono

  const AnimatedIconWidget({Key? key, required this.iconColor}) : super(key: key);

  @override
  _AnimatedIconWidgetState createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Repite la animación y la invierte

    _sizeAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _sizeAnimation.value, // Cambia el tamaño del ícono
          child: Icon(
            Icons.access_alarms, // Icono de alarma
            color: widget.iconColor, // Usa el color pasado por parámetro
            size: 22, // Tamaño base del icono
          ),
        );
      },
    );
  }
}
