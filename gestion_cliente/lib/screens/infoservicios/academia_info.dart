import 'package:flutter/material.dart';

class AcademiaInfo extends StatefulWidget {
  const AcademiaInfo({super.key});

  @override
  State<AcademiaInfo> createState() => _AcademiaInfoState();
}

class _AcademiaInfoState extends State<AcademiaInfo>
    with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
  final Color neonOrange = const Color(0xFFFFA726);

  late AnimationController _controller;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> clases = [
    {"title": "Matemáticas", "image": "assets/images/clasemates.png"},
    {"title": "Inglés", "image": "assets/images/claseingles.png"},
    {"title": "Repaso general", "image": "assets/images/estudianteMoure.png"},
  ];

  final List<Map<String, String>> refuerzo = [
    {"title": "Exámenes", "image": "assets/images/examen.jpg"},
    {"title": "Técnicas de estudio", "image": "assets/images/estudio.jpg"},
    {"title": "Tutorías", "image": "assets/images/moureperfil.png"},
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🧠 DESCRIPCIONES
  String _getDescription(String title) {
    switch (title) {
      case "Matemáticas":
        return "Clases de Matemáticas diseñadas para reforzar la comprensión desde los fundamentos hasta niveles avanzados. Trabajamos de forma progresiva el álgebra, la geometría, el cálculo y la resolución de problemas, explicando cada concepto paso a paso para garantizar una comprensión real y duradera.\n\n"
            "El enfoque de las clases se adapta al nivel de cada alumno, permitiendo reforzar bases si es necesario o avanzar hacia contenidos más complejos. Se hace especial hincapié en la práctica constante, la lógica matemática y la resolución guiada de ejercicios similares a los que aparecen en exámenes.\n\n"
            "Ideales tanto para mejorar el rendimiento diario como para preparar pruebas y exámenes con mayor seguridad y confianza.";
      case "Inglés":
        return "Clases de Inglés enfocadas en el desarrollo completo de las competencias lingüísticas: gramática, vocabulario, comprensión auditiva (listening), expresión oral (speaking) y expresión escrita (writing).\n\n"
            "El objetivo es mejorar la fluidez y la confianza al comunicarse en inglés, trabajando situaciones reales de uso del idioma y reforzando las bases gramaticales de forma clara y progresiva.\n\n"
            "Además, se realiza preparación específica para exámenes oficiales, practicando modelos de prueba, estrategias de examen y técnicas para mejorar el rendimiento en cada parte del examen.\n\n"
            "Ideales tanto para mejorar el nivel general del idioma como para alcanzar objetivos académicos o certificados oficiales.";
      case "Repaso general":
        return "Clases de refuerzo general diseñadas para ayudar al alumno a mejorar su rendimiento en todas las asignaturas del curso. Se adaptan completamente al nivel y necesidades de cada estudiante, trabajando de forma personalizada los contenidos que más le cuestan.\n\n"
            "Durante las sesiones se refuerzan los conceptos clave de cada materia, se resuelven dudas específicas y se realizan ejercicios prácticos para consolidar el aprendizaje.\n\n"
            "El objetivo es mejorar la comprensión global de las asignaturas, reforzar la base académica y aumentar la seguridad del alumno en su día a día escolar.";
      case "Exámenes":
        return "Clases centradas en la preparación de exámenes mediante simulacros reales y entrenamiento intensivo. Se trabajan modelos de prueba similares a los exámenes oficiales para que el alumno se familiarice con el formato, el tipo de preguntas y la gestión del tiempo.\n\n"
            "Durante las sesiones se refuerzan los contenidos clave, se identifican errores comunes y se aplican estrategias efectivas para mejorar el rendimiento en situaciones de evaluación.\n\n"
            "El objetivo es que el alumno llegue a los exámenes con mayor seguridad, control y confianza en sus conocimientos y habilidades.";
      case "Técnicas de estudio":
        return "Clases enfocadas en enseñar técnicas de estudio eficaces que ayudan a mejorar la comprensión, la memoria y el rendimiento académico. Se trabajan métodos prácticos para organizar el tiempo, resumir contenidos y afrontar el estudio de manera más eficiente.\n\n"
            "El alumno aprende estrategias para optimizar su aprendizaje, como la elaboración de esquemas, técnicas de memorización activa y planificación del estudio antes de exámenes.\n\n"
            "El objetivo es que el estudiante no solo estudie más, sino que estudie mejor, logrando resultados más sólidos con menos esfuerzo y mayor confianza.";
      case "Tutorías":
        return "Sesiones de tutoría personalizadas diseñadas para atender de forma individual las necesidades de cada alumno. Durante estas clases se resuelven dudas específicas de cualquier asignatura y se refuerzan los contenidos que presentan mayor dificultad.\n\n"
            "El profesor acompaña al estudiante de manera cercana, ayudándole a comprender mejor los conceptos, mejorar su organización y reforzar su método de estudio.\n\n"
            "El objetivo es ofrecer un apoyo continuo y adaptado que permita mejorar el rendimiento académico. ";
      default:
        return "Información no disponible.";
    }
  }

  // 🪟 MODAL INFO
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
                    color: Colors.black.withValues(alpha: 0.6),
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
                      color: neonOrange,
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
            "Academia",
            style: TextStyle(
              color: neonOrange,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: neonOrange, blurRadius: 10),
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
                  // 🎬 BANNER
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/academiainfo.png",
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
                                  Colors.black.withValues(alpha: 0.75),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      "Aprende a tu ritmo",
                                      style: TextStyle(
                                        color: neonOrange,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: neonOrange,
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
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: neonOrange.withValues(alpha: 0.25),
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/images/LogoAlphaAppAcademia.png",
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

                  // 🧠 TEXTO
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Text(
                      "Ofrecemos un sistema de apoyo académico integral diseñado para potenciar el rendimiento de cada estudiante mediante un aprendizaje personalizado y estructurado.\n\n"
                      "Impartimos clases de Matemáticas, centradas en el desarrollo progresivo de habilidades desde la base hasta niveles avanzados, incluyendo álgebra, geometría y resolución de problemas complejos.\n\n"
                      "En Inglés, trabajamos todas las competencias lingüísticas: comprensión, expresión oral y escrita, gramática y preparación de exámenes oficiales.\n\n"
                      "Las clases de repaso general permiten consolidar conocimientos de diferentes asignaturas, reforzando los contenidos más importantes del curso escolar.\n\n"
                      "Además, contamos con tutorías individualizadas, donde el alumno recibe atención directa para resolver dudas, mejorar su organización y optimizar su método de estudio.\n\n"
                      "Nuestro objetivo es no solo mejorar las calificaciones, sino también enseñar a aprender de forma autónoma, eficiente y duradera.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Clases disponibles"),
                  _horizontalList(clases),

                  const SizedBox(height: 25),

                  _sectionTitle("Refuerzo y apoyo"),
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

  // 📌 TITULOS
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

  // 📜 LISTA HORIZONTAL
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

// 🖱️ CARD CON HOVER + CLICK
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
