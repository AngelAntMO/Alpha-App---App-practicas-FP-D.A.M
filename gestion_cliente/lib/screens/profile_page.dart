import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

import 'package:gestion_cliente/screens/inicio_screen.dart';
import 'package:gestion_cliente/screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final List<String> avatarOptions = const [
    "assets/images/moureperfil.png",
    "assets/images/acaperfil.png",
    "assets/images/peluqueriaperfil.png",
    "assets/images/perfilfisio.png",
    "assets/images/perfilgimnasio.png",
    "assets/images/yogaperfil.png",
    "assets/images/tazaperfil.png",
    "assets/images/tazasuciaperfil.png",
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    double screenWidth = MediaQuery.of(context).size.width;

    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.88;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Mi Perfil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => PaginaInicio()),
                (route) => false,
              );
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: containerWidth,
              child: Column(
                children: [
                  _buildHeader(user),

                  const SizedBox(height: 30),

                  AnimatedMenuButton(
                    icon: Icons.person_outline,
                    title: "Editar Información",
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        _showEditProfile(context, user.uid);
                      }
                    },
                  ),
                  AnimatedMenuButton(
                    icon: Icons.notifications_none,
                    title: "Notificaciones",
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        _showNotifications(context, user.uid);
                      }
                    },
                  ),
                  AnimatedMenuButton(
                    icon: Icons.miscellaneous_services_outlined,
                    title: "Servicios",
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        _showNegociosDialog(context, user.uid);
                      }
                    },
                  ),
                  AnimatedMenuButton(
                    icon: Icons.support_agent,
                    title: "Soporte",
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        _showHelpDialog(context, user.uid);
                      }
                    },
                  ),

                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(color: Colors.white10, thickness: 1),
                  ),
                  const SizedBox(height: 25),

                  AnimatedLogoutButton(
                    text: "Cerrar sesión",
                    onTap: () async {
                      final bool? confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              "Cerrar sesión",
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              "¿Estás seguro de que quieres cerrar sesión?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  "Cerrar sesión",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmar == true) {
                        await FirebaseAuth.instance.signOut();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 HEADER CON ANIMACIÓN BOUNCE
  Widget _buildHeader(User? user) {
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }

        String nombreCompleto = user.displayName ?? "Usuario";
        String email = user.email ?? "Sin correo";
        String iniciales = "U";
        String? avatarUrl;

        if (snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;

          String nombre = data['nombre'] ?? "";
          String apellidos = data['apellidos'] ?? "";
          email = data['email'] ?? user.email ?? "Sin correo";
          avatarUrl = data['avatar'];

          if (nombre.isNotEmpty || apellidos.isNotEmpty) {
            nombreCompleto = "$nombre $apellidos".trim();
          }

          String iNombre = nombre.isNotEmpty ? nombre[0].toUpperCase() : "";
          String iApellido = apellidos.isNotEmpty
              ? apellidos[0].toUpperCase()
              : "";

          iniciales = (iNombre + iApellido).isEmpty ? "U" : iNombre + iApellido;
        }

        return Column(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                double scale = 1.0;

                return GestureDetector(
                  onTap: () async {
                    setState(() => scale = 0.9);
                    await Future.delayed(const Duration(milliseconds: 100));

                    setState(() => scale = 1.05);
                    await Future.delayed(const Duration(milliseconds: 100));

                    setState(() => scale = 1.0);

                    if (!context.mounted) return;

                    _showAvatarPicker(context, user.uid);
                  },
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        transitionBuilder: (child, animation) {
                          final bounceAnimation = TweenSequence<double>([
                            TweenSequenceItem(
                              tween: Tween(
                                begin: 0.8,
                                end: 1.2,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                              weight: 40,
                            ),
                            TweenSequenceItem(
                              tween: Tween(
                                begin: 1.2,
                                end: 0.95,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                              weight: 30,
                            ),
                            TweenSequenceItem(
                              tween: Tween(
                                begin: 0.95,
                                end: 1.0,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                              weight: 30,
                            ),
                          ]).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: bounceAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: CircleAvatar(
                          key: ValueKey(avatarUrl ?? iniciales),
                          radius: 45,
                          backgroundColor: const Color(0xFF64B5F6),
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? Text(
                                  iniciales,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            Text(
              nombreCompleto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  // 🔹 SELECTOR DE AVATAR
  void _showAvatarPicker(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
      builder: (context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 80),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            height: 340,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF334155),
                ],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 🔹 barra superior
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Elige tu avatar",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      itemCount: avatarOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemBuilder: (context, index) {
                        final avatar = avatarOptions[index];

                        return GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .set({
                                  'avatar': avatar,
                                }, SetOptions(merge: true));

                            if (!context.mounted) return;

                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(avatar),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfile(BuildContext context, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!context.mounted) return;

    final data = doc.data() ?? {};

    final user = FirebaseAuth.instance.currentUser;

    final googleName = user?.displayName ?? "";


    String nombre = data['nombre'] ?? "";
String apellidos = data['apellidos'] ?? "";

// 🔥 Si no hay datos en Firestore, usar Google
if (nombre.isEmpty && googleName.isNotEmpty) {
  final partes = googleName.split(" ");
  nombre = partes.first;
  apellidos = partes.length > 1 ? partes.sublist(1).join(" ") : "";
}

  final nameController = TextEditingController(text: nombre);
  final lastNameController = TextEditingController(text: apellidos);
  final addressController = TextEditingController(
    text: data['direccion'] ?? '',
  );
  final phoneController = TextEditingController(
  text: data['telefono'] ?? '',
);
    

    DateTime? birthDate = data['fechaNacimiento'] != null
        ? (data['fechaNacimiento'] as Timestamp).toDate()
        : null;

        
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInput(nameController, "Nombre"),
                  _buildInput(lastNameController, "Apellidos"),
                  _buildInput(addressController, "Dirección"),
                  _buildInput(phoneController, "Teléfono"),

                  const SizedBox(height: 10),

                  // 📅 FECHA DE NACIMIENTO (FIX REAL)
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: birthDate ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() {
                          birthDate =
                              picked; // 🔥 ahora sí se guarda en estado real
                        });
                      }
                    },
                    child: Text(
                      birthDate == null
                          ? "Seleccionar fecha de nacimiento"
                          : "Nacimiento: ${birthDate!.day}/${birthDate!.month}/${birthDate!.year}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({
                            'nombre': nameController.text.trim(),
                            'apellidos': lastNameController.text.trim(),
                            'direccion': addressController.text.trim(),
                            'telefono': phoneController.text.trim(),

                            // 🔥 GUARDA REALMENTE LA FECHA
                            'fechaNacimiento': birthDate != null
                                ? Timestamp.fromDate(birthDate!)
                                : null,
                          }, SetOptions(merge: true));
                      if (!context.mounted) return;

                      Navigator.pop(context);
                    },
                    child: const Text("Guardar cambios"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotifications(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            bool enabled = true;

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              enabled = data['notificationsEnabled'] ?? true;
            }

            return Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Notificaciones",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SwitchListTile(
                    value: enabled,
                    onChanged: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set({
                            'notificationsEnabled': value,
                          }, SetOptions(merge: true));
                    },
                    title: const Text(
                      "Activar notificaciones",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      enabled
                          ? "Recibirás notificaciones"
                          : "Notificaciones desactivadas",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    activeTrackColor: Colors.blueAccent,
                    thumbColor: WidgetStatePropertyAll(Colors.blueAccent),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNegociosDialog(BuildContext context, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!context.mounted) return;
    final data = doc.data();
    if (data == null) return;

    final List<String> serviciosDisponibles = [
      "Gimnasio",
      "Academia",
      "Fisioterapia",
      "Yoga",
      "Peluqueria",
    ];

    List<String> negocios = List<String>.from(data['negocios'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Mis servicios",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const Text(
                          "Activos",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (negocios.isEmpty)
                          const Text(
                            "No tienes servicios activos",
                            style: TextStyle(color: Colors.white54),
                          ),

                        ...negocios.map((servicio) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.store,
                                color: Colors.greenAccent,
                              ),
                              title: Text(
                                servicio,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  setStateDialog(() {
                                    negocios.remove(servicio);
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .set({
                                        'negocios': negocios,
                                      }, SetOptions(merge: true));
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "❌ '$servicio' dado de baja",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        const Text(
                          "Disponibles",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ...serviciosDisponibles.map((servicio) {
                          final yaActivo = negocios.contains(servicio);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: ListTile(
                              leading: Icon(
                                yaActivo
                                    ? Icons.check_circle
                                    : Icons.add_circle,
                                color: yaActivo
                                    ? Colors.greenAccent
                                    : Colors.white38,
                              ),
                              title: Text(
                                servicio,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                yaActivo ? "Activo" : "Disponible",
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: SizedBox(
                                width: 90,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: yaActivo
                                        ? Colors.white24
                                        : const Color(0xFF64B5F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: yaActivo
                                      ? null
                                      : () async {
                                          setStateDialog(() {
                                            negocios.add(servicio);
                                          });

                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .set({
                                                'negocios': negocios,
                                              }, SetOptions(merge: true));

                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "✅ Alta en '$servicio'",
                                              ),
                                              backgroundColor:
                                                  Colors.greenAccent,
                                            ),
                                          );
                                        },
                                  child: Text(
                                    yaActivo ? "Activo" : "Alta",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context, String uid) {
    final mensajeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 🔹 barra superior
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Ayuda y Soporte",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Text(
                        "¿Tienes algún problema o duda?\nEscríbenos y te responderemos lo antes posible.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextField(
                          controller: mensajeController,
                          maxLines: 6,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Escribe tu mensaje...",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B5F6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            if (mensajeController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("⚠️ Escribe un mensaje"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            await _sendSupportMessage(
                              uid,
                              mensajeController.text,
                            );
                            if (!context.mounted) return;

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ Mensaje enviado"),
                                backgroundColor: Colors.greenAccent,
                              ),
                            );
                          },
                          child: const Text("Enviar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendSupportMessage(String uid, String message) async {
    await FirebaseFirestore.instance.collection('support_messages').add({
      'uid': uid,
      'message': message,
      'createdAt': Timestamp.now(),
    });
  }

  Widget _buildInput(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class AnimatedMenuButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AnimatedMenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton> {
  bool _pressed = false;
  bool _hovered = false;

  void _setPressed(bool value) {
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) {
          _setPressed(false);
          widget.onTap();
        },
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          scale: _pressed ? 0.92 : (_hovered ? 1.03 : 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _pressed
                  ? Colors.white.withValues(alpha: 0.12)
                  : (_hovered
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _pressed
                    ? const Color(0xFF64B5F6).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: const Color(0xFF64B5F6),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white24,
                        size: 14,
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

class AnimatedLogoutButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const AnimatedLogoutButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<AnimatedLogoutButton> createState() => _AnimatedLogoutButtonState();
}

class _AnimatedLogoutButtonState extends State<AnimatedLogoutButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        scale: _pressed ? 0.94 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _pressed
                ? Colors.redAccent.withValues(alpha: 0.85)
                : Colors.redAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
  