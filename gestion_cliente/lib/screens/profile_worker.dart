import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_cliente/screens/inicio_worker.dart';
import 'root_page.dart';

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
                    icon: Icons.calendar_month,
                    title: "Mis horarios",
                    onTap: () {
                      if (user != null) {
                        _showSchedules(context, user.uid);
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

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const RootPage()),
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
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(color: Colors.blueAccent);
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        final nombre = data['nombre'] ?? "";
        final apellidos = data['apellidos'] ?? "";

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
                      .collection('users')
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
        .collection('users')
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
                        .collection('users')
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

  void _showSchedules(BuildContext context, String uid) {
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
              "Aquí aparecerán los horarios",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _showTasks(BuildContext context, String uid) {
    final controller = TextEditingController();
    final tagController = TextEditingController();
    final searchController = TextEditingController();

    List<String> selectedTags = [];
    String priority = "low";
    String searchText = "";

    // 🎛 filtros nuevos
    String selectedFilter = "none"; // none | priority | tags
    String selectedPriority = "all";
    String selectedTag = "";

    // 🆕 selección múltiple
    Set<String> selectedNotes = {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Mi bloc de notas",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  // 📝 INPUT NOTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Escribe una nota...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🏷 TAG INPUT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Añadir tag...",
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            if (tagController.text.trim().isEmpty) return;

                            setState(() {
                              selectedTags.add(tagController.text.trim());
                            });

                            tagController.clear();
                          },
                        ),
                      ],
                    ),
                  ),

                  // 🏷 TAGS VISUALES
                  Wrap(
                    spacing: 6,
                    children: selectedTags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.blueAccent.withValues(
                              alpha: 0.2,
                            ),
                            labelStyle: const TextStyle(color: Colors.white),
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                            onDeleted: () {
                              setState(() {
                                selectedTags.remove(tag);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),

                  // PRIORIDAD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButton<String>(
                      value: priority,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: "low", child: Text("Baja")),
                        DropdownMenuItem(value: "medium", child: Text("Media")),
                        DropdownMenuItem(value: "high", child: Text("Alta")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          priority = value!;
                        });
                      },
                    ),
                  ),

                  // 🚀 BOTÓN CREAR NOTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (controller.text.trim().isEmpty) return;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('notes')
                              .add({
                                'text': controller.text.trim(),
                                'createdAt': FieldValue.serverTimestamp(),
                                'done': false,
                                'tags': selectedTags,
                                'priority': priority,
                              });

                          controller.clear();
                          selectedTags = [];
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Crear nota"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔍 BUSCADOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        setState(() {
                          searchText = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Buscar notas...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🎛 BOTONES FILTRO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = "priority";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedFilter == "priority"
                                  ? Colors.blueAccent
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                            child: const Text("Prioridad"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = "tags";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedFilter == "tags"
                                  ? Colors.blueAccent
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                            child: const Text("Tags"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔽 FILTRO PRIORIDAD
                  if (selectedFilter == "priority")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: "all", child: Text("Todas")),
                          DropdownMenuItem(value: "low", child: Text("Baja")),
                          DropdownMenuItem(
                            value: "medium",
                            child: Text("Media"),
                          ),
                          DropdownMenuItem(value: "high", child: Text("Alta")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                    ),

                  // 🔽 FILTRO TAGS
                  if (selectedFilter == "tags")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .collection('notes')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final docs = snapshot.data!.docs;
                          final allTags = <String>{};

                          for (var doc in docs) {
                            final tags = (doc['tags'] ?? []) as List;
                            allTags.addAll(tags.cast<String>());
                          }

                          return Wrap(
                            spacing: 6,
                            children: allTags.map((tag) {
                              return ChoiceChip(
                                label: Text(tag),
                                selected: selectedTag == tag,
                                onSelected: (_) {
                                  setState(() {
                                    selectedTag = tag;
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),

                  // 🆕 BOTÓN BORRAR SELECCIONADAS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: Text(
                          "Borrar seleccionadas (${selectedNotes.length})",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedNotes.isEmpty
                              ? Colors.grey
                              : Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: selectedNotes.isEmpty
                            ? null
                            : () async {
                                for (final id in selectedNotes) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .collection('notes')
                                      .doc(id)
                                      .delete();
                                }

                                setState(() {
                                  selectedNotes.clear();
                                });
                              },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 📋 LISTA
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('notes')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final notes = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final data =
                                notes[index].data() as Map<String, dynamic>;

                            final text = (data['text'] ?? '').toLowerCase();
                            final tags = (data['tags'] ?? []) as List;
                            final priority = (data['priority'] ?? '');
                            final done = data['done'] ?? false;

                            if (searchText.isNotEmpty &&
                                !text.contains(searchText)) {
                              return const SizedBox.shrink();
                            }

                            if (selectedFilter == "priority") {
                              if (selectedPriority != "all" &&
                                  priority != selectedPriority) {
                                return const SizedBox.shrink();
                              }
                            }

                            if (selectedFilter == "tags") {
                              if (selectedTag.isNotEmpty &&
                                  !tags.contains(selectedTag)) {
                                return const SizedBox.shrink();
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedNotes.contains(
                                      notes[index].id,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedNotes.add(notes[index].id);
                                        } else {
                                          selectedNotes.remove(notes[index].id);
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      done
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: done
                                          ? Colors.greenAccent
                                          : Colors.white54,
                                    ),
                                    onPressed: () {
                                      notes[index].reference.update({
                                        'done': !done,
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      data['text'] ?? '',
                                      style: TextStyle(
                                        color: done
                                            ? Colors.white38
                                            : Colors.white,
                                        decoration: done
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      notes[index].reference.delete();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
