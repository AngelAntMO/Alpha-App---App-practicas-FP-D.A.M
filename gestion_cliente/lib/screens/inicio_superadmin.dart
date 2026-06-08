import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// ─── MODELOS ───────────────────────────────────────────────────────────────

class Clase {
  final String id;
  String nombre;
  String employeeID;
  String negocioID;

  Clase({
    required this.id,
    required this.nombre,
    required this.employeeID,
    required this.negocioID,
  });

  factory Clase.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Clase(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      employeeID: d['employeeID'] ?? '',
      negocioID: d['negocioID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'employeeID': employeeID,
        'negocioID': negocioID,
        'negocioRef': FirebaseFirestore.instance.doc('negocios/$negocioID'),
      };
}

class Worker {
  final String id;
  String nombre;
  String apellidos;
  String telefono;
  String direccion;
  String avatar;
  String rol;

  Worker({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    required this.direccion,
    required this.avatar,
    required this.rol,
  });

  factory Worker.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Worker(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      apellidos: d['apellidos'] ?? '',
      telefono: d['telefono'] ?? '',
      direccion: d['direccion'] ?? '',
      avatar: d['avatar'] ?? '',
      rol: d['rol'] ?? 'worker',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'apellidos': apellidos,
        'telefono': telefono,
        'direccion': direccion,
        'avatar': avatar,
        'rol': rol,
      };

  String get nombreCompleto => '$nombre $apellidos'.trim();
}

class UsuarioApp {
  final String id;
  String nombre;
  String apellidos;
  String email;
  String telefono;
  bool activo;
  String rol;
  List<String> negocios;

  UsuarioApp({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.activo,
    required this.rol,
    required this.negocios,
  });

  factory UsuarioApp.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UsuarioApp(
      id: doc.id,
      nombre: d['nombre'] ?? '',
      apellidos: d['apellidos'] ?? '',
      email: d['email'] ?? '',
      telefono: d['telefono'] ?? '',
      activo: d['activo'] ?? true,
      rol: d['rol'] ?? 'usuario',
      negocios: List<String>.from(d['negocios'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'apellidos': apellidos,
        'email': email,
        'telefono': telefono,
        'activo': activo,
        'rol': rol,
        'negocios': negocios,
      };

  String get nombreCompleto => '$nombre $apellidos'.trim();
}

class Reserva {
  final String id;
  final String claseNombre;
  final String cliente;
  final String employeeID;
  final String estado;
  final DateTime? fechaHora;
  final String hora;
  final String negocioNombre;
  final String userId;
  final DateTime? timestamp;

  Reserva({
    required this.id,
    required this.claseNombre,
    required this.cliente,
    required this.employeeID,
    required this.estado,
    this.fechaHora,
    required this.hora,
    required this.negocioNombre,
    required this.userId,
    this.timestamp,
  });

  factory Reserva.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Reserva(
      id: doc.id,
      claseNombre: d['claseNombre'] ?? '',
      cliente: d['cliente'] ?? '',
      employeeID: d['employeeID'] ?? '',
      estado: d['estado'] ?? '',
      fechaHora: (d['fechaHora'] as Timestamp?)?.toDate(),
      hora: d['hora'] ?? '',
      negocioNombre: d['negocioNombre'] ?? '',
      userId: d['userId'] ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}

// ─── CONSTANTES ────────────────────────────────────────────────────────────

const List<String> _negocioIds = [
  'Academia', 'Fisioterapia', 'Gimnasio', 'Peluqueria', 'Yoga'
];

const List<String> _rolesDisponibles = [
  'usuario', 'worker', 'admin', 'superadmin'
];

// Estados reales en Firestore — añade aquí cualquier variante que uses
const List<String> _estadosReales = [
  'activa', 'cancelada', 'completada', 'finalizada'
];

Color _colorRol(String rol) {
  switch (rol) {
    case 'superadmin': return const Color(0xFFEC4899);
    case 'admin':      return Colors.amber;
    case 'worker':     return const Color(0xFF64B5F6);
    default:           return Colors.white54;
  }
}

IconData _iconoRol(String rol) {
  switch (rol) {
    case 'superadmin': return Icons.shield;
    case 'admin':      return Icons.manage_accounts;
    case 'worker':     return Icons.engineering;
    default:           return Icons.person;
  }
}

Color _colorNegocio(String id) {
  switch (id) {
    case 'Academia':     return const Color(0xFF3B82F6);
    case 'Fisioterapia': return const Color(0xFF10B981);
    case 'Gimnasio':     return const Color(0xFFF59E0B);
    case 'Peluqueria':   return const Color(0xFFEC4899);
    case 'Yoga':         return const Color(0xFF8B5CF6);
    default:             return const Color(0xFF64B5F6);
  }
}

IconData _iconoNegocio(String id) {
  switch (id) {
    case 'Academia':     return Icons.school;
    case 'Fisioterapia': return Icons.healing;
    case 'Gimnasio':     return Icons.fitness_center;
    case 'Peluqueria':   return Icons.content_cut;
    case 'Yoga':         return Icons.self_improvement;
    default:             return Icons.business;
  }
}

// Normaliza el estado para el filtro:
// 'finalizada' y 'completada' se tratan igual
bool _estadoCoincide(String estadoReal, String? filtro) {
  if (filtro == null) return true;
  if (filtro == 'completada') {
    return estadoReal == 'completada' || estadoReal == 'finalizada';
  }
  return estadoReal == filtro;
}

// ─── FIRESTORE SERVICE ────────────────────────────────────────────────────

class _FS {
  static final _db = FirebaseFirestore.instance;

  // CLASES
  static Stream<QuerySnapshot> clasesPorNegocio(String negocioID) =>
      _db.collection('clases').where('negocioID', isEqualTo: negocioID).snapshots();
  static Future<void> crearClase(Clase c) => _db.collection('clases').add(c.toMap());
  static Future<void> actualizarClase(Clase c) =>
      _db.collection('clases').doc(c.id).update(c.toMap());
  static Future<void> eliminarClase(String id) =>
      _db.collection('clases').doc(id).delete();

  // WORKERS — viven en 'users' con rol worker/admin/superadmin
  static Stream<QuerySnapshot> workersStream() =>
      _db.collection('users')
          .where('rol', whereIn: ['worker', 'admin', 'superadmin'])
          .snapshots();
  static Future<void> crearWorker(Map<String, dynamic> data) =>
      _db.collection('users').add(data);
  static Future<void> actualizarWorker(String id, Map<String, dynamic> data) =>
      _db.collection('users').doc(id).update(data);
  static Future<void> eliminarWorker(String id) =>
      _db.collection('users').doc(id).delete();

  // USUARIOS NORMALES
  static Stream<QuerySnapshot> usuariosStream() =>
      _db.collection('users').where('rol', isEqualTo: 'usuario').snapshots();
  static Future<void> actualizarUser(UsuarioApp u) =>
      _db.collection('users').doc(u.id).update(u.toMap());
  static Future<void> eliminarUser(String id) =>
      _db.collection('users').doc(id).delete();
  static Future<void> actualizarRolUser(String uid, String nuevoRol) =>
      _db.collection('users').doc(uid).update({'rol': nuevoRol});

  // RESERVAS — sin orderBy para evitar necesitar índice compuesto
  static Stream<QuerySnapshot> reservasStream() =>
      _db.collection('reservas').snapshots();
  static Future<void> cancelarReserva(String id) =>
      _db.collection('reservas').doc(id).update({'estado': 'cancelada'});
  static Future<void> eliminarReserva(String id) =>
      _db.collection('reservas').doc(id).delete();
}

// ─── UI HELPERS ────────────────────────────────────────────────────────────

InputDecoration _inputDeco(IconData icon, Color accent) => InputDecoration(
      isDense: true,
      prefixIcon: Icon(icon, color: Colors.white38, size: 16),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 1.5)),
    );

Widget _badge(bool activo) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: activo
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Text(activo ? 'Activo' : 'Inactivo',
          style: TextStyle(
              color: activo ? Colors.greenAccent : Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.w500)),
    );

Widget _badgeRol(String rol) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _colorRol(rol).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_iconoRol(rol), color: _colorRol(rol), size: 10),
        const SizedBox(width: 4),
        Text(rol,
            style: TextStyle(
                color: _colorRol(rol),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
      ]),
    );

