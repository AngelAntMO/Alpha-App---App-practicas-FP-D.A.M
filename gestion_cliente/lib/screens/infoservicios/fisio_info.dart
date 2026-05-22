import 'package:flutter/material.dart';

class FisioInfo extends StatefulWidget {
  const FisioInfo({super.key});

  @override
  State<FisioInfo> createState() => _FisioInfoState();
}

class _FisioInfoState extends State<FisioInfo>
    with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
  final Color neonPurpleBright = const Color(0xFF9575FF);

  late AnimationController _controller;
  // ← _fadeAnimation y _scaleAnimation eliminados — no se usaban

  final List<Map<String, String>> clases = [
    {"title": "Especialista 1", "image": "assets/images/especialista1.jpg"},
    {"title": "Especialista 2", "image": "assets/images/especialista2.jpg"},
    {"title": "Especialista 3", "image": "assets/images/especialista3.jpg"},
  ];

  final List<Map<String, String>> refuerzo = [
    {
      "title": "Máquinas especializadas",
      "image": "assets/images/maquinafisio.jpg",
    },
    {
      "title": "Tratamientos personalizados",
      "image": "assets/images/tratamientofisio.jpg",
    },
    {"title": "Rehabilitación", "image": "assets/images/rehabilitacion.jpg"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDescription(String title) {
    switch (title) {
      case "Especialista 1":
        return "Luis, fisioterapeuta con especialización en rehabilitación deportiva. Se centra en la prevención y tratamiento de lesiones, utilizando técnicas de terapia manual y ejercicio terapéutico para acelerar la recuperación y mejorar el rendimiento físico.";
      case "Especialista 2":
        return "María, especialista en electroterapia dentro del ámbito de la fisioterapia. Aplica tratamientos con corrientes terapéuticas, ultrasonidos y técnicas complementarias para mejorar la recuperación de lesiones y optimizar la función muscular.";
      case "Especialista 3":
        return "Raúl, especialista en terapia manual y fisioterapia neurológica. Trabaja en la rehabilitación de pacientes con afecciones del sistema nervioso y lesiones musculoesqueléticas, utilizando técnicas manuales avanzadas para mejorar la funcionalidad y la calidad de vida.";
      case "Máquinas especializadas":
        return "Contamos con tecnología avanzada de fisioterapia diseñada para potenciar la recuperación y mejorar los resultados de cada tratamiento de forma segura y eficaz.\n\n"
            "Incorporamos equipos de electroterapia, que ayudan a aliviar el dolor, reducir la inflamación y estimular la regeneración muscular mediante corrientes terapéuticas controladas.\n\n"
            "Disponemos de ultrasonido terapéutico, utilizado para tratar lesiones profundas de tejidos blandos, mejorando la circulación y acelerando los procesos de recuperación.\n\n"
            "Nuestras máquinas de láser terapéutico permiten actuar sobre zonas específicas del cuerpo, favoreciendo la regeneración celular y la disminución del dolor crónico o agudo.\n\n"
            "Además, contamos con equipos de magnetoterapia, que utilizan campos magnéticos para mejorar la consolidación ósea y reducir procesos inflamatorios.\n\n"
            "Nuestro objetivo es combinar la tecnología con la atención personalizada para ofrecer tratamientos más precisos, efectivos y adaptados a cada paciente.";
      case "Tratamientos personalizados":
        return "Ofrecemos tratamientos de fisioterapia personalizados diseñados a partir de una valoración inicial completa de cada paciente, teniendo en cuenta su lesión, estado físico y objetivos de recuperación.\n\n"
            "Cada plan de tratamiento se adapta de forma individual, combinando terapia manual, ejercicio terapéutico y técnicas avanzadas para conseguir una recuperación más eficaz y segura.\n\n"
            "Realizamos un seguimiento continuo para evaluar la evolución del paciente y ajustar el tratamiento en función de sus progresos, garantizando una atención totalmente adaptada.\n\n"
            "Nuestro enfoque busca no solo aliviar el dolor o tratar la lesión, sino también mejorar la funcionalidad, prevenir recaídas y optimizar el bienestar general del paciente.\n\n"
            "El objetivo es ofrecer un tratamiento único para cada persona, centrado en una recuperación completa, progresiva y duradera.";
      case "Rehabilitación":
        return "Nuestro servicio de rehabilitación está enfocado en la recuperación funcional del paciente tras lesiones, cirugías o procesos dolorosos que afectan al sistema musculoesquelético.\n\n"
            "Aplicamos un enfoque progresivo que combina terapia manual, ejercicio terapéutico y técnicas avanzadas de fisioterapia para restaurar la movilidad, la fuerza y la funcionalidad.\n\n"
            "Cada tratamiento se diseña de forma individualizada, adaptándose a la evolución del paciente y a sus necesidades específicas en cada fase de la recuperación.\n\n"
            "Acompañamos al paciente durante todo el proceso, con un seguimiento continuo que garantiza una recuperación segura, eficaz y adaptada a sus objetivos.\n\n"
            "Nuestro objetivo es devolver la autonomía y mejorar la calidad de vida, reduciendo el dolor y previniendo futuras recaídas.";
      default:
        return "Información no disponible.";
    }
  }

  void _showInfoDialog(String title) {
    final description = _getDescription(title);

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6), // ← fix
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: neonPurpleBright,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
          title: Text(
            "Fisioterápia",
            style: TextStyle(
              color: neonPurpleBright,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: neonPurpleBright, blurRadius: 10),
                const Shadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white70),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Banner ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/clinicafisioinfo.png",
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.75), // ← fix
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Text(
                                        "Restauramos tu bienestar",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          color: neonPurpleBright,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: neonPurpleBright,
                                              blurRadius: 10,
                                            ),
                                            const Shadow(
                                              color: Colors.black,
                                              blurRadius: 8,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: neonPurpleBright.withValues(alpha: 0.25), // ← fix
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/images/LogoAlphaAppFisioterapia.png",
                                        height: 85,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      "Ofrecemos un servicio integral de fisioterapia orientado a mejorar la calidad de vida de cada paciente mediante tratamientos personalizados y basados en la evidencia.\n\n"
                      "Realizamos terapias de rehabilitación física centradas en la recuperación progresiva de lesiones musculares y articulares, trabajando desde la fase inicial hasta la completa readaptación funcional.\n\n"
                      "En el área de fisioterapia deportiva, ayudamos a prevenir y tratar lesiones, optimizando el rendimiento físico a través de técnicas específicas y programas adaptados a cada disciplina.\n\n"
                      "Nuestros tratamientos incluyen terapia manual, ejercicios terapéuticos y técnicas avanzadas para aliviar el dolor, mejorar la movilidad y acelerar la recuperación.\n\n"
                      "Además, ofrecemos sesiones individualizadas donde el paciente recibe atención directa, seguimiento continuo y orientación para mejorar sus hábitos posturales y su bienestar diario.\n\n"
                      "Nuestro objetivo es no solo tratar la lesión, sino también prevenir futuras dolencias y promover una recuperación eficaz, segura y duradera.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85), // ← fix
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Nuestro equipo de especialistas"),
                  _horizontalList(clases),

                  const SizedBox(height: 25),

                  _sectionTitle("Nuestras instalaciones"),
                  _horizontalList(refuerzo),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          color: neonBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: neonBlue, blurRadius: 10),
            const Shadow(color: Colors.black, blurRadius: 6),
          ],
        ),
      ),
    );
  }

  Widget _horizontalList(List<Map<String, String>> items) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _HoverCard(
            title: item["title"]!,
            image: item["image"]!,
            neonBlue: neonBlue,
            onTap: () => _showInfoDialog(item["title"]!),
          );
        },
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final String title;
  final String image;
  final Color neonBlue;
  final VoidCallback onTap;

  const _HoverCard({
    required this.title,
    required this.image,
    required this.neonBlue,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isHovered ? 1.12 : 1.0,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    widget.image,
                    height: 140,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.neonBlue,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(color: widget.neonBlue, blurRadius: 8),
                      const Shadow(color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}