import 'package:flutter/material.dart';

class YogaInfo extends StatefulWidget {
  const YogaInfo({super.key});

  @override
  State<YogaInfo> createState() => _YogaInfoState();
}

class _YogaInfoState extends State<YogaInfo>with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
 final Color agua = Color(0xFF64FFDA);

  late AnimationController _controller;

  final List<Map<String, String>> clases = [
    {"title": "Yoga Suave", "image": "assets/images/yoga4.jpg"},
    {"title": "Vinyasa", "image": "assets/images/yoga.jpg"},
    {"title": "Power Yoga", "image": "assets/images/yoga2.jpg"},
    {"title": "Meditación", "image": "assets/images/meditacion.jpg"},
  ];

  final List<Map<String, String>> refuerzo = [
    {"title": "Instalaciones", "image": "assets/images/yoga3.jpg"},
    {"title": "Entrenadores personales", "image": "assets/images/yoga5.jpg"},
    
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
      case "Yoga Suave":
        return "Las clases de yoga suave están diseñadas para promover la relajación, la flexibilidad y el bienestar general mediante movimientos lentos y conscientes adaptados a todos los niveles.\n\n"
"Durante las sesiones se trabajan posturas básicas mantenidas de forma progresiva, combinadas con técnicas de respiración que ayudan a liberar tensiones físicas y mentales.\n\n"
"Este tipo de yoga es ideal para principiantes, personas en proceso de recuperación o quienes buscan una actividad tranquila para mejorar su calidad de vida.\n\n"
"Además, contribuye a reducir el estrés, mejorar la postura y aumentar la movilidad articular de forma segura y controlada.\n\n"
"Nuestras clases están guiadas por instructores que acompañan cada movimiento, garantizando una práctica relajada, accesible y enfocada en el bienestar.";
      case "Vinyasa":
        return "Las clases de Vinyasa Yoga se caracterizan por la fluidez en el movimiento, enlazando posturas de forma dinámica sincronizadas con la respiración.\n\n"
"Este estilo de yoga ayuda a mejorar la fuerza, la flexibilidad y la resistencia física mediante secuencias continuas y energéticas.\n\n"
"Durante las sesiones se trabaja la concentración y el control del cuerpo, creando una práctica activa que también favorece el equilibrio mental.\n\n"
"Es una disciplina ideal para quienes buscan un entrenamiento más intenso dentro del yoga, combinando movimiento, respiración y conciencia corporal.\n\n"
"Nuestras clases están guiadas por instructores que adaptan la intensidad según el nivel del alumno, garantizando una práctica segura, fluida y motivadora.";
         
      case "Power Yoga":
        return "Las clases de Power Yoga ofrecen una práctica dinámica e intensa enfocada en el desarrollo de la fuerza, la resistencia y la flexibilidad mediante secuencias exigentes de posturas.\n\n"
"Este estilo de yoga combina movimiento continuo con control de la respiración, proporcionando un entrenamiento físico completo que activa todo el cuerpo.\n\n"
"Durante las sesiones se trabaja la concentración, el equilibrio y la coordinación, favoreciendo tanto el rendimiento físico como la claridad mental.\n\n"
"Es ideal para personas que buscan una práctica más atlética dentro del yoga, con un enfoque en el esfuerzo físico y la superación personal.\n\n"
"Nuestras clases están guiadas por instructores que adaptan la intensidad según el nivel del alumno, garantizando una experiencia desafiante, segura y motivadora.";
      case "Meditación":
        return "Las clases de meditación están diseñadas para promover la calma mental, la reducción del estrés y el equilibrio emocional mediante técnicas guiadas de atención plena.\n\n"
"Durante las sesiones se trabajan ejercicios de respiración consciente, concentración y relajación profunda que ayudan a desconectar del ritmo diario.\n\n"
"Esta práctica permite mejorar la claridad mental, aumentar la capacidad de enfoque y fomentar un estado de bienestar general.\n\n"
"Es ideal para cualquier persona, independientemente de su nivel, que busque reducir la ansiedad y mejorar su calidad de vida emocional.\n\n"
"Nuestras clases están guiadas por instructores que acompañan el proceso paso a paso, creando un ambiente tranquilo, seguro y propicio para la introspección.";       
     
      case "Instalaciones":
        return "Nuestras instalaciones de yoga están diseñadas para crear un ambiente de calma, equilibrio y conexión interior, ideal para la práctica consciente y el bienestar personal.\n\n"
"Contamos con salas amplias, luminosas y climatizadas, equipadas con materiales adecuados como esterillas, bloques y accesorios que facilitan la correcta ejecución de las posturas.\n\n"
"El espacio está pensado para reducir distracciones y favorecer la concentración, la relajación y la armonía durante cada sesión.\n\n"
"También disponemos de zonas de descanso donde los alumnos pueden relajarse antes y después de las clases, fomentando una experiencia completa de bienestar.\n\n"
"Nuestras instalaciones están orientadas a ofrecer un entorno seguro, tranquilo y acogedor, donde cada persona pueda desarrollar su práctica de yoga a su propio ritmo.";
      case "Entrenadores personales":
        return "Contamos con un equipo de instructores de yoga altamente cualificados, comprometidos con guiar a cada alumno en su proceso de aprendizaje y desarrollo personal.\n\n"
"Nuestros entrenadores están especializados en diferentes estilos de yoga, como Hatha, Vinyasa, Power Yoga y meditación, lo que permite ofrecer clases variadas y adaptadas a todos los niveles.\n\n"
"Durante las sesiones, acompañan de forma cercana y personalizada, corrigiendo posturas, mejorando la técnica y asegurando una práctica segura y consciente.\n\n"
"Además, fomentan un ambiente de respeto, calma y motivación, ayudando a cada persona a avanzar a su propio ritmo y según sus objetivos.\n\n"
"Nuestro objetivo es guiar a los alumnos no solo en la práctica física, sino también en el desarrollo del equilibrio mental y emocional a través del yoga.";
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
                      color: agua,
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
            "Yoga",
            style: TextStyle(
              color: agua,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: agua, blurRadius: 10),
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
                            "assets/images/yogainfo.png",
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
                                      "Relaja tu cuerpo",
                                      style: TextStyle(
                                        color: agua,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: agua,
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
                                            color: agua.withValues(alpha: 0.25),
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/images/LogoAlphaAppYoga.png",
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
"Ofrecemos un servicio integral de yoga orientado a mejorar el bienestar físico, mental y emocional de cada persona mediante prácticas guiadas y adaptadas a todos los niveles.\n\n"
"Realizamos sesiones de yoga diseñadas para aumentar la flexibilidad, la fuerza y el equilibrio, acompañando la evolución del alumno desde un nivel inicial hasta una práctica más avanzada y consciente.\n\n"
"En el área de bienestar y control del estrés, ayudamos a reducir la ansiedad y mejorar la concentración a través de técnicas de respiración, meditación y relajación profunda.\n\n"
"Nuestras clases incluyen diferentes estilos de yoga como Hatha, Vinyasa o Yoga restaurativo, combinando movimiento, respiración y mindfulness para una experiencia completa.\n\n"
"Además, ofrecemos seguimiento personalizado donde cada alumno recibe orientación para mejorar su técnica, postura y progresión dentro de su práctica.\n\n"
"Nuestro objetivo no es solo mejorar la condición física, sino también fomentar la calma, el equilibrio interior y un estilo de vida más consciente y saludable.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Nuestras clases y servicios"),
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