Widget _badgeEstado(String estado) {
  // Normaliza 'finalizada' → muestra como 'completada'
  final esCompletada = estado == 'completada' || estado == 'finalizada';
  final color = estado == 'activa'
      ? Colors.greenAccent
      : estado == 'cancelada'
          ? Colors.redAccent
          : esCompletada
              ? Colors.blueAccent
              : Colors.white60;
  final label = esCompletada ? 'completada' : estado;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w500)),
  );
}

Widget _modalHandle() => Center(
    child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2))));

Widget _modalBg(EdgeInsets padding, {required Widget child}) => Container(
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: child,
    );

Widget _fieldModal(String label, TextEditingController ctrl, IconData icon,
        Color accent,
        {int maxLines = 1}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: _inputDeco(icon, accent)),
    ]);

Widget _botonesModal(Color color,
        {required VoidCallback onCancelar,
        required VoidCallback onConfirmar,
        required String labelConfirmar}) =>
    Row(children: [
      Expanded(
          child: OutlinedButton(
              onPressed: onCancelar,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Cancelar'))),
      const SizedBox(width: 12),
      Expanded(
          flex: 2,
          child: ElevatedButton(
              onPressed: onConfirmar,
              style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              child: Text(labelConfirmar,
                  style: const TextStyle(fontWeight: FontWeight.w600)))),
    ]);

Widget _botonesAccion(Color color,
        {required VoidCallback onEliminar,
        required VoidCallback onCancelar,
        required VoidCallback onGuardar,
        String labelEliminar = 'Eliminar'}) =>
    Row(children: [
      Expanded(
          child: OutlinedButton.icon(
              onPressed: onEliminar,
              icon: const Icon(Icons.delete_outline, size: 15),
              label: Text(labelEliminar,
                  style: const TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))))),
      const SizedBox(width: 8),
      Expanded(
          child: OutlinedButton(
              onPressed: onCancelar,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 11)))),
      const SizedBox(width: 8),
      Expanded(
          child: ElevatedButton(
              onPressed: onGuardar,
              style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0),
              child: const Text('Guardar',
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)))),
    ]);

void _confirmarDialog(BuildContext context,
    {required String titulo,
    required String mensaje,
    required Future<void> Function() onConfirm}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      title: Text(titulo,
          style: const TextStyle(color: Colors.white)),
      content: Text(mensaje,
          style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white60))),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text('Confirmar')),
      ],
    ),
  );
}

Widget _searchBar(TextEditingController ctrl, String hint,
        ValueChanged<String> onChanged, String current) =>
    Container(
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.2))),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle:
              const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white38, size: 18),
          suffixIcon: current.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    ctrl.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.clear,
                      color: Colors.white38, size: 16))
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );

// ─── SELECTOR NEGOCIOS ─────────────────────────────────────────────────────

class _SelectorNegocios extends StatelessWidget {
  final String seleccionado;
  final ValueChanged<String> onSeleccionado;

  const _SelectorNegocios(
      {required this.seleccionado, required this.onSeleccionado});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _negocioIds.map((id) {
            final selected = id == seleccionado;
            final color = _colorNegocio(id);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSeleccionado(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconoNegocio(id),
                            color: selected ? color : Colors.white54,
                            size: 18),
                        const SizedBox(width: 6),
                        Text(id,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.white60,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal)),
                      ]),
                ),
              ),
            );
          }).toList(),
        ),
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
            colors: [
              Color(0xFF1E293B),
              Color(0xFF334155),
              Color(0xFF64B5F6)
            ]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Panel Super Administrador',
              style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async =>
                    await FirebaseAuth.instance.signOut()),
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
            child: switch (_tabIndex) {
              0 => const _NegocioTab(),
              1 => const _TrabajadoresTab(),
              2 => const _UsuariosTab(),
              _ => const _ReservasTab(),
            },
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
                      : Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  color: selected ? Colors.white : Colors.white60,
                  size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected ? Colors.white : Colors.white60,
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal)),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB NEGOCIO
// ═══════════════════════════════════════════════════════════════════════════

class _NegocioTab extends StatefulWidget {
  const _NegocioTab();
  @override
  State<_NegocioTab> createState() => _NegocioTabState();
}

class _NegocioTabState extends State<_NegocioTab> {
  String _negocioSel = 'Academia';

