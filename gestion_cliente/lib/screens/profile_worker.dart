import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/inicio_worker.dart';
import 'login_screen.dart';

class WorkerProfilePage extends StatelessWidget {
  const WorkerProfilePage({super.key});

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
    double containerWidth = screenWidth > 700 ? 500 : screenWidth * 0.9;

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Perfil trabajador",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => InicioWorker()),
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
                    title: "Editar perfil",
                    onTap: () {
                      if (user != null) {
                        _showEditWorkerProfile(context, user.uid);
                      }
                    },
                  ),

                 AnimatedMenuButton(
                    icon: Icons.mail_outline,
                    title: "Mis mensajes",
                    onTap: () {
                      if (user != null) {
                        _showInternalMessages(context, user.uid);
                      }
                    },
                  ),
                  
                  AnimatedMenuButton(
                    icon: Icons.work_outline,
                    title: "Mis tareas",
                    onTap: () {
                      if (user != null) {
                        _showTasks(context, user.uid);
                      }
                    },
                  ),

                  AnimatedMenuButton(
                    icon: Icons.history,
                    title: "Historial de fichajes",
                    onTap: () {
                      if (user != null) {
                        _showCheckHistory(context, user.uid);
                      }
                    },
                  ),

                  AnimatedMenuButton(
                    icon: Icons.email_outlined,
                    title: "Contactar administrador",
                    onTap: () {
                      if (user != null) {
                        _showContactAdmin(context, user.uid);
                     }
                    },
                  ),

                  const SizedBox(height: 25),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Divider(color: Colors.white10),
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

  Widget _buildHeader(User? user) {
    if (user == null) return const SizedBox();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(color: Colors.blueAccent);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final nombre = data['nombre'] ?? "";
        final apellidos = data['apellidos'] ?? "";
        final puesto = data['puesto'] ?? "Trabajador";
        final empresa = data['empresa'] ?? "";
        final avatar = data['avatar'];

        String iniciales = "W";

        if (nombre.isNotEmpty) {
          iniciales = nombre[0].toUpperCase();
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                _showAvatarPicker(context, user.uid);
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF64B5F6),
                  backgroundImage: avatar != null ? AssetImage(avatar) : null,
                  child: avatar == null
                      ? Text(
                          iniciales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "$nombre $apellidos",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              puesto,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 5),

            Text(empresa, style: const TextStyle(color: Colors.white38)),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.greenAccent, size: 18),

                  SizedBox(width: 8),

                  Text(
                    "Trabajador activo",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPicker(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: avatarOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              final avatar = avatarOptions[index];

              return GestureDetector(
                onTap: () async {
                  await FirebaseFirestore.instance
                      .collection('workers')
                      .doc(uid)
                      .set({'avatar': avatar}, SetOptions(merge: true));

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                child: CircleAvatar(backgroundImage: AssetImage(avatar)),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditWorkerProfile(BuildContext context, String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('workers')
        .doc(uid)
        .get();

    final data = doc.data() ?? {};

    final nameController = TextEditingController(text: data['nombre'] ?? '');

    final lastController = TextEditingController(text: data['apellidos'] ?? '');

    final phoneController = TextEditingController(text: data['telefono'] ?? '');

    final addressController = TextEditingController(
      text: data['direccion'] ?? '',
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInput(nameController, "Nombre"),
              _buildInput(lastController, "Apellidos"),
              _buildInput(phoneController, "Teléfono"),
              _buildInput(addressController, "Dirección"),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('workers')
                        .doc(uid)
                        .set({
                          'nombre': nameController.text.trim(),
                          'apellidos': lastController.text.trim(),
                          'telefono': phoneController.text.trim(),
                          'direccion': addressController.text.trim(),
                        }, SetOptions(merge: true));

                    if (!context.mounted) return;

                    Navigator.pop(context);
                  },
                  child: const Text("Guardar cambios"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInternalMessages(BuildContext context, String uid) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('workers')
              .doc(uid)
              .collection('mensajes')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No tienes mensajes",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data =
                    docs[index].data() as Map<String, dynamic>;

                final asunto = data['asunto'] ?? 'Sin asunto';
                final mensaje = data['mensaje'] ?? '';
                final remitente = data['remitente'] ?? 'Administrador';

                DateTime? fecha;

                if (data['createdAt'] != null) {
                  fecha =
                      (data['createdAt'] as Timestamp).toDate();
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF64B5F6),
                      child: Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      asunto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        Text(
                          mensaje,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "De: $remitente",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                          ),
                        ),

                        if (fecha != null)
                          Text(
                            "${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}

  void _showTasks(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: const Center(
            child: Text(
              "Aquí aparecerán las tareas",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

     void _showContactAdmin(BuildContext context, String uid) async {
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
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
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enviar correo al administrador",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildInput(subjectController, "Asunto"),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: messageController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Escribe tu mensaje...",
                  hintStyle:
                      const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor:
                      Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Enviar correo"),
                onPressed: () async {
                  if (subjectController.text.trim().isEmpty ||
                      messageController.text.trim().isEmpty) {
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('emails_admin')
                      .add({
                    'workerId': uid,
                    'subject':
                        subjectController.text.trim(),
                    'message':
                        messageController.text.trim(),
                    'createdAt':
                        FieldValue.serverTimestamp(),
                    'status': 'pendiente',
                  });

                  if (!context.mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Correo enviado al administrador",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

  void _showCheckHistory(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workers')
                .doc(uid)
                .collection('fichajes')
                .orderBy('fecha', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }



           
              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  final fecha = (data['fecha'] as Timestamp).toDate();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.access_time,
                        color: Colors.greenAccent,
                      ),
                      title: Text(
                        "${fecha.day}/${fecha.month}/${fecha.year}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${fecha.hour}:${fecha.minute}",
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
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
            borderRadius: BorderRadius.circular(14),
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
  bool pressed = false;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),

        onTapUp: (_) {
          setState(() => pressed = false);
          widget.onTap();
        },

        onTapCancel: () => setState(() => pressed = false),

        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: pressed ? 0.96 : (hovering ? 1.04 : 1.0),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: hovering
                  ? Colors.blueAccent.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                      Icon(widget.icon, color: const Color(0xFF64B5F6)),

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
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),

      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },

      onTapCancel: () => setState(() => pressed = false),

      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: pressed ? 0.95 : 1.0,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),

          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(20),
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
