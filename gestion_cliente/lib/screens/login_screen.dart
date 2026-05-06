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
  final String _masterPasswordActual = "ADMIN1234";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController masterPassController = TextEditingController();

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
          backgroundColor: const Color(0xFF1E293B).withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("🔐 Clave Maestra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          content: SizedBox(
            width: 300,
            child: _glassField(
              TextField(
                controller: masterPassController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(border: InputBorder.none, hintText: "••••", hintStyle: TextStyle(color: Colors.white24)),
              ),
            ),
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
              child: const Text("Entrar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje("Rellena todos los campos");
      return;
    }

    if (_isAdminMode) {
      setState(() => _isLoading = true);
      _procederLoginFirebase(email, password);
    } else {
      _generatedCode = (Random().nextInt(900000) + 100000).toString();
      _sendEmail(email, _generatedCode!); 
      _mostrarPopUpGmail(email, password);
    }
  }

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
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Código enviado al email", style: TextStyle(color: Colors.white70)),
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

  Future<void> _procederLoginFirebase(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseMessaging.instance.getToken().then((token) {
          if (token != null) {
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({'fcmToken': token}, SetOptions(merge: true));
          }
        }).catchError((e) => debugPrint("Error FCM ignorado: $e"));
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RootPage()), (route) => false);
      });
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _mostrarMensaje("Error: ${e.message}");
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _mostrarMensaje("Error inesperado");
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
    } catch (e) { debugPrint("EmailJS Error: $e"); }
  }

  void _mostrarMensaje(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF64B5F6)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/LogoAlphaAppPagInicio.png', width: 180, errorBuilder: (c, e, s) => const Icon(Icons.lock, size: 50, color: Colors.white)),
                const SizedBox(height: 40),
                
                // LONGITUD AJUSTADA A 350
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      _glassField(AnimatedTextField(label: 'Email', controller: emailController, textInputAction: TextInputAction.next)),
                      const SizedBox(height: 20),
                      _glassField(AnimatedTextField(label: 'Contraseña', isPasswordField: true, controller: passwordController, onSubmitted: login)),
                      const SizedBox(height: 15),
                      _glassField(
                        CheckboxListTile(
                          title: const Text("Acceso Admin", style: TextStyle(color: Colors.white, fontSize: 13)),
                          value: _isAdminMode,
                          activeColor: Colors.blueAccent,
                          onChanged: _gestionarCambioAdmin,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _isLoading ? null : login,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 55, width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]),
                    ),
                    child: Center(
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Entrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
    return ClipRRect(
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
    );
  }
}

class AnimatedTextField extends StatelessWidget {
  final String label;
  final bool isPasswordField;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  const AnimatedTextField({required this.label, this.isPasswordField = false, required this.controller, this.textInputAction, this.onSubmitted, super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPasswordField,
      style: const TextStyle(color: Colors.white),
      textInputAction: textInputAction,
      onSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white60),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}