  Future<void> _mostrarNuevaClase() async {
    final nombreCtrl = TextEditingController();
    String? empleadoSel;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => _modalBg(
          EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              _modalHandle(),
              const SizedBox(height: 16),
              Row(children: [
                Icon(_iconoNegocio(_negocioSel),
                    color: _colorNegocio(_negocioSel), size: 22),
                const SizedBox(width: 10),
                Text('Nueva clase · $_negocioSel',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 20),
              _fieldModal('Nombre de la clase', nombreCtrl,
                  Icons.label, _colorNegocio(_negocioSel)),
              const SizedBox(height: 16),
              Text('Asignar trabajador',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _WorkerSelector(
                negocioSel: _negocioSel,
                selectedId: empleadoSel,
                onSelected: (id) => set(() => empleadoSel = id),
              ),
              const SizedBox(height: 20),
              _botonesModal(
                _colorNegocio(_negocioSel),
                onCancelar: () => Navigator.pop(ctx),
                onConfirmar: () async {
                  if (nombreCtrl.text.trim().isEmpty) return;
                  await _FS.crearClase(Clase(
                    id: '',
                    nombre: nombreCtrl.text.trim(),
                    employeeID: empleadoSel ?? '',
                    negocioID: _negocioSel,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                labelConfirmar: 'Crear clase',
              ),
            ]),
          ),
        ),
      ),
    );
    nombreCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(_negocioSel);
    return Column(children: [
      _SelectorNegocios(
          seleccionado: _negocioSel,
          onSeleccionado: (id) =>
              setState(() => _negocioSel = id)),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GestureDetector(
          onTap: _mostrarNuevaClase,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: color.withValues(alpha: 0.4))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Icon(Icons.add_circle_outline, color: color, size: 18),
              const SizedBox(width: 8),
              Text('Añadir clase a $_negocioSel',
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _FS.clasesPorNegocio(_negocioSel),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white54));
            }
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Center(
                  child: Text('No hay clases en $_negocioSel',
                      style: const TextStyle(
                          color: Colors.white60)));
            }
            final clases =
                snap.data!.docs.map((d) => Clase.fromDoc(d)).toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: clases.length,
              itemBuilder: (context, i) => _ClaseCard(
                key: ValueKey(clases[i].id),
                clase: clases[i],
                onEliminar: () => _confirmarDialog(context,
                    titulo: 'Eliminar clase',
                    mensaje:
                        '¿Eliminar "${clases[i].nombre}"? Esta acción no se puede deshacer.',
                    onConfirm: () =>
                        _FS.eliminarClase(clases[i].id)),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── WORKER SELECTOR ──────────────────────────────────────────────────────

class _WorkerSelector extends StatelessWidget {
  final String negocioSel;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _WorkerSelector({
    required this.negocioSel,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(negocioSel);
    return StreamBuilder<QuerySnapshot>(
      stream: _FS.workersStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
                child: CircularProgressIndicator(
                    color: Colors.white54, strokeWidth: 2)),
          );
        }
        final workers =
            snap.data!.docs.map((d) => Worker.fromDoc(d)).toList();
        if (workers.isEmpty) {
          return const Text('No hay trabajadores disponibles',
              style: TextStyle(color: Colors.white38, fontSize: 12));
        }
        return Column(
          children: workers.map((w) {
            final sel = selectedId == w.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: GestureDetector(
                onTap: () => onSelected(w.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel
                            ? color.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            color.withValues(alpha: 0.3),
                        child: Text(
                            w.nombre.isNotEmpty
                                ? w.nombre[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                      Text(w.nombreCompleto,
                          style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : Colors.white70,
                              fontSize: 13)),
                      Text(w.rol,
                          style: TextStyle(
                              color: _colorRol(w.rol),
                              fontSize: 10)),
                    ])),
                    if (sel)
                      Icon(Icons.check_circle,
                          color: color, size: 18),
                  ]),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── CLASE CARD ────────────────────────────────────────────────────────────

class _ClaseCard extends StatefulWidget {
  final Clase clase;
  final VoidCallback onEliminar;

  const _ClaseCard(
      {required Key key,
      required this.clase,
      required this.onEliminar})
      : super(key: key);

  @override
  State<_ClaseCard> createState() => _ClaseCardState();
}

class _ClaseCardState extends State<_ClaseCard> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl;
  String? _empleadoSel;
  late Stream<QuerySnapshot> _workersStream;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.clase.nombre);
    _empleadoSel = widget.clase.employeeID.isNotEmpty
        ? widget.clase.employeeID
        : null;
     _workersStream = _FS.workersStream();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    widget.clase.nombre = _nombreCtrl.text.trim();
    widget.clase.employeeID = _empleadoSel ?? '';
    await _FS.actualizarClase(widget.clase);
    setState(() => _expandido = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Clase actualizada'),
          backgroundColor: _colorNegocio(widget.clase.negocioID),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(widget.clase.negocioID);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _expandido
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: _expandido ? 1.5 : 1),
        ),
        child: Column(children: [
          InkWell(
            onTap: () =>
                setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(10)),
                    child: Icon(
                        _iconoNegocio(widget.clase.negocioID),
                        color: color,
                        size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Text(widget.clase.nombre,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  if (widget.clase.employeeID.isNotEmpty)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.clase.employeeID)
                          .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData ||
                            !snap.data!.exists) {
                          return const Text(
                              'Sin trabajador asignado',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11));
                        }
                        final w = Worker.fromDoc(snap.data!);
                        return Row(children: [
                          Icon(Icons.engineering,
                              color: color, size: 11),
                          const SizedBox(width: 4),
                          Text(w.nombreCompleto,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11)),
                        ]);
                      },
                    )
                  else
                    const Text('Sin trabajador asignado',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 11)),
                ])),
                AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration:
                        const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22)),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expandido ? _buildForm(color) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Widget _buildForm(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1),
        const SizedBox(height: 14),
        Text('Nombre de la clase',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
            controller: _nombreCtrl,
            style: const TextStyle(
                color: Colors.white, fontSize: 13),
            decoration: _inputDeco(Icons.label, color)),
        const SizedBox(height: 14),
        Text('Trabajador asignado',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _WorkerSelector(
          negocioSel: widget.clase.negocioID,
          selectedId: _empleadoSel,
          onSelected: (id) =>
              setState(() => _empleadoSel = id),
        ),
        const SizedBox(height: 14),
        _botonesAccion(color,
            onEliminar: widget.onEliminar,
            onCancelar: () =>
                setState(() => _expandido = false),
            onGuardar: _guardar),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB TRABAJADORES — SIN filtros de rol (eliminados)
// ═══════════════════════════════════════════════════════════════════════════

class _TrabajadoresTab extends StatefulWidget {
  const _TrabajadoresTab();
  @override
  State<_TrabajadoresTab> createState() =>
      _TrabajadoresTabState();
}

class _TrabajadoresTabState extends State<_TrabajadoresTab> {
  String _negocioSel = 'Academia';
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _mostrarNuevoTrabajador() async {
    final nombreCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final dirCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _modalBg(
        EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _modalHandle(),
            const SizedBox(height: 16),
            const Row(children: [
              Icon(Icons.engineering,
                  color: Color(0xFF64B5F6), size: 22),
              SizedBox(width: 10),
              Text('Nuevo trabajador',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 20),
            _fieldModal('Nombre', nombreCtrl, Icons.person,
                const Color(0xFF64B5F6)),
            const SizedBox(height: 12),
            _fieldModal('Apellidos', apellidosCtrl,
                Icons.person_outline,
                const Color(0xFF64B5F6)),
            const SizedBox(height: 12),
            _fieldModal('Teléfono', telCtrl, Icons.phone,
                const Color(0xFF64B5F6)),
            const SizedBox(height: 12),
            _fieldModal('Dirección', dirCtrl,
                Icons.location_on,
                const Color(0xFF64B5F6)),
            const SizedBox(height: 20),
            _botonesModal(
              const Color(0xFF64B5F6),
              onCancelar: () => Navigator.pop(ctx),
              onConfirmar: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                await _FS.crearWorker({
                  'nombre': nombreCtrl.text.trim(),
                  'apellidos': apellidosCtrl.text.trim(),
                  'telefono': telCtrl.text.trim(),
                  'direccion': dirCtrl.text.trim(),
                  'avatar': 'assets/images/acaperfil.png',
                  'rol': 'worker',
                  'activo': true,
                  'email': '',
                  'negocios': [_negocioSel],
                  'fecha_registro':
                      FieldValue.serverTimestamp(),
                  'fechaNacimiento': null,
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              labelConfirmar: 'Añadir trabajador',
            ),
          ]),
        ),
      ),
    );
    nombreCtrl.dispose();
    apellidosCtrl.dispose();
    telCtrl.dispose();
    dirCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(_negocioSel);
    return Column(children: [
      _SelectorNegocios(
          seleccionado: _negocioSel,
          onSeleccionado: (id) => setState(() {
                _negocioSel = id;
                _busqueda = '';
                _busquedaCtrl.clear();
              })),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _searchBar(
            _busquedaCtrl,
            'Buscar trabajador...',
            (v) => setState(() => _busqueda = v),
            _busqueda),
      ),
      // ── Botón añadir (sin chips de rol) ──
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GestureDetector(
          onTap: _mostrarNuevoTrabajador,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withValues(alpha: 0.4))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Icon(Icons.add_circle_outline,
                  color: color, size: 18),
              const SizedBox(width: 8),
              Text('Añadir trabajador',
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _FS.workersStream(),
          builder: (context, snap) {
            if (snap.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white54));
            }
            if (!snap.hasData) return const SizedBox.shrink();
            return _WorkersConFiltroNegocio(
              negocioSel: _negocioSel,
              busqueda: _busqueda,
              allWorkers: snap.data!.docs
                  .map((d) => Worker.fromDoc(d))
                  .toList(),
              onEliminar: (w) => _confirmarDialog(context,
                  titulo: 'Dar de baja trabajador',
                  mensaje:
                      '¿Eliminar a ${w.nombreCompleto} del sistema?',
                  onConfirm: () =>
                      _FS.eliminarWorker(w.id)),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── WORKERS CON FILTRO NEGOCIO ────────────────────────────────────────────

class _WorkersConFiltroNegocio extends StatelessWidget {
  final String negocioSel;
  final String busqueda;
  final List<Worker> allWorkers;
  final void Function(Worker) onEliminar;

  const _WorkersConFiltroNegocio({
    required this.negocioSel,
    required this.busqueda,
    required this.allWorkers,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _FS.clasesPorNegocio(negocioSel),
      builder: (context, snapClases) {
        if (snapClases.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Colors.white54));
        }

        final employeeIds = snapClases.data?.docs
                .map((d) =>
                    (d.data() as Map<String,
                        dynamic>)['employeeID'] as String? ??
                    '')
                .where((id) => id.isNotEmpty)
                .toSet() ??
            {};

        var workers = employeeIds.isEmpty
            ? allWorkers
            : allWorkers
                .where((w) => employeeIds.contains(w.id))
                .toList();

        if (busqueda.isNotEmpty) {
          final q = busqueda.toLowerCase();
          workers = workers
              .where((w) =>
                  w.nombre.toLowerCase().contains(q) ||
                  w.apellidos.toLowerCase().contains(q) ||
                  w.telefono.contains(q))
              .toList();
        }

        if (workers.isEmpty) {
          return Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
            const Icon(Icons.engineering,
                color: Colors.white24, size: 40),
            const SizedBox(height: 12),
            Text(
                busqueda.isNotEmpty
                    ? 'Sin resultados para "$busqueda"'
                    : 'No hay trabajadores en $negocioSel',
                style:
                    const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center),
          ]));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: workers.length,
          itemBuilder: (context, i) => _WorkerCard(
            key: ValueKey(workers[i].id),
            worker: workers[i],
            negocioSel: negocioSel,
            onEliminar: () => onEliminar(workers[i]),
          ),
        );
      },
    );
  }
}

