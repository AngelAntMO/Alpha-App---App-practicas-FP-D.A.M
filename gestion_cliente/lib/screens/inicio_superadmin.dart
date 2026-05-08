import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── MODELOS ───────────────────────────────────────────────────────────────

class Servicio {
  String nombre;
  double precio;
  int duracionMinutos;
  String descripcion;
  bool activo;

  Servicio({
    required this.nombre,
    required this.precio,
    required this.duracionMinutos,
    required this.descripcion,
    required this.activo,
  });
}

class Negocio {
  final String nombre;
  final IconData icono;
  final Color color;
  final List<Servicio> servicios;

  const Negocio({
    required this.nombre,
    required this.icono,
    required this.color,
    required this.servicios,
  });
}

class Trabajador {
  String nombre;
  String email;
  String telefono;
  bool activo;
  Map<String, List<String>> negociosYServicios;
  Map<String, bool> esAdminEn;

  Trabajador({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.activo,
    required this.negociosYServicios,
    required this.esAdminEn,
  });

  List<String> get negociosAsignados => negociosYServicios.keys.toList();
  List<String> serviciosEnNegocio(String negocio) => negociosYServicios[negocio] ?? [];
  bool isAdminEn(String negocio) => esAdminEn[negocio] ?? false;
}

class Usuario {
  String nombre;
  String email;
  String telefono;
  bool activo;
  Map<String, List<String>> negociosYServicios;

  Usuario({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.activo,
    required this.negociosYServicios,
  });

  List<String> get negociosAsignados => negociosYServicios.keys.toList();
}

// ─── DATOS ─────────────────────────────────────────────────────────────────

final List<Negocio> negocios = [
  Negocio(
    nombre: 'Academia',
    icono: Icons.school,
    color: Color(0xFF3B82F6),
    servicios: [
      Servicio(
        nombre: 'Inglés',
        precio: 30,
        duracionMinutos: 60,
        descripcion: 'Clases de inglés todos los niveles.',
        activo: true,
      ),
      Servicio(
        nombre: 'Matemáticas',
        precio: 25,
        duracionMinutos: 60,
        descripcion: 'Clases de matemáticas y álgebra.',
        activo: true,
      ),
      Servicio(
        nombre: 'Repaso',
        precio: 20,
        duracionMinutos: 45,
        descripcion: 'Repaso general para exámenes.',
        activo: false,
      ),
    ],
  ),
  Negocio(
    nombre: 'Fisioterapeuta',
    icono: Icons.healing,
    color: Color(0xFF10B981),
    servicios: [
      Servicio(
        nombre: 'Especialista 1',
        precio: 50,
        duracionMinutos: 45,
        descripcion: 'Fisioterapia deportiva.',
        activo: true,
      ),
      Servicio(
        nombre: 'Especialista 2',
        precio: 50,
        duracionMinutos: 45,
        descripcion: 'Rehabilitación postoperatoria.',
        activo: true,
      ),
      Servicio(
        nombre: 'Especialista 3',
        precio: 55,
        duracionMinutos: 60,
        descripcion: 'Fisioterapia neurológica.',
        activo: true,
      ),
      Servicio(
        nombre: 'Especialista 4',
        precio: 45,
        duracionMinutos: 45,
        descripcion: 'Masaje terapéutico.',
        activo: false,
      ),
      Servicio(
        nombre: 'Especialista 5',
        precio: 60,
        duracionMinutos: 60,
        descripcion: 'Osteopatía.',
        activo: true,
      ),
    ],
  ),
  Negocio(
    nombre: 'Gimnasio',
    icono: Icons.fitness_center,
    color: Color(0xFFF59E0B),
    servicios: [
      Servicio(
        nombre: 'Sala Fitness',
        precio: 15,
        duracionMinutos: 60,
        descripcion: 'Acceso libre a sala de máquinas.',
        activo: true,
      ),
      Servicio(
        nombre: 'Spinning',
        precio: 10,
        duracionMinutos: 45,
        descripcion: 'Clase grupal de ciclismo indoor.',
        activo: true,
      ),
      Servicio(
        nombre: 'CrossTraining',
        precio: 12,
        duracionMinutos: 60,
        descripcion: 'Entrenamiento funcional de alta intensidad.',
        activo: true,
      ),
      Servicio(
        nombre: 'Boxeo',
        precio: 12,
        duracionMinutos: 60,
        descripcion: 'Técnica y cardio de boxeo.',
        activo: false,
      ),
      Servicio(
        nombre: 'Zumba',
        precio: 8,
        duracionMinutos: 45,
        descripcion: 'Baile fitness divertido.',
        activo: true,
      ),
    ],
  ),
  Negocio(
    nombre: 'Peluquería',
    icono: Icons.content_cut,
    color: Color(0xFFEC4899),
    servicios: [
      Servicio(
        nombre: 'Corte Caballeros',
        precio: 15,
        duracionMinutos: 30,
        descripcion: 'Corte clásico o moderno para hombre.',
        activo: true,
      ),
      Servicio(
        nombre: 'Corte Dama',
        precio: 25,
        duracionMinutos: 45,
        descripcion: 'Corte y peinado para mujer.',
        activo: true,
      ),
      Servicio(
        nombre: 'Coloración',
        precio: 60,
        duracionMinutos: 120,
        descripcion: 'Tinte completo con productos profesionales.',
        activo: true,
      ),
      Servicio(
        nombre: 'Tratamiento Capilar',
        precio: 35,
        duracionMinutos: 60,
        descripcion: 'Hidratación y nutrición del cabello.',
        activo: true,
      ),
      Servicio(
        nombre: 'Barbería',
        precio: 18,
        duracionMinutos: 30,
        descripcion: 'Arreglo de barba y bigote.',
        activo: false,
      ),
    ],
  ),
  Negocio(
    nombre: 'Yoga',
    icono: Icons.self_improvement,
    color: Color(0xFF8B5CF6),
    servicios: [
      Servicio(
        nombre: 'Yoga Suave',
        precio: 10,
        duracionMinutos: 60,
        descripcion: 'Posturas suaves para principiantes.',
        activo: true,
      ),
      Servicio(
        nombre: 'Vinyasa',
        precio: 12,
        duracionMinutos: 60,
        descripcion: 'Flujo dinámico de posturas.',
        activo: true,
      ),
      Servicio(
        nombre: 'Power Yoga',
        precio: 12,
        duracionMinutos: 60,
        descripcion: 'Yoga de alta intensidad y fuerza.',
        activo: true,
      ),
      Servicio(
        nombre: 'Meditación',
        precio: 8,
        duracionMinutos: 45,
        descripcion: 'Técnicas de mindfulness y relajación.',
        activo: true,
      ),
    ],
  ),
];

