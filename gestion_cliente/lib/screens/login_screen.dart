import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_cliente/screens/root_page.dart';
import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Configuración de Administrador
  final String _masterPasswordActual = "ADMIN1234";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController masterPassController = TextEditingController();

  bool _buttonPressed = false;
  bool _isLoading = false;
  bool _isAdminMode = false;
  String? _generatedCode;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    masterPassController.dispose();
    super.dispose();
  }

  // --- 1. LÓGICA DEL CHECKBOX ADMIN ---
  void _gestionarCambioAdmin(bool? valor) {
    if (valor == true) {
      masterPassController.clear();
      _mostrarPopUpMasterPass();
    } else {
      setState(() => _isAdminMode = false);
    }
  }

  void _mostrarPopUpMasterPass() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: const Text("🔐 Acceso Admin", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Introduce la clave maestra", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              _glassField(
                TextField(
                  controller: masterPassController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "••••", hintStyle: TextStyle(color: Colors.white24)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () {
                if (masterPassController.text == _masterPasswordActual) {
                  setState(() => _isAdminMode = true);
                  Navigator.pop(dialogContext);
                } else {
                  _mostrarMensaje("Clave incorrecta");
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. LÓGICA DE LOGIN ---
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor, rellena todos los campos");
      return;
    }

    if (_isAdminMode) {
      setState(() => _isLoading = true);
      _procederLoginFirebase(email, password);
    } else {
      // MODO USUARIO: Generar código y mostrar Pop-up antes de entrar
      _generatedCode = (Random().nextInt(900000) + 100000).toString();
      _sendEmail(email, _generatedCode!); 
      _mostrarPopUpGmail(email, password);
    }
  }

  // --- 3. POP-UP GMAIL (SIN OVERFLOW Y SIN ERRORES DE CONTROLADOR) ---
  void _mostrarPopUpGmail(String email, String password) {
    otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E293B).withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Verificación", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView( // EVITA RAYAS AMARILLAS
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Introduce el código enviado a tu Gmail", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    _glassField(
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 5),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: "000000", hintStyle: TextStyle(color: Colors.white24, letterSpacing: 0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cerrar", style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: () async {
                  if (otpController.text == _generatedCode) {
                    Navigator.pop(dialogContext);
                    setState(() => _isLoading = true);
                    _procederLoginFirebase(email, password);
                  } else {
                    _mostrarMensaje("Código incorrecto");
                  }
                },
                child: const Text("Verificar"),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. FINALIZAR LOGIN Y NAVEGACIÓN ---
  Future<void> _procederLoginFirebase(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final messaging = FirebaseMessaging.instance;
          await messaging.requestPermission();
          String? token = await messaging.getToken();
          if (token != null) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'fcmToken': token}, SetOptions(merge: true));
          }
        } catch (e) { debugPrint("Error FCM: $e"); }
      }
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const RootPage()), (route) => false);
    } on FirebaseAuthException catch (_) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Email o contraseña incorrectos");
    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Error de conexión");
    }
  }

  Future<void> _sendEmail(String email, String code) async {
    try {
      await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json', 'origin': 'http://localhost'},
        body: json.encode({
          'service_id': 'service_sziirym',
          'template_id': 'template_ecuyrkp',
          'user_id': 'NRbnnLuNptqqUU1eb',
          'template_params': {'user_email': email, 'passcode': code, 'time': '15 minutos'}
        }),
      );
    } catch (e) { debugPrint("Error email: $e"); }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  // --- 5. DISEÑO DE INTERFAZ ---
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.10),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/LogoAlphaAppPagInicio.png', width: 180, errorBuilder: (c, e, s) => const Icon(Icons.lock, size: 50, color: Colors.white)),
                const SizedBox(height: 40),
                _glassField(AnimatedTextField(label: 'Email', controller: emailController, textInputAction: TextInputAction.next)),
                const SizedBox(height: 20),
                _glassField(AnimatedTextField(label: 'Contraseña', isPasswordField: true, controller: passwordController, onSubmitted: login)),
                const SizedBox(height: 15),
                _glassField(
                  Theme(
                    data: ThemeData(unselectedWidgetColor: Colors.white70),
                    child: CheckboxListTile(
                      title: const Text("Entrar como administrador", style: TextStyle(color: Colors.white, fontSize: 13)),
                      value: _isAdminMode,
                      activeColor: Colors.blueAccent,
                      onChanged: _gestionarCambioAdmin,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _buttonPressed = true),
                    onTapUp: (_) => setState(() => _buttonPressed = false),
                    onTapCancel: () => setState(() => _buttonPressed = false),
                    onTap: _isLoading ? null : login,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 120),
                      scale: _buttonPressed ? 0.96 : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        height: 55, width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
                          boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                  child: const Text('¿No tienes cuenta? Regístrate', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassField(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// --- COMPONENTE DE TEXTO ANIMADO ---
class AnimatedTextField extends StatefulWidget {
  final String label;
  final bool isPasswordField;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  const AnimatedTextField({required this.label, this.isPasswordField = false, required this.controller, this.textInputAction, this.onSubmitted, super.key});
  @override State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}
class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  late bool _obscureText;
  @override void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
  }
  @override Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: TextStyle(color: _hasFocus ? Colors.white : Colors.white70),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: widget.isPasswordField ? IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70), onPressed: () => setState(() => _obscureText = !_obscureText)) : null,
      ),
    );
  }
}