// ─── WORKER CARD ───────────────────────────────────────────────────────────

class _WorkerCard extends StatefulWidget {
  final Worker worker;
  final String negocioSel;
  final VoidCallback onEliminar;

  const _WorkerCard(
      {required Key key,
      required this.worker,
      required this.negocioSel,
      required this.onEliminar})
      : super(key: key);

  @override
  State<_WorkerCard> createState() => _WorkerCardState();
}

class _WorkerCardState extends State<_WorkerCard> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl,
      _apellidosCtrl,
      _telCtrl,
      _dirCtrl;
  late String _rolSel;

 bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    _nombreCtrl = TextEditingController(text: w.nombre);
    _apellidosCtrl = TextEditingController(text: w.apellidos);
    _telCtrl = TextEditingController(text: w.telefono);
    _dirCtrl = TextEditingController(text: w.direccion);
    _rolSel = w.rol;
    _inicializado = true;
  }

  void _reset() {
    if (_inicializado) {
      _nombreCtrl.dispose();
      _apellidosCtrl.dispose();
      _telCtrl.dispose();
      _dirCtrl.dispose();
    }
    final w = widget.worker;
    _nombreCtrl = TextEditingController(text: w.nombre);
    _apellidosCtrl = TextEditingController(text: w.apellidos);
    _telCtrl = TextEditingController(text: w.telefono);
    _dirCtrl = TextEditingController(text: w.direccion);
    _rolSel = w.rol;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _telCtrl.dispose();
    _dirCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    widget.worker.nombre = _nombreCtrl.text.trim();
    widget.worker.apellidos = _apellidosCtrl.text.trim();
    widget.worker.telefono = _telCtrl.text.trim();
    widget.worker.direccion = _dirCtrl.text.trim();
    widget.worker.rol = _rolSel;
    await _FS.actualizarWorker(
        widget.worker.id, widget.worker.toMap());
    setState(() => _expandido = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Trabajador actualizado'),
          backgroundColor: _colorNegocio(widget.negocioSel),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(widget.negocioSel);
    final w = widget.worker;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _expandido
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: _expandido ? 1.5 : 1),
        ),
        child: Column(children: [
          InkWell(
            onTap: () =>
                setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Stack(children: [
                  CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          color.withValues(alpha: 0.25),
                      child: Text(
                          w.nombre.isNotEmpty
                              ? w.nombre[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))),
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                              color: _colorRol(w.rol),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(
                                      0xFF1E293B),
                                  width: 1.5)),
                          child: Icon(_iconoRol(w.rol),
                              size: 8,
                              color: Colors.white))),
                ]),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Row(children: [
                    Flexible(
                        child: Text(w.nombreCompleto,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600))),
                    const SizedBox(width: 6),
                    _badgeRol(w.rol),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                      w.telefono.isNotEmpty
                          ? w.telefono
                          : 'Sin teléfono',
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11)),
                ])),
                AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration:
                        const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22)),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expandido ? _buildForm(color) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Widget _buildForm(Color color) {
    Widget field(String label, TextEditingController ctrl,
            IconData icon) =>
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextFormField(
              controller: ctrl,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13),
              decoration: _inputDeco(icon, color)),
        ]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1),
        const SizedBox(height: 14),
        field('Nombre', _nombreCtrl, Icons.person),
        const SizedBox(height: 10),
        field('Apellidos', _apellidosCtrl,
            Icons.person_outline),
        const SizedBox(height: 10),
        field('Teléfono', _telCtrl, Icons.phone),
        const SizedBox(height: 10),
        field('Dirección', _dirCtrl, Icons.location_on),
        const SizedBox(height: 14),
        Text('Rol del trabajador',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rolesDisponibles.map((rol) {
              final sel = _rolSel == rol;
              final c = _colorRol(rol);
              return GestureDetector(
                onTap: () =>
                    setState(() => _rolSel = rol),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? c.withValues(alpha: 0.2)
                        : Colors.white
                            .withValues(alpha: 0.06),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                        color: sel
                            ? c.withValues(alpha: 0.7)
                            : Colors.white
                                .withValues(alpha: 0.15)),
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Icon(_iconoRol(rol),
                        color: sel ? c : Colors.white38,
                        size: 14),
                    const SizedBox(width: 6),
                    Text(rol,
                        style: TextStyle(
                            color: sel
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ]),
                ),
              );
            }).toList()),
        const SizedBox(height: 14),
        Text('Clases asignadas en ${widget.negocioSel}',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream:
              _FS.clasesPorNegocio(widget.negocioSel),
          builder: (ctx, snap) {
            if (!snap.hasData)
              return const SizedBox.shrink();
            final clases = snap.data!.docs
                .map((d) => Clase.fromDoc(d))
                .where((c) =>
                    c.employeeID == widget.worker.id)
                .toList();
            if (clases.isEmpty) {
              return Text(
                  'Sin clases asignadas en ${widget.negocioSel}',
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12));
            }
            return Wrap(
                spacing: 6,
                runSpacing: 4,
                children: clases
                    .map((c) => Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                          decoration: BoxDecoration(
                              color: color.withValues(
                                  alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(
                                      6)),
                          child: Text(c.nombre,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11)),
                        ))
                    .toList());
          },
        ),
        const SizedBox(height: 14),
        _botonesAccion(color,
            labelEliminar: 'Dar de baja',
            onEliminar: widget.onEliminar,
            onCancelar: () {
              _reset();
              setState(() => _expandido = false);
            },
            onGuardar: _guardar),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB USUARIOS