List<Trabajador> trabajadores = [
  Trabajador(
    nombre: 'Carlos Ruiz',
    email: 'carlos@academia.com',
    telefono: '612 345 678',
    negocioNombre: 'Academia',
    activo: true,
    serviciosAsignados: ['Inglés', 'Repaso'],
  ),
  Trabajador(
    nombre: 'Lucía Fernández',
    email: 'lucia@academia.com',
    telefono: '623 456 789',
    negocioNombre: 'Academia',
    activo: true,
    serviciosAsignados: ['Matemáticas'],
  ),
  Trabajador(
    nombre: 'Marta González',
    email: 'marta@fisio.com',
    telefono: '634 567 890',
    negocioNombre: 'Fisioterapeuta',
    activo: true,
    serviciosAsignados: ['Especialista 1', 'Especialista 3'],
  ),
  Trabajador(
    nombre: 'Javier Moreno',
    email: 'javier@fisio.com',
    telefono: '645 678 901',
    negocioNombre: 'Fisioterapeuta',
    activo: false,
    serviciosAsignados: ['Especialista 4'],
  ),
  Trabajador(
    nombre: 'Ana Torres',
    email: 'ana@fisio.com',
    telefono: '656 789 012',
    negocioNombre: 'Fisioterapeuta',
    activo: true,
    serviciosAsignados: ['Especialista 2', 'Especialista 5'],
  ),
  Trabajador(
    nombre: 'Pedro Sánchez',
    email: 'pedro@gimnasio.com',
    telefono: '667 890 123',
    negocioNombre: 'Gimnasio',
    activo: true,
    serviciosAsignados: ['Sala Fitness', 'CrossTraining'],
  ),
  Trabajador(
    nombre: 'Elena Díaz',
    email: 'elena@gimnasio.com',
    telefono: '678 901 234',
    negocioNombre: 'Gimnasio',
    activo: true,
    serviciosAsignados: ['Spinning', 'Zumba'],
  ),
  Trabajador(
    nombre: 'Roberto Jiménez',
    email: 'roberto@gimnasio.com',
    telefono: '689 012 345',
    negocioNombre: 'Gimnasio',
    activo: false,
    serviciosAsignados: ['Boxeo'],
  ),
  Trabajador(
    nombre: 'Isabel López',
    email: 'isabel@peluqueria.com',
    telefono: '690 123 456',
    negocioNombre: 'Peluquería',
    activo: true,
    serviciosAsignados: ['Corte Dama', 'Coloración', 'Tratamiento Capilar'],
  ),
  Trabajador(
    nombre: 'Miguel Romero',
    email: 'miguel@peluqueria.com',
    telefono: '601 234 567',
    negocioNombre: 'Peluquería',
    activo: true,
    serviciosAsignados: ['Corte Caballeros', 'Barbería'],
  ),
  Trabajador(
    nombre: 'Sofía Martín',
    email: 'sofia@yoga.com',
    telefono: '612 345 670',
    negocioNombre: 'Yoga',
    activo: true,
    serviciosAsignados: ['Yoga Suave', 'Meditación'],
  ),
  Trabajador(
    nombre: 'Daniel Herrera',
    email: 'daniel@yoga.com',
    telefono: '623 456 781',
    negocioNombre: 'Yoga',
    activo: true,
    serviciosAsignados: ['Vinyasa', 'Power Yoga'],
  ),
];

