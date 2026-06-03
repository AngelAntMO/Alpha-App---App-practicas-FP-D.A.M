import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  bool loading = false;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  Map<String, bool> negocios = {
    "Gimnasio": false,
    "Yoga": false,
    "Peluqueria": false,
    "Fisioterapia": false,
    "Academia": false,
  };

  @override
  void dispose() {
    // Evita fugas de memoria liberando los controladores
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    edadController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    // Validación básica de campos vacíos
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena los campos obligatorios')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;

      List<String> negociosSeleccionados = negocios.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        "nombre": nombreController.text.trim(),
        "apellidos": apellidoController.text.trim(),
        "email": user.email,
        "telefono": telefonoController.text.trim(),
        "direccion": direccionController.text.trim(),
        "edad": int.tryParse(edadController.text.trim()) ?? 0,
        "rol": "usuario",
        "negocios": negociosSeleccionados,
        "activo": true,
        "fecha_registro": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado correctamente')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Ocurrió un error inesperado';

      if (e.code == 'email-already-in-use') {
        mensaje = 'El email ya está en uso';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El formato del email no es válido';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
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
          title: const Text("Registro"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _glassField(_input(nombreController, "Nombre *", Icons.person)),
                  const SizedBox(height: 12),
                  _glassField(_input(apellidoController, "Apellidos", Icons.person_outline)),
                  const SizedBox(height: 12),
                  _glassField(_input(emailController, "Email *", Icons.email)),
                  const SizedBox(height: 12),
                  _glassField(_input(telefonoController, "Teléfono", Icons.phone)),
                  const SizedBox(height: 12),
                  _glassField(_input(direccionController, "Dirección", Icons.location_on)),
                  const SizedBox(height: 12),
                  _glassField(_input(edadController, "Edad", Icons.cake, number: true)),
                  const SizedBox(height: 12),
                  _glassField(_passwordField()),
                  const SizedBox(height: 12),
                  _glassField(_confirmPasswordField()),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Tipo de negocio",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...negocios.keys.map((key) {
                    return CheckboxListTile(
                      activeColor: Colors.blueAccent,
                      title: Text(
                        key,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: negocios[key],
                      onChanged: (value) {
                        setState(() => negocios[key] = value!);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: loading ? null : register,
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Registrarse",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassField(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon, {
    bool number = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label, // Cambiado de labelText a hintText
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  // INPUT CONTRASEÑA
  Widget _passwordField() {
    return TextField(
      controller: passwordController,
      obscureText: isPasswordHidden,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Contraseña *", // Cambiado de labelText a hintText
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  // INPUT CONFIRMAR CONTRASEÑA 
  Widget _confirmPasswordField() {
    return TextField(
      controller: confirmPasswordController,
      obscureText: isConfirmPasswordHidden,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Confirmar contraseña *", // Cambiado de labelText a hintText
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            isConfirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () => setState(
            () => isConfirmPasswordHidden = !isConfirmPasswordHidden,
          ),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}