// ═══════════════════════════════════════════════════════════════════════════

class _UsuariosTab extends StatefulWidget {
  const _UsuariosTab();
  @override
  State<_UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<_UsuariosTab> {
  String _negocioSel = 'Academia';
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';
  bool _soloActivos = false;
  Set<String> _filtroNegocios = {};
  bool _mostrarFiltros = false;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

Future<void> _mostrarNuevoUsuario() async {
  final nombreCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  List<String> negociosSel = [_negocioSel];
  bool passwordOculta = true;
  bool cargando = false;

  await showDialog(
    context: context,
    barrierDismissible: false, // no se cierra al tocar fuera
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, set) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 650),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  const Icon(Icons.person_add, color: Color(0xFF64B5F6), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Nuevo usuario',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ]),
              ),
              const Divider(color: Colors.white12, height: 20),
              // Scroll del formulario
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldModal('Nombre *', nombreCtrl, Icons.person, const Color(0xFF64B5F6)),
                      const SizedBox(height: 12),
                      _fieldModal('Apellidos', apellidosCtrl, Icons.person_outline, const Color(0xFF64B5F6)),
                      const SizedBox(height: 12),
                      _fieldModal('Email *', emailCtrl, Icons.email, const Color(0xFF64B5F6)),
                      const SizedBox(height: 12),
                      _fieldModal('Teléfono', telCtrl, Icons.phone, const Color(0xFF64B5F6)),
                      const SizedBox(height: 12),
                      // Campo contraseña con toggle visibilidad
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contraseña *',
                              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: passwordOculta,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              prefixIcon: const Icon(Icons.lock, color: Colors.white38, size: 16),
                              suffixIcon: GestureDetector(
                                onTap: () => set(() => passwordOculta = !passwordOculta),
                                child: Icon(
                                  passwordOculta ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white38, size: 16,
                                ),
                              ),
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
                                borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Negocios',
                          style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      ..._negocioIds.map((id) {
                        final asig = negociosSel.contains(id);
                        final c = _colorNegocio(id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: GestureDetector(
                            onTap: () => set(() {
                              if (asig) negociosSel.remove(id);
                              else negociosSel.add(id);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: asig ? c.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: asig ? c.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(children: [
                                Icon(asig ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: asig ? c : Colors.white38, size: 18),
                                const SizedBox(width: 8),
                                Icon(_iconoNegocio(id), color: asig ? c : Colors.white38, size: 16),
                                const SizedBox(width: 6),
                                Text(id, style: TextStyle(color: asig ? Colors.white : Colors.white60, fontSize: 13)),
                              ]),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      // Botones
                      Row(children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                          onPressed: cargando ? null : () async {
                            if (nombreCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passwordCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Rellena los campos obligatorios')),
                              );
                              return;
                            }
                            
                            set(() => cargando = true);
                            bool exito = false; // 1. Añadimos una bandera para saber si fue bien

                            try {
                              final appName = 'secondary_${DateTime.now().millisecondsSinceEpoch}';
                              final secondaryApp = await Firebase.initializeApp(
                                name: appName,
                                options: Firebase.app().options,
                              );

                              try {
                                final cred = await FirebaseAuth.instanceFor(app: secondaryApp)
                                    .createUserWithEmailAndPassword(
                                  email: emailCtrl.text.trim(),
                                  password: passwordCtrl.text.trim(),
                                );

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(cred.user!.uid)
                                    .set({
                                  'nombre': nombreCtrl.text.trim(),
                                  'apellidos': apellidosCtrl.text.trim(),
                                  'email': emailCtrl.text.trim(),
                                  'telefono': telCtrl.text.trim(),
                                  'activo': true,
                                  'rol': 'usuario',
                                  'negocios': negociosSel,
                                  'fecha_registro': FieldValue.serverTimestamp(),
                                  'avatar': 'assets/images/acaperfil.png',
                                  'direccion': '',
                                  'fechaNacimiento': null,
                                });

                                await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
                              } finally {
                                await secondaryApp.delete();
                              }
                              
                              exito = true; // 2. Marcamos como exitoso si llegó hasta aquí sin excepciones

                            } on FirebaseAuthException catch (e) {
                              String msg = 'Error inesperado';
                              if (e.code == 'email-already-in-use') msg = 'El email ya está en uso';
                              else if (e.code == 'weak-password') msg = 'Contraseña demasiado débil (mín. 6 caracteres)';
                              else if (e.code == 'invalid-email') msg = 'Email no válido';
                              
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
                              }
                            } finally {
                              // 3. AQUÍ ESTÁ LA MAGIA: Controlamos qué hacer al final
                              if (exito) {
                                // Si todo fue bien, cerramos el modal y NO llamamos a set()
                                if (ctx.mounted) Navigator.pop(ctx);
                              } else {
                                // Solo detenemos el loading si hubo un error y el modal sigue en pantalla
                                if (ctx.mounted) set(() => cargando = false);
                              }
                            }
                          },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF64B5F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: cargando
                                ? const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Crear usuario', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  nombreCtrl.dispose();
  apellidosCtrl.dispose();
  emailCtrl.dispose();
  passwordCtrl.dispose();
  telCtrl.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        _SelectorNegocios(
            seleccionado: _negocioSel,
            onSeleccionado: (id) => setState(() {
                  _negocioSel = id;
                  _busqueda = '';
                  _busquedaCtrl.clear();
                  _filtroNegocios.clear();
                })),
        Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            Expanded(
                child: _searchBar(
                    _busquedaCtrl,
                    'Buscar por nombre, email o teléfono...',
                    (v) => setState(() => _busqueda = v),
                    _busqueda)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() =>
                  _mostrarFiltros = !_mostrarFiltros),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_filtroNegocios.isNotEmpty ||
                          _soloActivos ||
                          _mostrarFiltros)
                      ? Colors.white
                          .withValues(alpha: 0.25)
                      : Colors.white
                          .withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          _filtroNegocios.isNotEmpty ||
                                  _soloActivos
                              ? Colors.white
                                  .withValues(alpha: 0.6)
                              : Colors.white
                                  .withValues(
                                      alpha: 0.2)),
                ),
                child: Stack(children: [
                  const Icon(Icons.filter_list,
                      color: Colors.white, size: 20),
                  if (_filtroNegocios.isNotEmpty ||
                      _soloActivos)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 8,
                            height: 8,
                            decoration:
                                const BoxDecoration(
                                    color: Colors.amber,
                                    shape:
                                        BoxShape.circle))),
                ]),
              ),
            ),
          ]),
        ),
  AnimatedSize(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    child: _mostrarFiltros
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 0, 16, 10),
            child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.07),
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.15))),
                child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                        'Solo usuarios activos',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13)),
                    value: _soloActivos,
                    activeColor:
                        const Color(0xFF64B5F6),
                    onChanged: (v) => setState(
                        () => _soloActivos = v)),
              ),
              const SizedBox(height: 10),
              Text('Filtrar por negocios adicionales:',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _negocioIds.map((n) {
                    final sel =
                        _filtroNegocios.contains(n);
                    final c = _colorNegocio(n);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (sel)
                          _filtroNegocios.remove(n);
                        else
                          _filtroNegocios.add(n);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? c.withValues(alpha: 0.25)
                              : Colors.white.withValues(
                                  alpha: 0.07),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? c.withValues(
                                      alpha: 0.7)
                                  : Colors.white
                                      .withValues(
                                          alpha: 0.2)),
                        ),
                        child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                          Icon(_iconoNegocio(n),
                              color: sel
                                  ? c
                                  : Colors.white38,
                              size: 14),
                          const SizedBox(width: 5),
                          Text(n,
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: sel
                                      ? FontWeight.w600
                                      : FontWeight
                                          .normal)),
                        ]),
                      ),
                    );
                  }).toList()),
              if (_filtroNegocios.isNotEmpty ||
                  _soloActivos) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _filtroNegocios.clear();
                    _soloActivos = false;
                  }),
                  child: Text('Limpiar filtros',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          decoration:
                              TextDecoration.underline,
                          decorationColor:
                              Colors.white38)),
                ),
              ],
            ]),
          )
          : const SizedBox.shrink(),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _FS.usuariosStream(),
            builder: (context, snap) {
              if (snap.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white54));
              }
              if (!snap.hasData)
                return const SizedBox.shrink();

              var usuarios = snap.data!.docs
                  .map((d) => UsuarioApp.fromDoc(d))
                  .where((u) =>
                      u.negocios.contains(_negocioSel))
                  .toList();

              if (_soloActivos) {
                usuarios = usuarios
                    .where((u) => u.activo)
                    .toList();
              }
              if (_filtroNegocios.isNotEmpty) {
                usuarios = usuarios
                    .where((u) => _filtroNegocios
                        .every((n) =>
                            u.negocios.contains(n)))
                    .toList();
              }
              if (_busqueda.isNotEmpty) {
                final q = _busqueda.toLowerCase();
                usuarios = usuarios
                    .where((u) =>
                        u.nombre
                            .toLowerCase()
                            .contains(q) ||
                        u.apellidos
                            .toLowerCase()
                            .contains(q) ||
                        u.email
                            .toLowerCase()
                            .contains(q) ||
                        u.telefono.contains(q))
                    .toList();
              }

              if (usuarios.isEmpty) {
                return Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                  const Icon(Icons.people,
                      color: Colors.white24, size: 40),
                  const SizedBox(height: 12),
                  Text(
                      _busqueda.isNotEmpty ||
                              _filtroNegocios.isNotEmpty
                          ? 'Sin resultados'
                          : 'No hay usuarios en $_negocioSel',
                      style: const TextStyle(
                          color: Colors.white60)),
                ]));
              }

              return Column(children: [
                if (_busqueda.isNotEmpty ||
                    _filtroNegocios.isNotEmpty ||
                    _soloActivos)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 6),
                    child: Row(children: [
                      Text(
                          '${usuarios.length} resultado${usuarios.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11)),
                    ]),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 80),
                    itemCount: usuarios.length,
                    itemBuilder: (context, i) =>
                        _UsuarioCard(
                      key: ValueKey(usuarios[i].id),
                      usuario: usuarios[i],
                      negocioSel: _negocioSel,
                      onEliminar: () =>
                          _confirmarDialog(context,
                              titulo:
                                  'Dar de baja usuario',
                              mensaje:
                                  '¿Eliminar a ${usuarios[i].nombreCompleto}?',
                              onConfirm: () =>
                                  _FS.eliminarUser(
                                      usuarios[i].id)),
                    ),
                  ),
                ),
              ]);
            },
          ),
        ),
      ]),
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingActionButton.extended(
          onPressed: _mostrarNuevoUsuario,
          backgroundColor: const Color(0xFF64B5F6),
          icon: const Icon(Icons.person_add,
              color: Colors.white),
          label: const Text('Añadir usuario',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ]);
  }
}

