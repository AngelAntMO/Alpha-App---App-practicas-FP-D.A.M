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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _buttonPressed = false;
  bool _isLoading = false;
  String? _generatedCode;

  // --- LÓGICA DE ENVÍO DE EMAIL ---
  Future<void> _sendEmail(String email, String code) async {
    const serviceId = 'service_sziirym'; 
    const templateId = 'template_ecuyrkp';
    const publicKey = 'NRbnnLuNptqqUU1eb';

    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost', 
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'user_email': email,
            'passcode': code,
            'time': '15 minutos',
          }
        }),
      );
    } catch (e) {
      debugPrint("Error enviando email: $e");
    }
  }

  Future<void> saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      String? token = await messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {'fcmToken': token}, 
          SetOptions(merge: true)
        );
      }
    } catch (e) {
      debugPrint("Error guardando token: $e");
    }
  }

  // --- POP-UP DE VERIFICACIÓN (TU DISEÑO) ---
  void _mostrarPopUpCodigo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E293B).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            title: const Text("Verificación de Email", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Introduce el código enviado a tu email", 
                  style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                _glassField(
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "000000",
                      hintStyle: TextStyle(color: Colors.white24, letterSpacing: 0),
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  otpController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Cancelar", style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: verificarYEntrar,
                child: const Text("Verificar"),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- LÓGICA DE LOGIN (ESTRATEGIA DE VERIFICACIÓN COMPATIBLE) ---
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Por favor, rellena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      /* 
         MÉTODO DE VERIFICACIÓN: 
         Intentamos un login con una contraseña falsa. 
         - Si el error es 'user-not-found', el correo NO existe.
         - Si el error es 'wrong-password' o 'invalid-credential', el correo SÍ existe.
      */
      bool existe = false;
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: "comprobacion_de_existencia_temporal_123",
        );
      } on FirebaseAuthException catch (e) {
        // En versiones nuevas, 'invalid-credential' es el código genérico.
        // Pero si la consola de Firebase tiene desactivada la protección de enumeración,
        // 'user-not-found' funcionará perfectamente.
        if (e.code == 'user-not-found') {
          existe = false;
        } else {
          // Cualquier otro error (como contraseña incorrecta) significa que el correo existe.
          existe = true;
        }
      }

      if (!existe) {
        _mostrarMensaje("Este correo no está registrado.");
        setState(() => _isLoading = false);
        return;
      }

      // Si existe, enviamos el código y abrimos popup
      _generatedCode = (Random().nextInt(900000) + 100000).toString();
      await _sendEmail(email, _generatedCode!);
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarPopUpCodigo();

    } catch (e) {
      setState(() => _isLoading = false);
      _mostrarMensaje("Error de conexión");
    }
  }

  Future<void> verificarYEntrar() async {
    if (otpController.text == _generatedCode) {
      try {
        Navigator.pop(context);
        setState(() => _isLoading = true);

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        await _finalizarAcceso();
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        _mostrarMensaje("Contraseña o datos incorrectos");
      }
    } else {
      _mostrarMensaje("Código incorrecto");
    }
  }

  Future<void> _finalizarAcceso() async {
    await saveFcmToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootPage()),
      (route) => false,
    );
  }

  void _mostrarMensaje(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
          leading: (Navigator.canPop(context) ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)) : null),
          title: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: screenWidth * 0.10,
              right: screenWidth * 0.10,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/LogoAlphaAppPagInicio.png', width: 180),
                const SizedBox(height: 40),

                _glassField(AnimatedTextField(label: 'Email', controller: emailController, textInputAction: TextInputAction.next)),
                const SizedBox(height: 20),
                _glassField(AnimatedTextField(label: 'Contraseña', isPasswordField: true, controller: passwordController, textInputAction: TextInputAction.done, onSubmitted: login)),

                const SizedBox(height: 40),
                
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
                        height: 55,
                        width: 220, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: _buttonPressed
                                ? [const Color(0xFF2F6FE4), const Color(0xFF4D94FF)]
                                : [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(_buttonPressed ? 0.2 : 0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Iniciar sesión', 
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

// Clase AnimatedTextField (Tus estilos originales)
class AnimatedTextField extends StatefulWidget {
  final String label;
  final bool isPasswordField;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const AnimatedTextField({required this.label, this.isPasswordField = false, required this.controller, this.textInputAction, this.onSubmitted, super.key});

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      textInputAction: widget.textInputAction,
      onSubmitted: (value) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: _hasFocus ? Colors.white : Colors.white70),
        hintText: widget.label,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: widget.isPasswordField 
          ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            )
          : null,
      ),
    );
  }
}