List<Usuario> usuarios = [
  Usuario(
    nombre: 'Laura Pérez',
    email: 'laura@gmail.com',
    telefono: '611 111 111',
    activo: true,
    negocioNombre: 'Academia',
  ),
  Usuario(
    nombre: 'Pablo García',
    email: 'pablo@gmail.com',
    telefono: '622 222 222',
    activo: true,
    negocioNombre: 'Gimnasio',
  ),
  Usuario(
    nombre: 'Carmen Ruiz',
    email: 'carmen@gmail.com',
    telefono: '633 333 333',
    activo: true,
    negocioNombre: 'Yoga',
  ),
  Usuario(
    nombre: 'Andrés López',
    email: 'andres@gmail.com',
    telefono: '644 444 444',
    activo: false,
    negocioNombre: 'Fisioterapeuta',
  ),
  Usuario(
    nombre: 'María Sánchez',
    email: 'maria@gmail.com',
    telefono: '655 555 555',
    activo: true,
    negocioNombre: 'Peluquería',
  ),
  Usuario(
    nombre: 'Francisco Torres',
    email: 'fran@gmail.com',
    telefono: '666 666 666',
    activo: true,
    negocioNombre: 'Gimnasio',
  ),
  Usuario(
    nombre: 'Beatriz Moreno',
    email: 'bea@gmail.com',
    telefono: '677 777 777',
    activo: false,
    negocioNombre: 'Academia',
  ),
  Usuario(
    nombre: 'Sergio Díaz',
    email: 'sergio@gmail.com',
    telefono: '688 888 888',
    activo: true,
    negocioNombre: 'Yoga',
  ),
];

// ─── HELPERS ───────────────────────────────────────────────────────────────

Negocio? _negocioPorNombre(String nombre) {
  try { return negocios.firstWhere((n) => n.nombre == nombre); } catch (_) { return null; }
}

// ─── SELECTOR DE NEGOCIOS ──────────────────────────────────────────────────

class _SelectorNegocios extends StatelessWidget {
  final int seleccionado;
  final ValueChanged<int> onSeleccionado;