// ─── USUARIO CARD ──────────────────────────────────────────────────────────

class _UsuarioCard extends StatefulWidget {
  final UsuarioApp usuario;
  final String negocioSel;
  final VoidCallback onEliminar;

  const _UsuarioCard(
      {required Key key,
      required this.usuario,
      required this.negocioSel,
      required this.onEliminar})
      : super(key: key);

  @override
  State<_UsuarioCard> createState() =>
      _UsuarioCardState();
}

class _UsuarioCardState extends State<_UsuarioCard> {
  bool _expandido = false;
  late TextEditingController _nombreCtrl,
      _apellidosCtrl,
      _emailCtrl,
      _telCtrl;
  late bool _activo;
  late List<String> _negocios;

  bool _inicializado = false;

@override
void initState() {
  super.initState();
  final u = widget.usuario;
  _nombreCtrl = TextEditingController(text: u.nombre);
  _apellidosCtrl = TextEditingController(text: u.apellidos);
  _emailCtrl = TextEditingController(text: u.email);
  _telCtrl = TextEditingController(text: u.telefono);
  _activo = u.activo;
  _negocios = List.from(u.negocios);
  _inicializado = true;
}

void _reset() {
  if (_inicializado) {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
  }
  final u = widget.usuario;
  _nombreCtrl = TextEditingController(text: u.nombre);
  _apellidosCtrl = TextEditingController(text: u.apellidos);
  _emailCtrl = TextEditingController(text: u.email);
  _telCtrl = TextEditingController(text: u.telefono);
  _activo = u.activo;
  _negocios = List.from(u.negocios);
}

@override
void dispose() {
  _nombreCtrl.dispose();
  _apellidosCtrl.dispose();
  _emailCtrl.dispose();
  _telCtrl.dispose();
  super.dispose();
}

