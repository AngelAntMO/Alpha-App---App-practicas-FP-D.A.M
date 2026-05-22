import 'package:flutter/material.dart';

class GimnasioInfo extends StatefulWidget {
  const GimnasioInfo({super.key});

  @override
  State<GimnasioInfo> createState() => _GimnasioInfoState();
}

class _GimnasioInfoState extends State<GimnasioInfo>
    with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
  final Color amarillo = Color(0xFFFFF176);

  late AnimationController _controller;

  final List<Map<String, String>> clases = [
    {"title": "Sala fitness", "image": "assets/images/fitness.jpg"},
    {"title": "Spinning", "image": "assets/images/spinning.jpg"},
    {"title": "Boxeo", "image": "assets/images/boxeo.jpg"},
    {"title": "Zumba", "image": "assets/images/zumba.jpg"},
  ];

  final List<Map<String, String>> refuerzo = [
    {"title": "Instalaciones", "image": "assets/images/instalacionesgym.jpg"},
    {
      "title": "Entrenadores personales",
      "image": "assets/images/entrenador.jpg",
    },
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
      case "Sala fitness":
        return "La sala de fitness está equipada con maquinaria moderna y espacios diseñados para ofrecer un entrenamiento completo y adaptado a cualquier objetivo físico.\n\n"
            "Dispone de zonas de musculación, cardio y peso libre, permitiendo trabajar fuerza, resistencia, tonificación y acondicionamiento físico general.\n\n"
            "El espacio está pensado tanto para principiantes como para usuarios avanzados, ofreciendo libertad para entrenar de forma autónoma o con supervisión profesional.\n\n"
            "Además, el ambiente está diseñado para favorecer la motivación y la concentración, con equipos de última generación que garantizan seguridad y eficacia en cada ejercicio.\n\n"
            "Nuestra sala de fitness es el lugar ideal para mejorar la forma física, adoptar hábitos saludables y alcanzar objetivos personales de manera progresiva y constante.";
      case "Spinning":
        return "Las clases de spinning están diseñadas para mejorar la resistencia cardiovascular, la quema de calorías y la capacidad física general mediante entrenamientos intensos sobre bicicleta estática.\n\n"
            "Cada sesión combina música motivadora con cambios de ritmo, simulando subidas, sprints y recorridos de alta intensidad que permiten trabajar todo el cuerpo.\n\n"
            "El entrenamiento es adaptable a cualquier nivel, permitiendo que cada persona regule la intensidad según su condición física y objetivos personales.\n\n"
            "Además de mejorar la resistencia, el spinning ayuda a fortalecer las piernas, glúteos y el core, contribuyendo a una mejora global del rendimiento físico.\n\n"
            "Nuestras clases están guiadas por instructores especializados que acompañan y motivan en todo momento para garantizar una experiencia dinámica, segura y efectiva.";

      case "Boxeo":
        return "Las clases de boxeo están orientadas a mejorar la condición física general, la coordinación, la resistencia y la fuerza mediante un entrenamiento dinámico y de alta intensidad.\n\n"
            "Durante las sesiones se trabajan técnicas básicas y avanzadas de golpeo, desplazamiento y defensa, siempre adaptadas al nivel de cada persona.\n\n"
            "El entrenamiento combina ejercicios cardiovasculares, trabajo de fuerza y circuitos funcionales que ayudan a quemar calorías y mejorar la agilidad.\n\n"
            "Además de sus beneficios físicos, el boxeo es una excelente disciplina para liberar estrés, aumentar la concentración y mejorar la confianza personal.\n\n"
            "Nuestras clases están guiadas por entrenadores especializados que garantizan un aprendizaje progresivo, seguro y motivador.";
      case "Zumba":
        return "Las clases de zumba combinan ejercicio físico y música para ofrecer un entrenamiento dinámico, divertido y efectivo que mejora la condición física general.\n\n"
            "A través de coreografías sencillas basadas en ritmos latinos y música internacional, se trabaja el sistema cardiovascular mientras se queman calorías de forma entretenida.\n\n"
            "Es una actividad apta para todos los niveles, ya que cada persona puede seguir el ritmo a su propio nivel de intensidad.\n\n"
            "Además de mejorar la resistencia y la coordinación, la zumba ayuda a liberar estrés, aumentar la energía y mejorar el estado de ánimo.\n\n"
            "Nuestras sesiones están guiadas por instructores que motivan y acompañan en todo momento para garantizar una experiencia divertida, activa y saludable.";

      case "Instalaciones":
        return "Nuestras instalaciones están diseñadas para ofrecer un entorno moderno, cómodo y completamente equipado que favorece el rendimiento y el bienestar de todos los usuarios.\n\n"
            "Contamos con amplias zonas de entrenamiento que incluyen sala de fitness, áreas de cardio, peso libre y espacios funcionales adaptados a diferentes tipos de entrenamiento.\n\n"
            "Disponemos de salas específicas para clases dirigidas como spinning, zumba y entrenamiento de alta intensidad, equipadas con material de última generación.\n\n"
            "El gimnasio también cuenta con vestuarios amplios, duchas, zonas de descanso y espacios climatizados para garantizar la máxima comodidad durante la estancia.\n\n"
            "Nuestro objetivo es ofrecer un ambiente seguro, motivador y accesible, donde cada persona pueda entrenar a su ritmo y alcanzar sus objetivos de forma eficaz.";
      case "Entrenadores personales":
        return "Ofrecemos servicio de entrenamiento personal totalmente personalizado, diseñado para adaptarse a los objetivos, nivel físico y necesidades de cada persona.\n\n"
            "Nuestros entrenadores personales elaboran planes de entrenamiento específicos para mejorar la fuerza, la resistencia, la pérdida de peso o la mejora del rendimiento deportivo.\n\n"
            "Durante cada sesión, el usuario recibe atención directa, corrección de técnica y seguimiento continuo para asegurar una ejecución correcta y segura de los ejercicios.\n\n"
            "Además, se realiza un control constante de la evolución, ajustando las rutinas para maximizar resultados y mantener la motivación en todo momento.\n\n"
            "Nuestro objetivo es acompañar al usuario en su proceso de cambio físico, garantizando un entrenamiento eficaz, seguro y completamente adaptado a sus metas.";
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
                      color: amarillo,
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
            "Gimnasio",
            style: TextStyle(
              color: amarillo,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: amarillo, blurRadius: 10),
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
                            "assets/images/gimnasioinfo.png",
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
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Text(
                                        "Mejora tu salud",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          color: amarillo,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: amarillo,
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
                                            color: amarillo.withValues(alpha: 0.25),
                                            blurRadius: 18,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/images/LogoAlphaAppGimnasio.png",
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
                      "Ofrecemos un servicio integral de entrenamiento en gimnasio orientado a mejorar la salud, la forma física y la calidad de vida de cada persona mediante planes de entrenamiento personalizados y adaptados a sus objetivos.\n\n"
                      "Realizamos programas de fuerza, resistencia y pérdida de peso diseñados para acompañar la progresión del usuario desde el nivel inicial hasta un rendimiento físico avanzado, asegurando una evolución constante y segura.\n\n"
                      "En el área de entrenamiento funcional y deportivo, ayudamos a mejorar el rendimiento físico, prevenir lesiones y optimizar la condición física a través de rutinas específicas y guiadas por profesionales.\n\n"
                      "Nuestras sesiones incluyen trabajo de musculación, cardio, entrenamiento funcional y asesoramiento técnico para mejorar la ejecución de ejercicios, la movilidad y la resistencia general.\n\n"
                      "Además, ofrecemos seguimiento personalizado donde cada usuario recibe orientación, planificación y ajustes en su rutina para maximizar resultados y mantener la motivación.\n\n"
                      "Nuestro objetivo no es solo mejorar la apariencia física, sino también fomentar hábitos saludables, constancia y un estilo de vida activo y equilibrado.",
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
