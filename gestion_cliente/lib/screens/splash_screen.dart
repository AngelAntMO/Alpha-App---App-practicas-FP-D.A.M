import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Splash visual mostrado durante el arranque de la aplicación, falsa pantalla de carga.
// No depende de ninguna carga real de datos.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotationAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);

    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _rotationAnim = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);

    _glowAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    _controller.forward();

    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = (screenWidth * 0.8).clamp(240, 380).toDouble();
    final spinSize = (screenWidth * 0.1).clamp(30, 55).toDouble();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final glowSize = (logoWidth * _glowAnim.value)
                    .clamp(180, 420)
                    .toDouble();

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFBFE3FF).withValues(alpha: 0.5),
                            const Color(0xFF8ECFFF).withValues(alpha: 0.25),
                            const Color(0xFF64B5F6).withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),

                    Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.rotate(
                        angle: _rotationAnim.value,
                        child: Transform.scale(
                          scale: _scaleAnim.value,
                          child: child,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Image.asset(
                'assets/images/LogoAlphaAppPagInicio.png',
                width: logoWidth,
              ),
            ),

            const SizedBox(height: 30),

            SpinKitWave(color: const Color(0xFF64B5F6), size: spinSize),
          ],
        ),
      ),
    );
  }
}