  void _guardar() async {
    widget.usuario.nombre = _nombreCtrl.text.trim();
    widget.usuario.apellidos =
        _apellidosCtrl.text.trim();
    widget.usuario.email = _emailCtrl.text.trim();
    widget.usuario.telefono = _telCtrl.text.trim();
    widget.usuario.activo = _activo;
    widget.usuario.negocios = List.from(_negocios);
    await _FS.actualizarUser(widget.usuario);
    setState(() => _expandido = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Usuario actualizado'),
          backgroundColor:
              _colorNegocio(widget.negocioSel),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorNegocio(widget.negocioSel);
    final u = widget.usuario;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _expandido
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: _expandido ? 1.5 : 1),
        ),
        child: Column(children: [
          InkWell(
            onTap: () =>
                setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        color.withValues(alpha: 0.25),
                    child: Text(
                        u.nombre.isNotEmpty
                            ? u.nombre[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Text(u.nombreCompleto,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(u.email,
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11)),
                  if (u.negocios.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Wrap(
                        spacing: 4,
                        children: u.negocios.map((n) {
                          final c = _colorNegocio(n);
                          return Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 5,
                                  vertical: 1),
                              decoration: BoxDecoration(
                                  color: c.withValues(
                                      alpha: 0.2),
                                  borderRadius:
                                      BorderRadius
                                          .circular(4)),
                              child: Text(n,
                                  style: TextStyle(
                                      color: c,
                                      fontSize: 9)));
                        }).toList()),
                  ],
                ])),
                _badge(u.activo),
                const SizedBox(width: 6),
                AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration:
                        const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22)),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expandido ? _buildForm(color) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Widget _buildForm(Color color) {
    Widget field(String label,
            TextEditingController ctrl, IconData icon,
            {bool readOnly = false}) =>
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextFormField(
              controller: ctrl,
              readOnly: readOnly,
              style: TextStyle(
                  color: readOnly
                      ? Colors.white38
                      : Colors.white,
                  fontSize: 13),
              decoration: _inputDeco(icon, color)),
        ]);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1),
        const SizedBox(height: 14),
        field('Nombre', _nombreCtrl, Icons.person),
        const SizedBox(height: 10),
        field('Apellidos', _apellidosCtrl,
            Icons.person_outline),
        const SizedBox(height: 10),
        field('Email', _emailCtrl, Icons.email,
            readOnly: true),
        const SizedBox(height: 10),
        field('Teléfono', _telCtrl, Icons.phone),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
              color:
                  Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white
                      .withValues(alpha: 0.15))),
          child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Usuario activo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13)),
              subtitle: Text(
                  _activo
                      ? 'Acceso habilitado'
                      : 'Acceso suspendido',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11)),
              value: _activo,
              activeColor: color,
              onChanged: (v) =>
                  setState(() => _activo = v)),
        ),
        const SizedBox(height: 12),
        Text('Negocios del usuario',
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ..._negocioIds.map((id) {
          final asignado = _negocios.contains(id);
          final c = _colorNegocio(id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => setState(() {
                if (asignado)
                  _negocios.remove(id);
                else
                  _negocios.add(id);
              }),
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: asignado
                      ? c.withValues(alpha: 0.15)
                      : Colors.white
                          .withValues(alpha: 0.05),
                  borderRadius:
                      BorderRadius.circular(8),
                  border: Border.all(
                      color: asignado
                          ? c.withValues(alpha: 0.5)
                          : Colors.white
                              .withValues(alpha: 0.15)),
                ),
                child: Row(children: [
                  Icon(
                      asignado
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: asignado
                          ? c
                          : Colors.white38,
                      size: 18),
                  const SizedBox(width: 8),
                  Icon(_iconoNegocio(id),
                      color: asignado
                          ? c
                          : Colors.white38,
                      size: 16),
                  const SizedBox(width: 6),
                  Text(id,
                      style: TextStyle(
                          color: asignado
                              ? Colors.white
                              : Colors.white60,
                          fontSize: 13)),
                ]),
              ),
            ),
          );
        }),
        const SizedBox(height: 14),
        _botonesAccion(color,
            labelEliminar: 'Dar de baja',
            onEliminar: widget.onEliminar,
            onCancelar: () {
              _reset();
              setState(() => _expandido = false);
            },
            onGuardar: _guardar),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TAB RESERVAS — filtro 'completada' cubre también 'finalizada'
// ═══════════════════════════════════════════════════════════════════════════

class _ReservasTab extends StatefulWidget {
  const _ReservasTab();
  @override
  State<_ReservasTab> createState() => _ReservasTabState();
}

