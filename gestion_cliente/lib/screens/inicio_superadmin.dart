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

// ─── DATOS ─────────────────────────────────────────────────────────────────

final List<Negocio> negocios = [
  Negocio(
    nombre: 'Academia',
    icono: Icons.school,
    color: Color(0xFF3B82F6),
    servicios: [
      Servicio(nombre: 'Inglés', precio: 30, duracionMinutos: 60, descripcion: 'Clases de inglés todos los niveles.', activo: true),
      Servicio(nombre: 'Matemáticas', precio: 25, duracionMinutos: 60, descripcion: 'Clases de matemáticas y álgebra.', activo: true),
      Servicio(nombre: 'Repaso', precio: 20, duracionMinutos: 45, descripcion: 'Repaso general para exámenes.', activo: false),
    ],
  ),
  Negocio(
    nombre: 'Fisioterapeuta',
    icono: Icons.healing,
    color: Color(0xFF10B981),
    servicios: [
      Servicio(nombre: 'Especialista 1', precio: 50, duracionMinutos: 45, descripcion: 'Fisioterapia deportiva.', activo: true),
      Servicio(nombre: 'Especialista 2', precio: 50, duracionMinutos: 45, descripcion: 'Rehabilitación postoperatoria.', activo: true),
      Servicio(nombre: 'Especialista 3', precio: 55, duracionMinutos: 60, descripcion: 'Fisioterapia neurológica.', activo: true),
      Servicio(nombre: 'Especialista 4', precio: 45, duracionMinutos: 45, descripcion: 'Masaje terapéutico.', activo: false),
      Servicio(nombre: 'Especialista 5', precio: 60, duracionMinutos: 60, descripcion: 'Osteopatía.', activo: true),
    ],
  ),
  Negocio(
    nombre: 'Gimnasio',
    icono: Icons.fitness_center,
    color: Color(0xFFF59E0B),
    servicios: [
      Servicio(nombre: 'Sala Fitness', precio: 15, duracionMinutos: 60, descripcion: 'Acceso libre a sala de máquinas.', activo: true),
      Servicio(nombre: 'Spinning', precio: 10, duracionMinutos: 45, descripcion: 'Clase grupal de ciclismo indoor.', activo: true),
      Servicio(nombre: 'CrossTraining', precio: 12, duracionMinutos: 60, descripcion: 'Entrenamiento funcional de alta intensidad.', activo: true),
      Servicio(nombre: 'Boxeo', precio: 12, duracionMinutos: 60, descripcion: 'Técnica y cardio de boxeo.', activo: false),
      Servicio(nombre: 'Zumba', precio: 8, duracionMinutos: 45, descripcion: 'Baile fitness divertido.', activo: true),
    ],
  ),
  Negocio(
    nombre: 'Peluquería',
    icono: Icons.content_cut,
    color: Color(0xFFEC4899),
    servicios: [
      Servicio(nombre: 'Corte Caballeros', precio: 15, duracionMinutos: 30, descripcion: 'Corte clásico o moderno para hombre.', activo: true),
      Servicio(nombre: 'Corte Dama', precio: 25, duracionMinutos: 45, descripcion: 'Corte y peinado para mujer.', activo: true),
      Servicio(nombre: 'Coloración', precio: 60, duracionMinutos: 120, descripcion: 'Tinte completo con productos profesionales.', activo: true),
      Servicio(nombre: 'Tratamiento Capilar', precio: 35, duracionMinutos: 60, descripcion: 'Hidratación y nutrición del cabello.', activo: true),
      Servicio(nombre: 'Barbería', precio: 18, duracionMinutos: 30, descripcion: 'Arreglo de barba y bigote.', activo: false),
    ],
  ),
  Negocio(
    nombre: 'Yoga',
    icono: Icons.self_improvement,
    color: Color(0xFF8B5CF6),
    servicios: [
      Servicio(nombre: 'Yoga Suave', precio: 10, duracionMinutos: 60, descripcion: 'Posturas suaves para principiantes.', activo: true),
      Servicio(nombre: 'Vinyasa', precio: 12, duracionMinutos: 60, descripcion: 'Flujo dinámico de posturas.', activo: true),
      Servicio(nombre: 'Power Yoga', precio: 12, duracionMinutos: 60, descripcion: 'Yoga de alta intensidad y fuerza.', activo: true),
      Servicio(nombre: 'Meditación', precio: 8, duracionMinutos: 45, descripcion: 'Técnicas de mindfulness y relajación.', activo: true),
    ],
  ),
];

// ─── PANTALLA PRINCIPAL ADMIN ──────────────────────────────────────────────

class InicioSuperAdmin extends StatefulWidget {
  const InicioSuperAdmin({super.key});

  @override
  State<InicioSuperAdmin> createState() => _InicioSuperAdminState();
}

