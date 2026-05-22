import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'infoservicios/academia_info.dart';
import 'infoservicios/fisio_info.dart';
import 'infoservicios/gimnasio_info.dart';
import 'infoservicios/pelu_info.dart';
import 'infoservicios/yoga_info.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final PageController _controller = PageController(viewportFraction: 0.65);


  int? _pressedIndex;

  final services = const [
    {"image": "assets/images/peluqueriainfo2.png", "title": "Peluquería"},
    {"image": "assets/images/clinicafisioinfo.png", "title": "Clínica de fisioterapia"},
    {"image": "assets/images/gimnasioinfo.png", "title": "Gimnasio"},
    {"image": "assets/images/yogainfo.png", "title": "Yoga y Pilates"},
    {"image": "assets/images/academiainfo.png", "title": "Academia"},
  ];

  void _open(String title) {
    Widget page;

    switch (title) {
      case "Peluquería":
        page = const PeluInfo();
        break;
      case "Clínica de fisioterapia":
        page = const FisioInfo();
        break;
      case "Gimnasio":
        page = const GimnasioInfo();
        break;
      case "Yoga y Pilates":
        page = const YogaInfo();
        break;
      case "Academia":
        page = const AcademiaInfo();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final neonBlue = const Color(0xFF64B5F6);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),

      appBar: AppBar(
        title: const Text("Servicios"),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF334155),
                Color(0xFF64B5F6),
              ],
            ),
          ),
        ),
      ),

      body: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Explora nuestros servicios",
                style: TextStyle(
                  color: neonBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(color: neonBlue.withValues(alpha: 0.9), blurRadius: 18),
                    const Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final item = services[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),

                    child: Listener(
  onPointerDown: (_) {
    setState(() {
      _pressedIndex = index;
    });
  },
  onPointerUp: (_) {
    setState(() {
      _pressedIndex = null;
    });
  },
  onPointerCancel: (_) {
    setState(() {
      _pressedIndex = null;
    });
  },

  child: GestureDetector(
    onTap: () => _open(item["title"]!),

    child: AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: _pressedIndex == index ? 0.94 : 1.0,

                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),

                          // 🔥 GLOW AZUL MÁS POTENTE
                          boxShadow: [
                            BoxShadow(
                             color: neonBlue.withValues(alpha: 0.45),
                              blurRadius: 28,
                              spreadRadius: 2.5,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),

                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item["image"]!,
                                fit: BoxFit.cover,
                              ),

                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 16,
                                bottom: 16,
                                child: Text(
                                  item["title"]!,
                                  style: TextStyle(
                                    color: neonBlue,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        color: neonBlue,
                                        blurRadius: 14,
                                      ),
                                      const Shadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}