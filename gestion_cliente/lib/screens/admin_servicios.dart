import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ═══════════════════════════════════════════════════════════════════════════════
//  PÁGINA PRINCIPAL — GESTIÓN DE NEGOCIO (ADMIN)
// ═══════════════════════════════════════════════════════════════════════════════
class GestionNegocioAdmin extends StatefulWidget {
  const GestionNegocioAdmin({super.key});

  @override
  State<GestionNegocioAdmin> createState() => _GestionNegocioAdminState();
}

class _GestionNegocioAdminState extends State<GestionNegocioAdmin> {
  bool _localeOk   = false;
  bool _cargando   = true;
  String?           _negocio;
  DocumentReference? _negocioRef;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      if (mounted) setState(() => _localeOk = true);
    });
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    final doc  = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    final negocios = data['negocios'];

    if (negocios is List && negocios.isNotEmpty) {
      final nombre = negocios.first.toString();
      DocumentReference? ref;

      try {
        // Intento 1: el ID del documento = nombre del negocio
        final nd = await FirebaseFirestore.instance.collection('negocios').doc(nombre).get();
        ref = nd.exists ? nd.reference : null;

        // Intento 2: buscar por campo 'nombre'
        if (ref == null) {
          final q = await FirebaseFirestore.instance
              .collection('negocios')
              .where('nombre', isEqualTo: nombre)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) ref = q.docs.first.reference;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _negocio    = nombre;
          _negocioRef = ref;
          _cargando   = false;
        });
      }
    } else {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ─── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_cargando || !_localeOk) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E293B),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF64B5F6))),
      );
    }
    if (_negocio == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E293B),
        body: Center(child: Text('Sin negocio asignado', style: TextStyle(color: Colors.white))),
      );
    }

    final titulo = _negocio![0].toUpperCase() + _negocio!.substring(1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Gestión · $titulo',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('clases')
                .where('negocioID', isEqualTo: _negocio)
                .snapshots(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final docs = snap.data!.docs;

              return Column(
                children: [
                  _Banner(total: docs.length),
                  Expanded(
                    child: docs.isEmpty
                        ? const _Vacio()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                            itemCount: docs.length,
                            itemBuilder: (_, i) => _TarjetaClase(
                              doc:        docs[i],
                              negocio:    _negocio!,
                              negocioRef: _negocioRef,
                              index:      i,
                            ),
                          ),
                  ),
                  _BotonesAccion(
                    onNuevaClase:    () => _dlgNuevaClase(),
                    onNuevoProfesor: () => _dlgNuevoProfesor(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── DIÁLOGO: Nueva Clase ────────────────────────────────────────────────────
  Future<void> _dlgNuevaClase() async {
    final ctrl = TextEditingController();
    final fk   = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool loading = false;
        return StatefulBuilder(
          builder: (ctx, ss) => _DialogShell(
            titulo: 'Nueva Clase',
            icono:  Icons.class_outlined,
            color:  const Color(0xFF64B5F6),
            child: Form(
              key: fk,
              child: Column(children: [
                _Campo(
                  ctrl:      ctrl,
                  label:     'Nombre de la clase',
                  icono:     Icons.label_outline,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 22),
                _BtnPrimario(
                  label:   'Crear clase',
                  color:   const Color(0xFF64B5F6),
                  loading: loading,
                  onTap: () async {
                    if (!fk.currentState!.validate()) return;
                    ss(() => loading = true);
                    final name = ctrl.text.trim();
                    try {
                      final exists = await FirebaseFirestore.instance
                          .collection('clases').doc(name).get();
                      if (exists.exists) throw Exception('Ya existe una clase con ese nombre');

                      await FirebaseFirestore.instance.collection('clases').doc(name).set({
                        'nombre':           name,
                        'negocioID':        _negocio,
                        'negocioRef':       _negocioRef,
                        'employeeID':       '',
                        'fechasBloqueadas': [],
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted)    _snack('✅ Clase "$name" creada', Colors.green);
                    } catch (e) {
                      if (mounted) _snack('$e', Colors.red);
                    }
                    ss(() => loading = false);
                  },
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  // ─── DIÁLOGO: Nuevo Profesor ─────────────────────────────────────────────────
  Future<void> _dlgNuevoProfesor() async {
    // Solo clases sin profesor asignado
    final snap = await FirebaseFirestore.instance
        .collection('clases')
        .where('negocioID', isEqualTo: _negocio)
        .get();

    if (!mounted) return;

    if (snap.docs.isEmpty) {
      _snack('Primero crea al menos una clase', Colors.orange);
      return;
    }

    final libres = snap.docs.where((d) {
      final emp = (d.data() as Map)['employeeID'] ?? '';
      return emp.toString().trim().isEmpty;
    }).toList();

    if (libres.isEmpty) {
      _snack('Todas las clases ya tienen profesor asignado', Colors.orange);
      return;
    }

    final nombre   = TextEditingController();
    final apellidos = TextEditingController();
    final email    = TextEditingController();
    final pass     = TextEditingController();
    final tel      = TextEditingController();
    final dir      = TextEditingController();
    final edad     = TextEditingController();
    String? claseId;
    final fk = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        bool loading = false, verPass = false;
        return StatefulBuilder(
          builder: (ctx, ss) => _DialogShell(
            titulo: 'Nuevo Profesor',
            icono:  Icons.person_add_outlined,
            color:  const Color(0xFF81C784),
            child: Form(
              key: fk,
              child: Column(children: [
                _Campo(ctrl: nombre,    label: 'Nombre',    icono: Icons.person_outline,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Obligatorio' : null),
                const SizedBox(height: 10),
                _Campo(ctrl: apellidos, label: 'Apellidos', icono: Icons.person_outline,
                    validator: (v) => v?.trim().isEmpty ?? true ? 'Obligatorio' : null),
                const SizedBox(height: 10),
                _Campo(ctrl: email, label: 'Email', icono: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null),
                const SizedBox(height: 10),
                _Campo(
                  ctrl: pass, label: 'Contraseña', icono: Icons.lock_outline,
                  obscure: !verPass,
                  validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                  suffix: IconButton(
                    icon: Icon(verPass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white38, size: 18),
                    onPressed: () => ss(() => verPass = !verPass),
                  ),
                ),
                const SizedBox(height: 10),
                _Campo(ctrl: tel,  label: 'Teléfono (opcional)',  icono: Icons.phone_outlined,  keyboard: TextInputType.phone),
                const SizedBox(height: 10),
                _Campo(ctrl: dir,  label: 'Dirección (opcional)', icono: Icons.home_outlined),
                const SizedBox(height: 10),
                _Campo(ctrl: edad, label: 'Edad (opcional)',      icono: Icons.cake_outlined,   keyboard: TextInputType.number),
                const SizedBox(height: 10),

                // Dropdown de clases disponibles
                DropdownButtonFormField<String>(
                  initialValue: claseId,
                  dropdownColor: const Color(0xFF334155),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                  decoration: _dropDeco('Asignar a clase', Icons.class_outlined, const Color(0xFF81C784)),
                  items: libres.map((d) {
                    final n = (d.data() as Map)['nombre'] ?? d.id;
                    return DropdownMenuItem<String>(value: d.id, child: Text(n.toString()));
                  }).toList(),
                  onChanged: (v) => ss(() => claseId = v),
                  validator: (v) => v == null ? 'Selecciona una clase' : null,
                ),
                const SizedBox(height: 22),

                _BtnPrimario(
                  label:   'Crear profesor',
                  color:   const Color(0xFF81C784),
                  loading: loading,
                  onTap: () async {
                    if (!fk.currentState!.validate()) return;
                    ss(() => loading = true);

                    try {
                      // ── Secondary Firebase App ─────────────────────────────
                      // Crear un usuario Auth sin cerrar la sesión del admin.
                      FirebaseApp? secondary;
                      try {
                        secondary = await Firebase.initializeApp(
                          name: 'AdminCreation',
                          options: Firebase.app().options,
                        );
                      } catch (_) {
                        // Ya existe una instancia con ese nombre
                        secondary = Firebase.app('AdminCreation');
                      }

                      final auth2 = FirebaseAuth.instanceFor(app: secondary);
                      final cred  = await auth2.createUserWithEmailAndPassword(
                        email:    email.text.trim(),
                        password: pass.text.trim(),
                      );
                      final uid = cred.user!.uid;
                      await auth2.signOut();

                      // Limpiar la app secundaria para próximas creaciones
                      try { await secondary.delete(); } catch (_) {}

                      // ── Documento en users ─────────────────────────────────
                      await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'activo':         true,
                        'apellidos':      apellidos.text.trim(),
                        'direccion':      dir.text.trim(),
                        'edad':           int.tryParse(edad.text.trim()) ?? 0,
                        'email':          email.text.trim(),
                        'fecha_registro': Timestamp.now(),
                        'negocios':       [_negocio],
                        'nombre':         nombre.text.trim(),
                        'rol':            'worker',
                        'telefono':       tel.text.trim(),
                        'clase':          claseId,
                      });

                      // ── Actualizar employeeID en la clase ──────────────────
                      await FirebaseFirestore.instance
                          .collection('clases').doc(claseId)
                          .update({'employeeID': uid});

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted)    _snack('✅ Profesor creado correctamente', Colors.green);
                    } catch (e) {
                      if (mounted) _snack('Error: $e', Colors.red);
                    }
                    ss(() => loading = false);
                  },
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  void _snack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }
}

// InputDecoration compartida para Dropdowns
InputDecoration _dropDeco(String label, IconData icono, Color accent) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
  prefixIcon: Icon(icono, color: accent, size: 20),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white.withAlpha(40)),
      borderRadius: BorderRadius.circular(14)),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: accent),
      borderRadius: BorderRadius.circular(14)),
  errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(14)),
  focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(14)),
  filled: true,
  fillColor: Colors.white.withAlpha(10),
);

// ═══════════════════════════════════════════════════════════════════════════════
//  TARJETA DE CLASE  (cabecera del ExpansionTile)
// ═══════════════════════════════════════════════════════════════════════════════
class _TarjetaClase extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String                negocio;
  final DocumentReference?    negocioRef;
  final int                   index;

  const _TarjetaClase({
    required this.doc,
    required this.negocio,
    required this.negocioRef,
    required this.index,
  });

  @override
  State<_TarjetaClase> createState() => _TarjetaClaseState();
}

class _TarjetaClaseState extends State<_TarjetaClase> {
  String? _profNombre;

  @override
  void initState() {
    super.initState();
    _cargarProf();
  }

  @override
  void didUpdateWidget(covariant _TarjetaClase old) {
    super.didUpdateWidget(old);
    _cargarProf();
  }

  Future<void> _cargarProf() async {
    final data = widget.doc.data() as Map<String, dynamic>;
    final eid  = data['employeeID'] as String? ?? '';
    if (eid.isEmpty) { if (mounted) setState(() => _profNombre = null); return; }

    final d = await FirebaseFirestore.instance.collection('users').doc(eid).get();
    if (!mounted) return;

    if (d.exists) {
      final ud = d.data() as Map<String, dynamic>;
      setState(() => _profNombre = '${ud['nombre'] ?? ''} ${ud['apellidos'] ?? ''}'.trim());
    } else {
      setState(() => _profNombre = '—');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data      = widget.doc.data() as Map<String, dynamic>;
    final nombre    = data['nombre']    as String? ?? widget.doc.id;
    final eid       = data['employeeID'] as String? ?? '';
    final bloqueadas = List<Timestamp>.from(
      (data['fechasBloqueadas'] as List?)?.whereType<Timestamp>() ?? [],
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.index * 80),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color:        Colors.white.withValues(alpha: 0.07),
          border:       Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor:          Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              title: Row(children: [
                // Indicador de estado
                Container(
                  width: 4, height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: eid.isEmpty ? Colors.orange : const Color(0xFF81C784),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(nombre,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      eid.isEmpty ? 'Sin profesor asignado' : (_profNombre ?? 'Cargando...'),
                      style: TextStyle(
                        color: eid.isEmpty
                            ? Colors.orange.withAlpha(180)
                            : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ]),
                ),
                if (bloqueadas.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin:  const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bloqueadas.length} bloq.',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ]),
              children: [
                _CardBody(
                  doc:      widget.doc,
                  nombre:   nombre,
                  eid:      eid,
                  bloqueadas: bloqueadas,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CONTENIDO INTERIOR DE LA TARJETA
// ═══════════════════════════════════════════════════════════════════════════════
class _CardBody extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String                nombre;
  final String                eid;
  final List<Timestamp>       bloqueadas;

  const _CardBody({
    required this.doc,
    required this.nombre,
    required this.eid,
    required this.bloqueadas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      color: Colors.black.withValues(alpha: 0.15),
      child: Column(children: [

        // ── Información del profesor ───────────────────────────────────────────
        eid.isEmpty
            ? const _Fila(
                icono: Icons.person_off_outlined,
                texto: 'Sin profesor — crea uno desde los botones de abajo',
                color: Colors.orange,
              )
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(eid)
                    .snapshots(),
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return const _Fila(icono: Icons.person_outline, texto: 'Cargando...', color: Colors.white38);
                  }
                  if (!snap.data!.exists) {
                    return const _Fila(icono: Icons.person_off_outlined, texto: 'Perfil no encontrado', color: Colors.orange);
                  }
                  final ud    = snap.data!.data() as Map<String, dynamic>;
                  final np    = '${ud['nombre'] ?? ''} ${ud['apellidos'] ?? ''}'.trim();
                  final em    = ud['email']  as String? ?? '';
                  final activo = ud['activo'] as bool?   ?? true;

                  return Column(children: [
                    _Fila(
                      icono: activo ? Icons.verified_user_outlined : Icons.person_off_outlined,
                      texto: np.isEmpty ? 'Sin nombre' : np,
                      color: activo ? const Color(0xFF81C784) : Colors.orange,
                    ),
                    _Fila(icono: Icons.email_outlined, texto: em, color: Colors.white54),
                    const SizedBox(height: 4),

                    // Toggle activo/inactivo
                    Row(children: [
                      Icon(
                        activo ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                        color: activo ? const Color(0xFF81C784) : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activo ? 'Cuenta activa' : 'Cuenta suspendida',
                        style: TextStyle(
                            color: activo ? const Color(0xFF81C784) : Colors.redAccent,
                            fontSize: 13),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: activo,
                          activeThumbColor: const Color(0xFF81C784),
                          inactiveThumbColor: Colors.redAccent,
                          onChanged: (v) => FirebaseFirestore.instance
                              .collection('users').doc(eid).update({'activo': v}),
                        ),
                      ),
                    ]),
                  ]);
                },
              ),

        const Divider(color: Colors.white12, height: 24),

        // ── Resumen fechas bloqueadas ──────────────────────────────────────────
        Row(children: [
          const Icon(Icons.event_busy_outlined, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text(
            bloqueadas.isEmpty
                ? 'Sin días bloqueados'
                : '${bloqueadas.length} ${bloqueadas.length == 1 ? "día bloqueado" : "días bloqueados"}',
            style: TextStyle(
              color: bloqueadas.isEmpty ? Colors.white38 : Colors.redAccent,
              fontSize: 13,
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // ── Botón calendario de bloqueo ────────────────────────────────────────
        _BtnSec(
          icono:  Icons.calendar_month_outlined,
          label:  'Gestionar días bloqueados',
          color:  const Color(0xFFFFB74D),
          onTap: () => showDialog(
            context: context,
            builder: (_) => _DlgCalendario(
              claseDoc:  doc,
              eid:       eid,
              bloqueadas: bloqueadas,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Botón eliminar clase ───────────────────────────────────────────────
        _BtnSec(
          icono:  Icons.delete_outline,
          label:  'Eliminar clase',
          color:  Colors.redAccent.shade100,
          onTap: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Eliminar clase',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Text(
                '¿Eliminar "$nombre"? Esta acción no se puede deshacer.',
                style: const TextStyle(color: Colors.white60),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    FirebaseFirestore.instance.collection('clases').doc(doc.id).delete();
                  },
                  child: const Text('Eliminar',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  DIÁLOGO: CALENDARIO DE BLOQUEO
// ═══════════════════════════════════════════════════════════════════════════════
class _DlgCalendario extends StatefulWidget {
  final QueryDocumentSnapshot claseDoc;
  final String                eid;
  final List<Timestamp>       bloqueadas;

  const _DlgCalendario({
    required this.claseDoc,
    required this.eid,
    required this.bloqueadas,
  });

  @override
  State<_DlgCalendario> createState() => _DlgCalendarioState();
}

class _DlgCalendarioState extends State<_DlgCalendario> {
  late List<DateTime> _bloqs;
  late DateTime       _mes;
  bool                _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes  = DateTime(now.year, now.month);
    _bloqs = widget.bloqueadas.map((t) {
      final d = t.toDate();
      return DateTime(d.year, d.month, d.day);
    }).toList();
  }

  bool _esBloq(DateTime d)   => _bloqs.any((b) => b.year == d.year && b.month == d.month && b.day == d.day);
  bool _esPasado(DateTime d) {
    final h = DateTime.now();
    return d.isBefore(DateTime(h.year, h.month, h.day));
  }
  bool _esHoy(DateTime d) {
    final h = DateTime.now();
    return d.year == h.year && d.month == h.month && d.day == h.day;
  }

  Future<void> _toggle(DateTime dia) async {
    final bloq = _esBloq(dia);
    setState(() {
      bloq
          ? _bloqs.removeWhere((b) => b.year == dia.year && b.month == dia.month && b.day == dia.day)
          : _bloqs.add(dia);
    });

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('clases').doc(widget.claseDoc.id)
          .update({'fechasBloqueadas': _bloqs.map((d) => Timestamp.fromDate(d)).toList()});

      // Si se acaba de bloquear, eliminar reservas de ese día
      if (!bloq && widget.eid.isNotEmpty) await _deleteReservas(dia);
    } catch (_) {
      // Revertir en caso de error
      setState(() {
        bloq
            ? _bloqs.add(dia)
            : _bloqs.removeWhere((b) => b.year == dia.year && b.month == dia.month && b.day == dia.day);
      });
    }
    setState(() => _saving = false);
  }

  Future<void> _deleteReservas(DateTime dia) async {
    final from = Timestamp.fromDate(DateTime(dia.year, dia.month, dia.day, 0,  0,  0));
    final to   = Timestamp.fromDate(DateTime(dia.year, dia.month, dia.day, 23, 59, 59));

    final res = await FirebaseFirestore.instance
        .collection('reservas')
        .where('employeeID', isEqualTo: widget.eid)
        .where('fechaHora',  isGreaterThanOrEqualTo: from)
        .where('fechaHora',  isLessThanOrEqualTo:    to)
        .get();

    final batch = FirebaseFirestore.instance.batch();
      for (final r in res.docs) {
        batch.delete(r.reference);
      }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:  const Color(0xFF1E293B).withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withAlpha(30)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              // Cabecera
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withAlpha(30),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.calendar_month_outlined,
                      color: Color(0xFFFFB74D), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Días bloqueados',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (_saving)
                  const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB74D)),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),

              const SizedBox(height: 6),
              Text(
                'Toca un día para bloquearlo o desbloquearlo.\nLas reservas existentes se eliminarán automáticamente.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Navegación de mes
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white60),
                  onPressed: () => setState(() => _mes = DateTime(_mes.year, _mes.month - 1)),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'es_ES').format(_mes),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white60),
                  onPressed: () => setState(() => _mes = DateTime(_mes.year, _mes.month + 1)),
                ),
              ]),

              // Cabecera días de la semana
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá', 'Do'].map((d) =>
                    SizedBox(
                      width: 38,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ).toList(),
                ),
              ),

              _buildGrid(),

              const SizedBox(height: 14),

              // Leyenda
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Leyenda(color: const Color(0xFFFFB74D).withAlpha(200), label: 'Bloqueado'),
                const SizedBox(width: 14),
                _Leyenda(color: const Color(0xFF64B5F6).withAlpha(60),  label: 'Hoy'),
                const SizedBox(width: 14),
                _Leyenda(color: Colors.white.withAlpha(18),              label: 'Libre'),
                const SizedBox(width: 14),
                _Leyenda(color: Colors.white.withAlpha(8),               label: 'Pasado'),
              ]),

              if (_bloqs.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${_bloqs.length} ${_bloqs.length == 1 ? "día bloqueado" : "días bloqueados"} en total',
                  style: const TextStyle(
                      color: Color(0xFFFFB74D), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final firstDay    = DateTime(_mes.year, _mes.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_mes.year, _mes.month);
    final offset      = firstDay.weekday - 1; // Lunes = 0

    final cells = <DateTime?>[
      ...List.filled(offset, null),
      ...List.generate(daysInMonth, (i) => DateTime(_mes.year, _mes.month, i + 1)),
    ];
    // Completar última fila
    while (cells.length % 7 != 0) { cells.add(null);
    }

    final rows = <TableRow>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(TableRow(
        children: List.generate(7, (j) {
          final d = cells[i + j];
          if (d == null) return const SizedBox(height: 42);

          final bloq  = _esBloq(d);
          final pasado = _esPasado(d);
          final hoy   = _esHoy(d);

          return GestureDetector(
            onTap: pasado ? null : () => _toggle(d),
            child: Container(
              height: 40, margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: bloq
                    ? const Color(0xFFFFB74D).withAlpha(200)
                    : pasado
                        ? Colors.white.withAlpha(8)
                        : hoy
                            ? const Color(0xFF64B5F6).withAlpha(60)
                            : Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
                border: hoy && !bloq
                    ? Border.all(color: const Color(0xFF64B5F6), width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    color: bloq
                        ? const Color(0xFF1E293B)
                        : pasado
                            ? Colors.white70
                            : Colors.white,
                    fontSize: 13,
                    fontWeight: bloq || hoy ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ));
    }

    return Table(children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  WIDGETS COMPARTIDOS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Banner superior ──────────────────────────────────────────────────────────
class _Banner extends StatelessWidget {
  final int total;
  const _Banner({required this.total});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color:  Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(40)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.business_center_outlined, color: Color(0xFF64B5F6)),
            const SizedBox(width: 12),
            Text(
              '$total ${total == 1 ? "clase configurada" : "clases configuradas"}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ]),
        ),
      ),
    ),
  );
}

// ── Estado vacío ─────────────────────────────────────────────────────────────
class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.class_outlined, size: 52, color: Colors.white24),
      SizedBox(height: 14),
      Text('Sin clases todavía',
          style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w500)),
      SizedBox(height: 6),
      Text('Usa los botones de abajo para añadir',
          style: TextStyle(color: Colors.white30, fontSize: 13)),
    ]),
  );
}

// ── Fila de botones de acción ─────────────────────────────────────────────────
class _BotonesAccion extends StatelessWidget {
  final VoidCallback onNuevaClase;
  final VoidCallback onNuevoProfesor;
  const _BotonesAccion({required this.onNuevaClase, required this.onNuevoProfesor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
    child: Row(children: [
      Expanded(
        child: _BtnAccion(
          icono: Icons.add_circle_outline,
          label: 'Nueva Clase',
          color: const Color(0xFF64B5F6),
          onTap: onNuevaClase,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _BtnAccion(
          icono: Icons.person_add_outlined,
          label: 'Nuevo Profesor',
          color: const Color(0xFF81C784),
          onTap: onNuevoProfesor,
        ),
      ),
    ]),
  );
}

// ── Botón principal de acción (parte inferior) ────────────────────────────────
class _BtnAccion extends StatelessWidget {
  final IconData icono; final String label; final Color color; final VoidCallback onTap;
  const _BtnAccion({required this.icono, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:  color.withAlpha(35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icono, color: color, size: 26),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    ),
  );
}

// ── Botón secundario (dentro de tarjeta) ──────────────────────────────────────
class _BtnSec extends StatelessWidget {
  final IconData icono; final String label; final Color color; final VoidCallback onTap;
  const _BtnSec({required this.icono, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color:  color.withAlpha(22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(55)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icono, color: color, size: 17),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ),
  );
}

// ── Shell de diálogo ─────────────────────────────────────────────────────────
class _DialogShell extends StatelessWidget {
  final String titulo; final IconData icono; final Color color; final Widget child;
  const _DialogShell({required this.titulo, required this.icono, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:  const Color(0xFF1E293B).withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(30)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icono, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              const SizedBox(height: 20),
              child,
            ]),
          ),
        ),
      ),
    ),
  );
}

// ── Campo de texto del formulario ─────────────────────────────────────────────
class _Campo extends StatelessWidget {
  final TextEditingController      ctrl;
  final String                     label;
  final IconData                   icono;
  final TextInputType?             keyboard;
  final bool                       obscure;
  final String? Function(String?)? validator;
  final Widget?                    suffix;

  const _Campo({
    required this.ctrl,
    required this.label,
    required this.icono,
    this.keyboard,
    this.obscure   = false,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, keyboardType: keyboard, obscureText: obscure, validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    decoration: InputDecoration(
      labelText:  label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      prefixIcon: Icon(icono, color: Colors.white38, size: 20),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withAlpha(40)),
          borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF64B5F6)),
          borderRadius: BorderRadius.circular(14)),
      errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(14)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(14)),
      filled:    true,
      fillColor: Colors.white.withAlpha(10),
    ),
  );
}

// ── Botón primario (submit del formulario) ────────────────────────────────────
class _BtnPrimario extends StatelessWidget {
  final String   label; final Color color; final bool loading; final VoidCallback onTap;
  const _BtnPrimario({required this.label, required this.color, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor:         color,
        disabledBackgroundColor: color.withAlpha(100),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: loading
          ? SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withAlpha(200)))
          : Text(label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    ),
  );
}

// ── Fila de info (icono + texto) ──────────────────────────────────────────────
class _Fila extends StatelessWidget {
  final IconData icono; final String texto; final Color color;
  const _Fila({required this.icono, required this.texto, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icono, size: 15, color: color),
      const SizedBox(width: 10),
      Expanded(
        child: Text(texto,
            style: TextStyle(color: color, fontSize: 13),
            overflow: TextOverflow.ellipsis),
      ),
    ]),
  );
}

// ── Elemento de leyenda ───────────────────────────────────────────────────────
class _Leyenda extends StatelessWidget {
  final Color color; final String label;
  const _Leyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 11, height: 11,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    ),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
  ]);
}