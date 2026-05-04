import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_cliente/screens/agendaworker_screen.dart';
import 'profile_worker.dart';
import 'package:gestion_cliente/screens/worker_check_screen.dart';

class InicioWorker extends StatefulWidget {
  const InicioWorker({super.key});

  @override
  State<InicioWorker> createState() => _InicioWorkerState();
}

class _InicioWorkerState extends State<InicioWorker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          leadingWidth: 150,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset(
              'assets/images/Icono_AlphaApp.png',
              fit: BoxFit.contain,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(width: 10),
          ],
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.7),
                          blurRadius: 40,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                          blurRadius: 90,
                          spreadRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.85),
                            border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                            ),
                            shape: BoxShape.circle,
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _scaleAnim,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnim.value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1E88E5,
                                        ).withValues(alpha: 0.35),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1565C0,
                                        ).withValues(alpha: 0.25),
                                        blurRadius: 34,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/LogoAlphaAppPagInicio.png',
                                    width: 240,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(seconds: 3),
                                builder: (context, value, child) {
                                  return ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment(-1 + value * 2, 0),
                                        end: Alignment(1 + value * 2, 0),
                                        colors: const [
                                          Colors.white,
                                          Colors.blueAccent,
                                          Colors.cyan,
                                          Colors.white,
                                        ],
                                        stops: const [0.0, 0.3, 0.6, 1.0],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      "Zona de empleados",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 12),

                              AnimatedBuilder(
                                animation: _scaleAnim,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (_scaleAnim.value - 1.0) * 0.5,
                                    child: child,
                                  );
                                },
                                child: const Icon(
                                  Icons.work_outline,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  HoverButton(
                    icon: Icons.how_to_reg,
                    text: "Fichar entrada/salida",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkerCheckScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  HoverButton(
                    icon: Icons.schedule,
                    text: "Agenda",
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgendaWorkerPage(),
                      ),
                  );
                    },
                  ),
                  const SizedBox(height: 20),

                  HoverButton(
                    icon: Icons.person,
                    text: "Perfil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerProfilePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const HoverButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth > 600 ? 420 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Transform.translate(
            offset: Offset(0, _isHovering ? -6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: _isHovering
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _isHovering ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(widget.icon, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
