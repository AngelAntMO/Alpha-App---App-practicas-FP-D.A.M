import 'package:flutter/material.dart';

class PeluInfo extends StatefulWidget {
  const PeluInfo({super.key});

  @override
  State<PeluInfo> createState() => _PeluInfoState();
}

class _PeluInfoState extends State<PeluInfo>
    with SingleTickerProviderStateMixin {
  final Color neonBlue = const Color(0xFF64B5F6);
  final Color aguamarron = const Color(0xFFFF80AB);

  late AnimationController _controller;
 

  final List<Map<String, String>> clases = [
    {"title": "Corte caballero", "image": "assets/images/cortecaballero.jpg"},
    {"title": "Corte dama", "image": "assets/images/cortedama.jpg"},
    {"title": "Coloración", "image": "assets/images/tinte.jpg"},
    {
      "title": "Tratamiento capilar",
      "image": "assets/images/tratamientocapilar.jpg",
    },
    {"title": "Barbería", "image": "assets/images/barba.jpg"},
  ];

  final List<Map<String, String>> refuerzo = [
    {"title": "Instalaciones", "image": "assets/images/instalacionpelu.jpg"},
    {
      "title": "Personal especializado",
      "image": "assets/images/personalpelu.jpg",
    },
  ];

  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDescription(String title) {
    switch (title) {
      case "Corte caballero":
        return "Ofrecemos el servicio de cortes de caballero orientado a conseguir un estilo moderno, cuidado y adaptado a las preferencias de cada cliente.\n\n"
            "Realizamos cortes clásicos y actuales, incluyendo degradados (fade), cortes texturizados y estilos personalizados según la forma del rostro y el tipo de cabello.\n\n"
            "Durante el servicio cuidamos cada detalle para garantizar un acabado limpio y profesional, utilizando técnicas de precisión y herramientas de alta calidad.\n\n"
            "Además, asesoramos a cada cliente para ayudarle a encontrar el estilo que mejor se adapte a su imagen y personalidad.\n\n"
            "Nuestro objetivo es ofrecer un corte cómodo, actual y bien definido, que realce la estética masculina con un resultado duradero y elegante.";
      case "Corte dama":
        return "Ofrecemos el servicio de cortes de dama enfocado en realzar la belleza natural de cada persona mediante estilos personalizados, modernos y adaptados a sus rasgos.\n\n"
            "Realizamos cortes clásicos, en capas, rectos, bob, long bob y estilos más actuales, siempre teniendo en cuenta la textura del cabello y las preferencias de la clienta.\n\n"
            "Durante el proceso cuidamos cada detalle para conseguir un acabado profesional, saludable y favorecedor, utilizando técnicas precisas y productos de calidad.\n\n"
            "Además, ofrecemos asesoramiento de imagen para ayudar a elegir el corte que mejor se adapte al rostro, estilo de vida y tendencia actual.\n\n"
            "Nuestro objetivo es crear un look equilibrado, elegante y versátil que potencie la confianza y el estilo personal de cada clienta.";

      case "Coloración":
        return "Ofrecemos un servicio profesional de coloración capilar diseñado para transformar y realzar el cabello con resultados vibrantes, naturales y personalizados.\n\n"
            "Realizamos tintes completos, mechas, balayage, babylights y técnicas de iluminación adaptadas al estilo y tono de piel de cada cliente.\n\n"
            "Trabajamos con productos de alta calidad que protegen la fibra capilar, garantizando un color duradero, brillante y saludable.\n\n"
            "Además, ofrecemos servicios de corrección de color para ajustar o reparar trabajos anteriores, consiguiendo un resultado uniforme y equilibrado.\n\n"
            "Nuestro objetivo es crear colores únicos que reflejen la personalidad de cada cliente, cuidando siempre la salud y el brillo del cabello.";

      case "Tratamiento capilar":
        return "Ofrecemos tratamientos capilares profesionales diseñados para recuperar, fortalecer y revitalizar la salud del cabello desde la raíz hasta las puntas.\n\n"
            "Realizamos tratamientos de hidratación profunda, reparación intensiva y nutrición capilar adaptados a las necesidades específicas de cada tipo de cabello.\n\n"
            "Incluimos técnicas avanzadas como keratina, botox capilar y reconstrucción de fibra, que ayudan a reducir el encrespamiento, aportar brillo y mejorar la textura del cabello.\n\n"
            "También ofrecemos tratamientos anticaída y de fortalecimiento del cuero cabelludo para favorecer un crecimiento sano y equilibrado.\n\n"
            "Nuestro objetivo es devolver al cabello su vitalidad, suavidad y fuerza, garantizando resultados visibles desde las primeras sesiones.";

      case "Barbería":
        return "Ofrecemos un servicio especializado en el corte y arreglo de barba, enfocado en mantener un estilo masculino cuidado, definido y adaptado a cada cliente.\n\n"
            "Realizamos perfilado de barba con máxima precisión, respetando la forma natural del rostro para conseguir un acabado limpio, simétrico y profesional.\n\n"
            "Incluimos recorte y degradado de barba para dar volumen controlado, uniformidad y un estilo moderno o clásico según la preferencia del cliente.\n\n"
            "También trabajamos el diseño de contornos en mejillas y cuello, eliminando el exceso de vello para lograr una apariencia más pulida y ordenada.\n\n"
            "Nuestro objetivo es ofrecer una barba bien cuidada, equilibrada y estilizada, que refuerce la imagen personal con un resultado elegante y duradero.";

      case "Instalaciones":
        return "Disponemos de unas instalaciones de peluquería modernas, cómodas y diseñadas para ofrecer una experiencia de belleza relajante y profesional a cada cliente.\n\n"
            "Contamos con estaciones de trabajo totalmente equipadas, espejos de alta calidad, iluminación adecuada y mobiliario ergonómico que garantiza comodidad durante todo el servicio.\n\n"
            "Nuestras zonas de lavado están diseñadas para proporcionar una experiencia agradable, combinando confort y productos profesionales para el cuidado del cabello.\n\n"
            "El espacio está organizado para crear un ambiente limpio, acogedor y estilizado, favoreciendo la tranquilidad y la confianza del cliente.\n\n"
            "Nuestro objetivo es ofrecer un entorno donde la estética, la comodidad y la profesionalidad se unan para brindar una experiencia de peluquería completa y satisfactoria.";

      case "Personal especializado":
        return "Contamos con un equipo de peluqueros y estilistas altamente cualificados, especializados en técnicas modernas de corte, coloración y cuidado capilar.\n\n"
            "Cada profesional está formado en diferentes áreas como estilismo femenino y masculino, barbería, colorimetría y tratamientos capilares avanzados.\n\n"
            "Nuestro personal ofrece una atención cercana y personalizada, asesorando a cada cliente para encontrar el estilo que mejor se adapte a su imagen y necesidades.\n\n"
            "Además, se mantienen en constante formación para incorporar las últimas tendencias y técnicas del sector de la peluquería.\n\n"
            "Nuestro objetivo es garantizar un servicio profesional, creativo y de alta calidad, donde cada cliente reciba un trato experto y resultados excepcionales.";
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
                      color: aguamarron,
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
            "Peluquería",
            style: TextStyle(
              color: aguamarron,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: aguamarron, blurRadius: 10),
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
                            "assets/images/peluqueriainfo2.png",
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
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    "assets/images/peluqueriainfo2.png",
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

                                  /// 🔥 AQUÍ ESTÁ EL ÚNICO CAMBIO
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16,
                                              ),
                                              child: Text(
                                                "Cuidamos tu imagen",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  color: aguamarron,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    Shadow(
                                                      color: aguamarron,
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
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: aguamarron
                                                        .withValues(alpha: 0.25),
                                                    blurRadius: 18,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Image.asset(
                                                "assets/images/LogoAlphaAppPeluquería.png",
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
                      "Ofrecemos un servicio integral de peluquería orientado a realzar la imagen personal de cada cliente mediante técnicas modernas, productos de calidad y un trato totalmente personalizado.\n\n"
                      "Realizamos cortes de cabello adaptados a cada estilo y tipo de rostro, desde looks clásicos hasta tendencias actuales, garantizando un resultado profesional y favorecedor.\n\n"
                      "En el área de coloración, trabajamos con técnicas avanzadas como mechas, balayage y corrección de color, logrando resultados naturales, brillantes y duraderos.\n\n"
                      "Nuestras sesiones incluyen peinados para el día a día y eventos especiales, así como tratamientos capilares enfocados en la hidratación, reparación y cuidado profundo del cabello.\n\n"
                      "Además, ofrecemos servicios de barbería y estilismo masculino, cuidando cada detalle para conseguir un acabado limpio, moderno y personalizado.\n\n"
                      "Nuestro objetivo no es solo mejorar la apariencia, sino también cuidar la salud del cabello y ofrecer una experiencia de belleza cómoda, profesional y de confianza.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Nuestros servicios"),
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