class _InicioSuperAdminState extends State<InicioSuperAdmin> {
  int _tabIndex = 0; // 0=Negocio, 1=Trabajadores, 2=Usuarios, 3=Reservas

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
          elevation: 0,
          backgroundColor: Colors.transparent,
          leadingWidth: 160,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Image.asset('assets/images/Icono_AlphaApp.png', fit: BoxFit.contain),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () async => await FirebaseAuth.instance.signOut(),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            // ── Tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTab(0, Icons.business, 'Negocio'),
                  _buildTab(1, Icons.engineering, 'Trabajadores'),
                  _buildTab(2, Icons.people, 'Usuarios'),
                  _buildTab(3, Icons.calendar_today, 'Reservas'),
                ],
              ),
            ),
            // ── Contenido ──
            Expanded(
              child: _tabIndex == 0
                  ? const _NegocioTab()
                  : _PlaceholderTab(label: ['Trabajadores', 'Usuarios', 'Reservas'][_tabIndex - 1]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final selected = _tabIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => _tabIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? Colors.white.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? Colors.white : Colors.white60, size: 20),
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
          ),
        ),
      ),
    );
  }
}

// ─── TAB NEGOCIO ───────────────────────────────────────────────────────────

class _NegocioTab extends StatelessWidget {
  const _NegocioTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GridView.builder(
        itemCount: negocios.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemBuilder: (context, i) {
          final negocio = negocios[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _ServiciosScreen(negocio: negocio)),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: negocio.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(negocio.icono, color: negocio.color, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    negocio.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${negocio.servicios.length} servicios',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── PANTALLA SERVICIOS ────────────────────────────────────────────────────

class _ServiciosScreen extends StatelessWidget {
  final Negocio negocio;
  const _ServiciosScreen({required this.negocio});

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Icon(negocio.icono, color: negocio.color, size: 20),
              const SizedBox(width: 8),
              Text(negocio.nombre, style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: negocio.servicios.length,
          itemBuilder: (context, i) {
            final s = negocio.servicios[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _DetalleServicioScreen(servicio: s, color: negocio.color),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: negocio.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(negocio.icono, color: negocio.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.nombre, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text('${s.duracionMinutos} min · ${s.precio.toStringAsFixed(0)}€',
                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.activo ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s.activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: s.activo ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── PANTALLA DETALLE / EDICIÓN ────────────────────────────────────────────

class _DetalleServicioScreen extends StatefulWidget {
  final Servicio servicio;
  final Color color;
  const _DetalleServicioScreen({required this.servicio, required this.color});

  @override
  State<_DetalleServicioScreen> createState() => _DetalleServicioScreenState();
}

class _DetalleServicioScreenState extends State<_DetalleServicioScreen> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _duracionCtrl;
  late TextEditingController _descCtrl;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.servicio.nombre);
    _precioCtrl = TextEditingController(text: widget.servicio.precio.toStringAsFixed(0));
    _duracionCtrl = TextEditingController(text: widget.servicio.duracionMinutos.toString());
    _descCtrl = TextEditingController(text: widget.servicio.descripcion);
    _activo = widget.servicio.activo;
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
    // Aquí guardarás en Firestore
    widget.servicio.nombre = _nombreCtrl.text;
    widget.servicio.precio = double.tryParse(_precioCtrl.text) ?? widget.servicio.precio;
    widget.servicio.duracionMinutos = int.tryParse(_duracionCtrl.text) ?? widget.servicio.duracionMinutos;
    widget.servicio.descripcion = _descCtrl.text;
    widget.servicio.activo = _activo;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Servicio guardado correctamente'),
        backgroundColor: widget.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('Editar servicio', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: _guardar,
              child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Cabecera de color ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.color.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.edit_note, color: widget.color, size: 36),
                    const SizedBox(height: 8),
                    Text(widget.servicio.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Campos ──
              _buildField('Nombre del servicio', _nombreCtrl, Icons.label),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildField('Precio (€)', _precioCtrl, Icons.euro, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField('Duración (min)', _duracionCtrl, Icons.timer, isNumber: true)),
                ],
              ),
              const SizedBox(height: 12),
              _buildField('Descripción', _descCtrl, Icons.description, maxLines: 3),
              const SizedBox(height: 12),

              // ── Toggle activo ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Servicio activo', style: TextStyle(color: Colors.white, fontSize: 15)),
                  subtitle: Text(
                    _activo ? 'Visible para los clientes' : 'Oculto para los clientes',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  value: _activo,
                  activeColor: widget.color,
                  onChanged: (v) => setState(() => _activo = v),
                ),
              ),
              const SizedBox(height: 28),

              // ── Botón guardar ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                 child: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54, size: 18),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: widget.color, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PLACEHOLDER para las otras tabs ──────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sección $label\n(próximamente)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white60, fontSize: 16),
      ),
    );
  }
}