  const _SelectorNegocios({
    required this.seleccionado,
    required this.onSeleccionado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: List.generate(negocios.length, (i) {
          final n = negocios[i];
          final selected = i == seleccionado;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < negocios.length - 1 ? 6 : 0),
              child: GestureDetector(
                onTap: () => onSeleccionado(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.45)
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        n.icono,
                        color: selected ? n.color : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white60,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(n.icono, color: selected ? n.color : Colors.white54, size: 20),
                    const SizedBox(height: 4),
                    Text(n.nombre, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: selected ? Colors.white : Colors.white60, fontSize: 9, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  ]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── PANTALLA PRINCIPAL ────────────────────────────────────────────────────

class InicioSuperAdmin extends StatefulWidget {
  const InicioSuperAdmin({super.key});
  @override
  State<InicioSuperAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioSuperAdmin> {
  int _tabIndex = 0;

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
          backgroundColor: Colors.transparent, elevation: 0,
          title: const Text('Panel Super Administrador', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.white,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _buildTab(0, Icons.business, 'Negocio'),
                  _buildTab(1, Icons.engineering, 'Trabajadores'),
                  _buildTab(2, Icons.people, 'Usuarios'),
                  _buildTab(3, Icons.calendar_today, 'Reservas'),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: const [
                  _NegocioTab(),
                  _TrabajadoresTab(),
                  _UsuariosTab(),
                  _PlaceholderTab(label: 'Reservas'),
                ],
              ),
            ),
          ],
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(children: [
              _buildTab(0, Icons.business, 'Negocio'),
              _buildTab(1, Icons.engineering, 'Trabajadores'),
              _buildTab(2, Icons.people, 'Usuarios'),
              _buildTab(3, Icons.calendar_today, 'Reservas'),
            ]),
          ),
          Expanded(
            child: IndexedStack(index: _tabIndex, children: const [
              _NegocioTab(),
              _TrabajadoresTab(),
              _UsuariosTab(),
              _PlaceholderTab(label: 'Reservas'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final selected = _tabIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () => setState(() => _tabIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : Colors.white60,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white60,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: selected ? Colors.white : Colors.white60, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── MODAL HELPERS ─────────────────────────────────────────────────────────

Future<void> _mostrarDialogoNuevoServicio(
  BuildContext context,
  Negocio negocio,
  VoidCallback onCreado,
) async {
  final nombreCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  final duracionCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool activo = true;
  final color = negocio.color;

Widget _modalHandle() => Center(child: Container(width: 40, height: 4,
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))));

Widget _modalTitulo(IconData icon, Color color, String titulo) =>
    Row(children: [
      Icon(icon, color: color, size: 22), const SizedBox(width: 10),
      Expanded(child: Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
    ]);

Widget _switchModal(String label, bool value, Color color, ValueChanged<bool> onChanged) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.15))),
      child: SwitchListTile(contentPadding: EdgeInsets.zero, dense: true,
          title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          value: value, activeColor: color, onChanged: onChanged),
    );

Widget _botonesModal(Color color, {required VoidCallback onCancelar, required VoidCallback onConfirmar, required String labelConfirmar}) =>
    Row(children: [
      Expanded(child: OutlinedButton(onPressed: onCancelar,
          style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: BorderSide(color: Colors.white.withValues(alpha: 0.3)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Cancelar'))),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: ElevatedButton(onPressed: onConfirmar,
          style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
          child: Text(labelConfirmar, style: const TextStyle(fontWeight: FontWeight.w600)))),
    ]);

Widget _fieldModal(String label, TextEditingController ctrl, IconData icon, Color accent, {bool isNumber = false, int maxLines = 1}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      TextFormField(controller: ctrl, maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDeco(icon, accent)),
    ]);

// ─── WIDGET SELECTOR NEGOCIOS+SERVICIOS (reutilizable en modales) ──────────

Widget _negociosServiciosSelector({
  required Map<String, List<String>> negociosYServicios,
  Map<String, bool>? esAdminEn,
  required StateSetter set,
  bool showAdmin = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: negocios.map((n) {
      final asignado = negociosYServicios.containsKey(n.nombre);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => set(() {
            if (asignado) {
              negociosYServicios.remove(n.nombre);
              esAdminEn?.remove(n.nombre);
            } else {
              negociosYServicios[n.nombre] = [];
              if (showAdmin) esAdminEn?[n.nombre] = false;
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: asignado ? n.color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: asignado ? n.color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(children: [
              Icon(asignado ? Icons.check_circle : Icons.radio_button_unchecked, color: asignado ? n.color : Colors.white38, size: 18),
              const SizedBox(width: 8),
              Icon(n.icono, color: asignado ? n.color : Colors.white38, size: 16),
              const SizedBox(width: 6),
              Text(n.nombre, style: TextStyle(color: asignado ? Colors.white : Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
              if (showAdmin && asignado && esAdminEn != null) ...[
                const Spacer(),
                Icon(Icons.shield, color: (esAdminEn[n.nombre] ?? false) ? Colors.amber : Colors.white24, size: 14),
                const SizedBox(width: 4),
                Text((esAdminEn[n.nombre] ?? false) ? 'Admin' : 'Staff',
                    style: TextStyle(color: (esAdminEn[n.nombre] ?? false) ? Colors.amber : Colors.white38, fontSize: 11)),
              ],
            ]),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Título
              Row(
                children: [
                  Icon(negocio.icono, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Nuevo servicio · ${negocio.nombre}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _fieldModal(
                'Nombre del servicio',
                nombreCtrl,
                Icons.label,
                color,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _fieldModal(
                      'Precio (€)',
                      precioCtrl,
                      Icons.euro,
                      color,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _fieldModal(
                      'Duración (min)',
                      duracionCtrl,
                      Icons.timer,
                      color,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _fieldModal(
                'Descripción',
                descCtrl,
                Icons.description,
                color,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Activo desde el inicio',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  value: activo,
                  activeThumbColor: color,
                  onChanged: (v) => setModalState(() => activo = v),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nombreCtrl.text.trim().isEmpty) return;
                        negocio.servicios.add(
                          Servicio(
                            nombre: nombreCtrl.text.trim(),
                            precio: double.tryParse(precioCtrl.text) ?? 0,
                            duracionMinutos:
                                int.tryParse(duracionCtrl.text) ?? 60,
                            descripcion: descCtrl.text.trim(),
                            activo: activo,
                          ),
                        );
                        Navigator.pop(ctx);
                        onCreado();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Crear servicio',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  nombreCtrl.dispose();
  precioCtrl.dispose();
  duracionCtrl.dispose();
  descCtrl.dispose();
}

// ─── MODAL NUEVO TRABAJADOR ────────────────────────────────────────────────

Future<void> _mostrarDialogoNuevoTrabajador(
  BuildContext context,
  Negocio negocio,
  VoidCallback onCreado,
) async {
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  bool activo = true;
  List<String> serviciosSeleccionados = [];
  final color = negocio.color;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(negocio.icono, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Nuevo trabajador · ${negocio.nombre}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _fieldModal('Nombre completo', nombreCtrl, Icons.person, color),
              const SizedBox(height: 12),
              _fieldModal('Email', emailCtrl, Icons.email, color),
              const SizedBox(height: 12),
              _fieldModal('Teléfono', telCtrl, Icons.phone, color),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Activo desde el inicio',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  value: activo,
                  activeThumbColor: color,
                  onChanged: (v) => setModalState(() => activo = v),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Servicios asignados',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...negocio.servicios.map((s) {
                final sel = serviciosSeleccionados.contains(s.nombre);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () => setModalState(() {
                      if (sel) {
                        serviciosSeleccionados.remove(s.nombre);
                      } else {
                        serviciosSeleccionados.add(s.nombre);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? color.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel
                              ? color.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sel
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: sel ? color : Colors.white38,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            s.nombre,
                            style: TextStyle(
                              color: sel ? Colors.white : Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nombreCtrl.text.trim().isEmpty) return;
                        trabajadores.add(
                          Trabajador(
                            nombre: nombreCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            telefono: telCtrl.text.trim(),
                            negocioNombre: negocio.nombre,
                            activo: activo,
                            serviciosAsignados: List.from(
                              serviciosSeleccionados,
                            ),
                          ),
                        );
                        Navigator.pop(ctx);
                        onCreado();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Añadir trabajador',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )),
  );

  nombreCtrl.dispose();
  emailCtrl.dispose();
  telCtrl.dispose();
}

// ─── MODAL GESTIONAR ROLES ─────────────────────────────────────────────────

Future<void> _mostrarDialogoNuevoUsuario(
  BuildContext context,
  Negocio negocio,
  VoidCallback onCreado,
) async {
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  bool activo = true;
  final color = negocio.color;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(negocio.icono, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Nuevo usuario · ${negocio.nombre}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _fieldModal('Nombre completo', nombreCtrl, Icons.person, color),
              const SizedBox(height: 12),
              _fieldModal('Email', emailCtrl, Icons.email, color),
              const SizedBox(height: 12),
              _fieldModal('Teléfono', telCtrl, Icons.phone, color),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text(
                    'Activo desde el inicio',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  value: activo,
                  activeThumbColor: color,
                  onChanged: (v) => setModalState(() => activo = v),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nombreCtrl.text.trim().isEmpty) return;
                        usuarios.add(
                          Usuario(
                            nombre: nombreCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            telefono: telCtrl.text.trim(),
                            activo: activo,
                            negocioNombre: negocio.nombre,
                          ),
                        );
                        Navigator.pop(ctx);
                        onCreado();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Añadir usuario',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )),
  );
}

// ─── MODAL NUEVO USUARIO GLOBAL ────────────────────────────────────────────

  nombreCtrl.dispose();
  emailCtrl.dispose();
  telCtrl.dispose();
}

// ─── FIELD PARA MODALES ────────────────────────────────────────────────────

Widget _fieldModal(
  String label,
  TextEditingController ctrl,
  IconData icon,
  Color accent, {
  bool isNumber = false,
  int maxLines = 1,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
    const SizedBox(height: 4),
    TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: _inputDeco(icon, accent),
    ),
  ],
);

// ─── BOTÓN AÑADIR ──────────────────────────────────────────────────────────

Widget _botonAnadir({
  required Color color,
  required String label,
  required VoidCallback onTap,
}) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
  child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  ),
);

// ─── TAB NEGOCIO ───────────────────────────────────────────────────────────

class _NegocioTab extends StatefulWidget {
  const _NegocioTab();
  @override
  State<_NegocioTab> createState() => _NegocioTabState();
}

class _NegocioTabState extends State<_NegocioTab> {
  int _negocioSeleccionado = 0;

  void _confirmarEliminarServicio(Servicio s, Negocio negocio) {
    showDialog(
      context: context,
      builder: (_) => _dialogConfirm(
        context: context,
        titulo: 'Eliminar servicio',
        mensaje: '¿Eliminar "${s.nombre}" de ${negocio.nombre}? Esta acción no se puede deshacer.',
        onConfirm: () {
          setState(() => negocio.servicios.remove(s));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final negocio = negocios[_negocioSeleccionado];
    return Column(
      children: [
        _SelectorNegocios(
          seleccionado: _negocioSeleccionado,
          onSeleccionado: (i) => setState(() => _negocioSeleccionado = i),
        ),
        _botonAnadir(
          color: negocio.color,
          label: 'Añadir servicio a ${negocio.nombre}',
          onTap: () => _mostrarDialogoNuevoServicio(
            context,
            negocio,
            () => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: negocio.servicios.length,
            itemBuilder: (context, i) => _ServicioExpansion(
              key: ValueKey(negocio.servicios[i]),
              servicio: negocio.servicios[i],
              negocio: negocio,
              onGuardado: () => setState(() {}),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ─── SERVICIO EXPANSION ────────────────────────────────────────────────────

class _ServicioExpansion extends StatefulWidget {
  final Servicio servicio;
  final Negocio negocio;
  final VoidCallback onGuardado;
  final VoidCallback onEliminar;

  const _ServicioExpansion({
    required Key key,
    required this.servicio,
    required this.negocio,
    required this.onGuardado,
    required this.onEliminar,
  }) : super(key: key);

  @override
  State<_ServicioExpansion> createState() => _ServicioExpansionState();
}

class _ServicioExpansionState extends State<_ServicioExpansion> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl, _precioCtrl, _duracionCtrl, _descCtrl;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant _ServicioExpansion old) {
    super.didUpdateWidget(old);
    if (old.servicio != widget.servicio) {
      _nombreCtrl.dispose();
      _precioCtrl.dispose();
      _duracionCtrl.dispose();
      _descCtrl.dispose();
      _reset();
    }
  }

  void _reset() {
    final s = widget.servicio;
    _nombreCtrl = TextEditingController(text: s.nombre);
    _precioCtrl = TextEditingController(text: s.precio.toStringAsFixed(0));
    _duracionCtrl = TextEditingController(text: s.duracionMinutos.toString());
    _descCtrl = TextEditingController(text: s.descripcion);
    _activo = s.activo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _duracionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final s = widget.servicio;
    s.nombre = _nombreCtrl.text;
    s.precio = double.tryParse(_precioCtrl.text) ?? s.precio;
    s.duracionMinutos = int.tryParse(_duracionCtrl.text) ?? s.duracionMinutos;
    s.descripcion = _descCtrl.text;
    s.activo = _activo;
    setState(() => _expandido = false);
    widget.onGuardado();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Servicio guardado'),
        backgroundColor: widget.negocio.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelar() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _duracionCtrl.dispose();
    _descCtrl.dispose();
    _reset();
    setState(() => _expandido = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.servicio;
    final color = widget.negocio.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expandido
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: _expandido ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandido = !_expandido),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.negocio.icono, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${s.duracionMinutos} min · ${s.precio.toStringAsFixed(0)}€',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _badge(s.activo),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expandido ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _form(color),
              crossFadeState: _expandido
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(Color color) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
        const SizedBox(height: 14),
        _field('Nombre', _nombreCtrl, Icons.label, color),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _field(
                'Precio (€)',
                _precioCtrl,
                Icons.euro,
                color,
                isNumber: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                'Duración (min)',
                _duracionCtrl,
                Icons.timer,
                color,
                isNumber: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _field('Descripción', _descCtrl, Icons.description, color, maxLines: 2),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Servicio activo',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            subtitle: Text(
              _activo
                  ? 'Visible para los clientes'
                  : 'Oculto para los clientes',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            value: _activo,
            activeThumbColor: color,
            onChanged: (v) => setState(() => _activo = v),
          ),
        ),
        const SizedBox(height: 14),
        _botonesGuardar(color, onCancelar: _cancelar, onGuardar: _guardar),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color accent, {
    bool isNumber = false,
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: _inputDeco(icon, accent),
      ),
    ],
  );
}

// ─── TAB TRABAJADORES ──────────────────────────────────────────────────────

class _TrabajadoresTab extends StatefulWidget {
  const _TrabajadoresTab();
  @override
  State<_TrabajadoresTab> createState() => _TrabajadoresTabState();
}

class _TrabajadoresTabState extends State<_TrabajadoresTab> {
  int _negocioSeleccionado = 0;

  List<Trabajador> get _filtrados => trabajadores
      .where((t) => t.negocioNombre == negocios[_negocioSeleccionado].nombre)
      .toList();

  void _eliminar(Trabajador t) {
    showDialog(
      context: context,
      builder: (_) => _dialogConfirm(
        context: context,
        titulo: 'Dar de baja trabajador',
        mensaje: '¿Eliminar a ${t.nombre} del sistema?',
        onConfirm: () {
          setState(() => trabajadores.remove(t));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final negocio = negocios[_negocioSeleccionado];
    return Column(
      children: [
        _SelectorNegocios(
          seleccionado: _negocioSeleccionado,
          onSeleccionado: (i) => setState(() => _negocioSeleccionado = i),
        ),
        _botonAnadir(
          color: negocio.color,
          label: 'Añadir trabajador a ${negocio.nombre}',
          onTap: () => _mostrarDialogoNuevoTrabajador(
            context,
            negocio,
            () => setState(() {}),
          ),
        ),
        Expanded(
          child: _filtrados.isEmpty
              ? const Center(
                  child: Text(
                    'No hay trabajadores en este negocio',
                    style: TextStyle(color: Colors.white60),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filtrados.length,
                  itemBuilder: (context, i) {
                    final t = _filtrados[i];
                    return _TrabajadorExpansion(
                      key: ValueKey(t),
                      trabajador: t,
                      negocio: negocio,
                      onEliminado: () => _eliminar(t),
                      onActualizado: () => setState(() {}),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TrabajadorExpansion extends StatefulWidget {
  final Trabajador trabajador;
  final Negocio negocio;
  final VoidCallback onEliminado;
  final VoidCallback onActualizado;

  const _TrabajadorExpansion({required Key key, required this.trabajador, required this.negocio, required this.onEliminado, required this.onActualizado}) : super(key: key);

  @override
  State<_TrabajadorExpansion> createState() => _TrabajadorExpansionState();
}

class _TrabajadorExpansionState extends State<_TrabajadorExpansion> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl, _emailCtrl, _telCtrl;
  late bool _activo;
  late List<String> _servicios;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant _TrabajadorExpansion old) {
    super.didUpdateWidget(old);
    if (old.trabajador != widget.trabajador) {
      _nombreCtrl.dispose();
      _emailCtrl.dispose();
      _telCtrl.dispose();
      _reset();
    }
  }

  void _reset() {
    final t = widget.trabajador;
    _nombreCtrl = TextEditingController(text: t.nombre);
    _emailCtrl = TextEditingController(text: t.email);
    _telCtrl = TextEditingController(text: t.telefono);
    _activo = t.activo;
    _servicios = List.from(t.serviciosAsignados);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final t = widget.trabajador;
    t.nombre = _nombreCtrl.text;
    t.email = _emailCtrl.text;
    t.telefono = _telCtrl.text;
    t.activo = _activo;
    t.serviciosAsignados = List.from(_servicios);
    setState(() => _expandido = false);
    widget.onActualizado();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Trabajador actualizado'),
        backgroundColor: widget.negocio.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelar() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _reset();
    setState(() => _expandido = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trabajador;
    final color = widget.negocio.color;
    final esAdmin = t.isAdminEn(widget.negocio.nombre);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expandido
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: _expandido ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandido = !_expandido),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withValues(alpha: 0.25),
                      child: Text(
                        t.nombre.isNotEmpty ? t.nombre[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.email,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _badge(t.activo),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expandido ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _form(color),
              crossFadeState: _expandido
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(Color color) {
    final todosServicios = widget.negocio.servicios
        .map((s) => s.nombre)
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 14),
          _field('Nombre completo', _nombreCtrl, Icons.person, color),
          const SizedBox(height: 10),
          _field('Email', _emailCtrl, Icons.email, color),
          const SizedBox(height: 10),
          _field('Teléfono', _telCtrl, Icons.phone, color),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Trabajador activo',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              subtitle: Text(
                _activo
                    ? 'Visible en el sistema'
                    : 'Dado de baja temporalmente',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              value: _activo,
              activeThumbColor: color,
              onChanged: (v) => setState(() => _activo = v),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Servicios asignados',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...todosServicios.map((nombre) {
            final asignado = _servicios.contains(nombre);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => setState(() {
                  if (asignado) {
                    _servicios.remove(nombre);
                  } else {
                    _servicios.add(nombre);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: asignado
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: asignado
                          ? color.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        asignado
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: asignado ? color : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        nombre,
                        style: TextStyle(
                          color: asignado ? Colors.white : Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          _botonesConBaja(
            color,
            onBaja: widget.onEliminado,
            onCancelar: _cancelar,
            onGuardar: _guardar,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color accent,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: _inputDeco(icon, accent),
      ),
    ],
  );
}

// ─── TAB USUARIOS ──────────────────────────────────────────────────────────

class _UsuariosTab extends StatefulWidget {
  const _UsuariosTab();
  @override
  State<_UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<_UsuariosTab> {
  int _negocioSeleccionado = 0;
  final TextEditingController _busquedaCtrl = TextEditingController();
  String _textoBusqueda = '';
  // Negocios seleccionados como filtro (vacío = sin filtro)
  Set<String> _filtroNegocios = {};
  bool _mostrarFiltros = false;

  @override
  void dispose() { _busquedaCtrl.dispose(); super.dispose(); }

  List<Usuario> get _usuariosFiltrados {
    List<Usuario> lista = usuarios;

  List<Usuario> get _filtrados => usuarios
      .where((u) => u.negocioNombre == negocios[_negocioSeleccionado].nombre)
      .toList();

  void _eliminar(Usuario u) {
    showDialog(
      context: context,
      builder: (_) => _dialogConfirm(
        context: context,
        titulo: 'Dar de baja usuario',
        mensaje: '¿Eliminar a ${u.nombre}? Esta acción no se puede deshacer.',
        onConfirm: () {
          setState(() => usuarios.remove(u));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final negocio = negocios[_negocioSeleccionado];
    return Column(
      children: [
        _SelectorNegocios(
          seleccionado: _negocioSeleccionado,
          onSeleccionado: (i) => setState(() => _negocioSeleccionado = i),
        ),
        _botonAnadir(
          color: negocio.color,
          label: 'Añadir usuario a ${negocio.nombre}',
          onTap: () => _mostrarDialogoNuevoUsuario(
            context,
            negocio,
            () => setState(() {}),
          ),
        ),
        Expanded(
          child: _filtrados.isEmpty
              ? const Center(
                  child: Text(
                    'No hay usuarios en este negocio',
                    style: TextStyle(color: Colors.white60),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filtrados.length,
                  itemBuilder: (context, i) {
                    final u = _filtrados[i];
                    return _UsuarioExpansion(
                      key: ValueKey(u),
                      usuario: u,
                      negocio: negocio,
                      onEliminado: () => _eliminar(u),
                      onActualizado: () => setState(() {}),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── USUARIO EXPANSION ────────────────────────────────────────────────────

class _UsuarioExpansion extends StatefulWidget {
  final Usuario usuario;
  final Negocio negocio;
  final VoidCallback onEliminado;
  final VoidCallback onActualizado;

  const _UsuarioExpansion({required Key key, required this.usuario, required this.negocio, required this.onEliminado, required this.onActualizado}) : super(key: key);

  @override
  State<_UsuarioExpansion> createState() => _UsuarioExpansionState();
}

class _UsuarioExpansionState extends State<_UsuarioExpansion> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl, _emailCtrl, _telCtrl;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant _UsuarioExpansion old) {
    super.didUpdateWidget(old);
    if (old.usuario != widget.usuario) {
      _nombreCtrl.dispose();
      _emailCtrl.dispose();
      _telCtrl.dispose();
      _reset();
    }
  }

  void _reset() {
    final u = widget.usuario;
    _nombreCtrl = TextEditingController(text: u.nombre);
    _emailCtrl = TextEditingController(text: u.email);
    _telCtrl = TextEditingController(text: u.telefono);
    _activo = u.activo;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    final u = widget.usuario;
    u.nombre = _nombreCtrl.text;
    u.email = _emailCtrl.text;
    u.telefono = _telCtrl.text;
    u.activo = _activo;
    setState(() => _expandido = false);
    widget.onActualizado();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Usuario actualizado'),
        backgroundColor: widget.negocio.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelar() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _reset();
    setState(() => _expandido = false);
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.usuario;
    final color = widget.negocio.color;
    final serviciosEnNegocio = u.negociosYServicios[widget.negocio.nombre] ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expandido
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: _expandido ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandido = !_expandido),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withValues(alpha: 0.25),
                      child: Text(
                        u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            u.email,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _badge(u.activo),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expandido ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _form(color),
              crossFadeState: _expandido
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formUsuario(Color color) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
        const SizedBox(height: 14),
        _field('Nombre completo', _nombreCtrl, Icons.person, color),
        const SizedBox(height: 10),
        _field('Email', _emailCtrl, Icons.email, color),
        const SizedBox(height: 10),
        _field('Teléfono', _telCtrl, Icons.phone, color),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Usuario activo',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            subtitle: Text(
              _activo ? 'Acceso habilitado' : 'Acceso suspendido',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            value: _activo,
            activeThumbColor: color,
            onChanged: (v) => setState(() => _activo = v),
          ),
        ),
        const SizedBox(height: 14),
        _botonesConBaja(
          color,
          onBaja: widget.onEliminado,
          onCancelar: _cancelar,
          onGuardar: _guardar,
        ),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color accent,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: _inputDeco(icon, accent),
      ),
    ],
  );
}

// ─── HELPERS GLOBALES ──────────────────────────────────────────────────────

InputDecoration _inputDeco(IconData icon, Color accent) => InputDecoration(
  isDense: true,
  prefixIcon: Icon(icon, color: Colors.white38, size: 16),
  filled: true,
  fillColor: Colors.white.withValues(alpha: 0.08),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: accent, width: 1.5),
  ),
);

Widget _badge(bool activo) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
  decoration: BoxDecoration(
    color: activo
        ? Colors.green.withValues(alpha: 0.2)
        : Colors.red.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    activo ? 'Activo' : 'Inactivo',
    style: TextStyle(
      color: activo ? Colors.greenAccent : Colors.redAccent,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    ),
  ),
);

Widget _botonesGuardar(
  Color color, {
  required VoidCallback onCancelar,
  required VoidCallback onGuardar,
}) => Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: onCancelar,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      flex: 2,
      child: ElevatedButton(
        onPressed: onGuardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Guardar cambios',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  ],
);

Widget _botonesConBaja(
  Color color, {
  required VoidCallback onBaja,
  required VoidCallback onCancelar,
  required VoidCallback onGuardar,
}) => Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: onBaja,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Dar de baja', style: TextStyle(fontSize: 11)),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: OutlinedButton(
        onPressed: onCancelar,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Cancelar', style: TextStyle(fontSize: 11)),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: ElevatedButton(
        onPressed: onGuardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Guardar',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  ],
);

Widget _dialogConfirm({
  required BuildContext context,
  required String titulo,
  required String mensaje,
  required VoidCallback onConfirm,
}) => AlertDialog(
  backgroundColor: const Color(0xFF1E293B),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  title: Text(titulo, style: const TextStyle(color: Colors.white)),
  content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
    ),
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onConfirm,
      child: const Text('Eliminar'),
    ),
  ],
);

// ─── PLACEHOLDER ───────────────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Sección $label\n(próximamente)',
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white60, fontSize: 16),
    ),
  );
}