class _ReservasTabState extends State<_ReservasTab> {
  String? _negocioFiltro;
  String? _estadoFiltro;
  final _busquedaCtrl = TextEditingController();
  String _busqueda = '';
  DateTimeRange? _rangoFechas;

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  String _formatFecha(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarRango() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      initialDateRange: _rangoFechas,
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF64B5F6),
            onPrimary: Colors.white,
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null)
      setState(() => _rangoFechas = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Filtro negocio
      Padding(
        padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _chipN('Todos', null),
            ..._negocioIds.map((id) => _chipN(id, id)),
          ]),
        ),
      ),
      // Filtro estado + selector fecha
      Padding(
        padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _chipE('Todas', null),
                const SizedBox(width: 8),
                _chipE('Activas', 'activa'),
                const SizedBox(width: 8),
                _chipE('Canceladas', 'cancelada'),
                const SizedBox(width: 8),
                // 'completada' filtra tanto 'completada' como 'finalizada'
                _chipE('Completadas', 'completada'),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _seleccionarRango,
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: _rangoFechas != null
                    ? const Color(0xFF64B5F6)
                        .withValues(alpha: 0.25)
                    : Colors.white
                        .withValues(alpha: 0.07),
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                    color: _rangoFechas != null
                        ? const Color(0xFF64B5F6)
                            .withValues(alpha: 0.7)
                        : Colors.white
                            .withValues(alpha: 0.2)),
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Icon(Icons.date_range,
                    color: _rangoFechas != null
                        ? const Color(0xFF64B5F6)
                        : Colors.white54,
                    size: 14),
                const SizedBox(width: 5),
                Text(
                    _rangoFechas != null
                        ? '${_rangoFechas!.start.day}/${_rangoFechas!.start.month} – ${_rangoFechas!.end.day}/${_rangoFechas!.end.month}'
                        : 'Fechas',
                    style: TextStyle(
                        color: _rangoFechas != null
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 11)),
                if (_rangoFechas != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(
                        () => _rangoFechas = null),
                    child: const Icon(Icons.close,
                        color: Colors.white54,
                        size: 12),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
      // Buscador
      Padding(
        padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _searchBar(
            _busquedaCtrl,
            'Buscar por cliente, clase o negocio...',
            (v) => setState(() => _busqueda = v),
            _busqueda),
      ),
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: _FS.reservasStream(),
          builder: (context, snap) {
            if (snap.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white54));
            }
            if (!snap.hasData)
              return const SizedBox.shrink();

            var reservas = snap.data!.docs
                .map((d) => Reserva.fromDoc(d))
                .toList();

            // Ordenamos por fecha desc en cliente
            reservas.sort((a, b) {
              if (a.fechaHora == null &&
                  b.fechaHora == null) return 0;
              if (a.fechaHora == null) return 1;
              if (b.fechaHora == null) return -1;
              return b.fechaHora!
                  .compareTo(a.fechaHora!);
            });

            if (_negocioFiltro != null) {
              reservas = reservas
                  .where((r) =>
                      r.negocioNombre ==
                      _negocioFiltro)
                  .toList();
            }

            // Filtro de estado con normalización
            if (_estadoFiltro != null) {
              reservas = reservas
                  .where((r) => _estadoCoincide(
                      r.estado, _estadoFiltro))
                  .toList();
            }

            if (_rangoFechas != null) {
              reservas = reservas.where((r) {
                if (r.fechaHora == null) return false;
                return r.fechaHora!.isAfter(
                        _rangoFechas!.start.subtract(
                            const Duration(days: 1))) &&
                    r.fechaHora!.isBefore(
                        _rangoFechas!.end
                            .add(const Duration(days: 1)));
              }).toList();
            }

            if (_busqueda.isNotEmpty) {
              final q = _busqueda.toLowerCase();
              reservas = reservas
                  .where((r) =>
                      r.cliente
                          .toLowerCase()
                          .contains(q) ||
                      r.claseNombre
                          .toLowerCase()
                          .contains(q) ||
                      r.negocioNombre
                          .toLowerCase()
                          .contains(q))
                  .toList();
            }

            if (reservas.isEmpty) {
              return Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white24, size: 40),
                const SizedBox(height: 12),
                const Text(
                    'No hay reservas con estos filtros',
                    style: TextStyle(
                        color: Colors.white60)),
              ]));
            }

            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 6),
                child: Row(children: [
                  Text(
                      '${reservas.length} reserva${reservas.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 16),
                  itemCount: reservas.length,
                  itemBuilder: (context, i) =>
                      _ReservaCard(
                          reserva: reservas[i],
                          formatFecha: _formatFecha),
                ),
              ),
            ]);
          },
        ),
      ),
    ]);
  }

  Widget _chipN(String label, String? value) {
    final sel = _negocioFiltro == value;
    final color =
        value != null ? _colorNegocio(value) : Colors.white70;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            setState(() => _negocioFiltro = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: sel
                ? color.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: sel
                    ? color.withValues(alpha: 0.7)
                    : Colors.white
                        .withValues(alpha: 0.2)),
          ),
          child: Text(label,
              style: TextStyle(
                  color:
                      sel ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: sel
                      ? FontWeight.w600
                      : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _chipE(String label, String? value) {
    final sel = _estadoFiltro == value;
    return GestureDetector(
      onTap: () =>
          setState(() => _estadoFiltro = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sel
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white
                      .withValues(alpha: 0.15)),
        ),
        child: Text(label,
            style: TextStyle(
                color:
                    sel ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: sel
                    ? FontWeight.w600
                    : FontWeight.normal)),
      ),
    );
  }
}

// ─── RESERVA CARD ──────────────────────────────────────────────────────────

class _ReservaCard extends StatefulWidget {
  final Reserva reserva;
  final String Function(DateTime?) formatFecha;

  const _ReservaCard(
      {required this.reserva, required this.formatFecha});

  @override
  State<_ReservaCard> createState() =>
      _ReservaCardState();
}

class _ReservaCardState extends State<_ReservaCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.reserva;
    final color = _colorNegocio(r.negocioNombre);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(alpha: _expandido ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _expandido
                  ? color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.2),
              width: _expandido ? 1.5 : 1),
        ),
        child: Column(children: [
          InkWell(
            onTap: () =>
                setState(() => _expandido = !_expandido),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color:
                            color.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(10)),
                    child: Icon(
                        _iconoNegocio(r.negocioNombre),
                        color: color,
                        size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                  Text(r.claseNombre,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(r.cliente,
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(widget.formatFecha(r.fechaHora),
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10)),
                ])),
                _badgeEstado(r.estado),
                const SizedBox(width: 6),
                AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration:
                        const Duration(milliseconds: 200),
                    child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white54,
                        size: 22)),
              ]),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expandido ? _buildDetalle(color) : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }

  Widget _buildDetalle(Color color) {
    final r = widget.reserva;

    Widget fila(IconData icon, String label,
            String value) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 8),
            Text('$label: ',
                style: const TextStyle(
                    color: Colors.white60, fontSize: 12)),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12))),
          ]),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Divider(
            color: Colors.white.withValues(alpha: 0.15),
            height: 1),
        const SizedBox(height: 14),
        fila(Icons.business, 'Negocio', r.negocioNombre),
        fila(Icons.fitness_center, 'Clase',
            r.claseNombre),
        fila(Icons.person, 'Cliente', r.cliente),
        fila(Icons.access_time, 'Hora', r.hora),
        fila(Icons.calendar_today, 'Fecha',
            widget.formatFecha(r.fechaHora)),
        fila(Icons.info_outline, 'Estado', r.estado),
        fila(Icons.receipt_long, 'ID', r.id),
        const SizedBox(height: 14),
        Row(children: [
          if (r.estado == 'activa') ...[
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () => _confirmarDialog(
                        context,
                        titulo: 'Cancelar reserva',
                        mensaje:
                            '¿Cancelar la reserva de ${r.cliente} para ${r.claseNombre}?',
                        onConfirm: () =>
                            _FS.cancelarReserva(r.id)),
                    icon: const Icon(
                        Icons.cancel_outlined,
                        size: 15),
                    label: const Text('Cancelar reserva',
                        style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.orangeAccent,
                        side: const BorderSide(
                            color: Colors.orangeAccent),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    10))))),
            const SizedBox(width: 8),
          ],
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () => _confirmarDialog(
                      context,
                      titulo: 'Eliminar reserva',
                      mensaje:
                          '¿Eliminar esta reserva definitivamente?',
                      onConfirm: () =>
                          _FS.eliminarReserva(r.id)),
                  icon: const Icon(Icons.delete_outline,
                      size: 15),
                  label: const Text('Eliminar',
                      style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                          color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  10))))),
        ]),
      ]),
    );
  }
}