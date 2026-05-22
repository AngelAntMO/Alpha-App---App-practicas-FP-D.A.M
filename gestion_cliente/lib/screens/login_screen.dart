import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';
import 'package:base32/base32.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';

// Importa tus pantallas locales
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
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isAdminMode = false;
  String? _generatedCode;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    masterPassController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE LOGIN PRINCIPAL ---

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
      _mostrarSelectorMetodo(email, password);
    }
  }

  // --- SELECTOR DE MÉTODO (DISEÑO MANTENIDO) ---

  void _mostrarSelectorMetodo(String email, String password) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Verificación 2FA",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _metodoItem(
                icon: Icons.email_outlined,
                title: "Código por Email",
                onTap: () {
                  Navigator.pop(context);
                  _iniciarFlujoEmail(email, password);
                },
              ),
              const SizedBox(height: 15),
              _metodoItem(
                icon: Icons.phonelink_lock_outlined,
                title: "Google Authenticator",
                onTap: () {
                  Navigator.pop(context);
                  _iniciarFlujoAuthenticator(email, password);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metodoItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _glassField(
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FLUJO 1: EMAIL (TU CÓDIGO ORIGINAL) ---

  void _iniciarFlujoEmail(String email, String password) {
    _generatedCode = (Random().nextInt(900000) + 100000).toString();
    _sendEmail(email, _generatedCode!);
    _mostrarPopUpGmail(email, password);
  }

  // --- FLUJO 2: AUTHENTICATOR (QR Y TOTP) ---

  Future<void> _iniciarFlujoAuthenticator(String email, String password) async {
    try {
      // 1. Buscamos el usuario que tenga ese email en la colección 'users'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      String? secret;
      String docId;

      if (querySnapshot.docs.isNotEmpty) {
        // Si el usuario existe, sacamos su ID y su secreto (si lo tiene)
        var userDoc = querySnapshot.docs.first;
        docId = userDoc.id;
        secret = userDoc.data().containsKey('mfa_secret')
            ? userDoc.data()['mfa_secret']
            : null;
      } else {
        // Si el usuario no existe en la colección 'users', usamos el email como ID temporal
        // o puedes mostrar un error de "Usuario no encontrado"
        docId = email;
      }

      if (secret == null) {
        // Generar nueva clave secreta si no existe
        Uint8List randomBytes = Uint8List.fromList(
          List.generate(10, (i) => Random().nextInt(256)),
        );
        String newSecret = base32.encode(randomBytes);
        _mostrarConfiguracionQR(docId, email, password, newSecret);
      } else {
        _mostrarPopUpValidacionTOTP(email, password, secret);
      }
    } catch (e) {
      debugPrint(
        "Error Firestore: $e",
      ); // Esto te dirá el error real en la consola
      _mostrarMensaje("Error de permisos o conexión");
    }
  }

  void _mostrarConfiguracionQR(
    String docId,
    String email,
    String password,
    String secret,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Configurar App",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            // <-- IMPORTANTE: Definimos un ancho fijo para el diálogo
            width: 300,
            child: SingleChildScrollView(
              // <-- Evita errores de overflow
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Escanea este QR con Google Authenticator",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Contenedor del QR con tamaño definido
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: QrImageView(
                        data:
                            "otpauth://totp/AlphaApp:$email?secret=$secret&issuer=AlphaApp",
                        version: QrVersions.auto,
                        // Eliminamos restricciones intrínsecas
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Clave manual: $secret",
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final navigator = Navigator.of(context);

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .set({'mfa_secret': secret}, SetOptions(merge: true));

                  if (!mounted) return;

                  navigator.pop();

                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    _mostrarPopUpValidacionTOTP(email, password, secret);
                  });
                } catch (e) {
                  if (!mounted) return;
                  _mostrarMensaje("Error al guardar: $e");
                }
              },
              child: const Text("CONFIRMAR VINCULACIÓN"),
            ),
          ],
        ),
      ),
    );
  }

  void _verificarCodigoYEntrar(
    String email,
    String password,
    String secret,
    BuildContext dialogContext,
  ) {
    String inputCode = _otpController.text.trim();
    int time = DateTime.now().toUtc().millisecondsSinceEpoch;

    // Generamos el esperado con la configuración de Google
    String expected = OTP.generateTOTPCodeString(
      secret,
      time,
      interval: 30,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    if (inputCode == expected) {
      // 1. Cerramos el diálogo usando el contexto del propio diálogo
      Navigator.pop(dialogContext);

      // 2. Activamos el loader en la pantalla principal
      setState(() => _isLoading = true);

      // 3. Ejecutamos el login final
      _procederLoginFirebase(email, password);
    } else {
      // Si falla, mostramos error pero NO cerramos el diálogo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Código incorrecto"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarPopUpValidacionTOTP(
    String email,
    String password,
    String secret,
  ) {
    // Limpiamos el controlador por si acaso había algo de un intento anterior
    _otpController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ), // Efecto de cristal esmerilado
        child: AlertDialog(
          backgroundColor: const Color(
            0xFF1E293B,
          ).withValues(alpha: 0.95), // Fondo oscuro AlphaApp
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Verificación de Seguridad",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Introduzca el código de 6 dígitos generado por su aplicación de autenticación.",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                // Campo de texto estilizado
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "", // Oculta el contador de caracteres
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    hintText: "000000",
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _verificarCodigoYEntrar(
                email,
                password,
                secret,
                dialogContext,
              ),
              child: const Text(
                "VERIFICAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE APOYO ORIGINALES ---

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
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "🔐 Clave Maestra",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            child: _glassField(
              TextField(
                controller: masterPassController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "••••",
                  hintStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.white54),
              ),
            ),
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

  void _mostrarPopUpGmail(String email, String password) {
    otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Verificación Email",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Código enviado al email",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _glassField(
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 5,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "000000",
                    hintStyle: TextStyle(
                      color: Colors.white24,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cerrar",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
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
      ),
    );
  }

  Future<void> _procederLoginFirebase(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _mostrarMensaje("Error al iniciar sesión: $e");
    }
  }

  Future<void> _sendEmail(String email, String code) async {
    try {
      await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_sziirym',
          'template_id': 'template_ecuyrkp',
          'user_id': 'NRbnnLuNptqqUU1eb',
          'template_params': {
            'user_email': email,
            'passcode': code,
            'time': '15 minutos',
          },
        }),
      );
    } catch (e) {
      debugPrint("EmailJS Error: $e");
    }
  }

  void _mostrarMensaje(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
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
          title: const Text(
            'Iniciar sesión',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/LogoAlphaAppPagInicio.png',
                  width: 180,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.lock, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 350,
                  child: Column(
                    children: [
                      _glassField(
                        AnimatedTextField(
                          label: 'Email',
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _glassField(
                        AnimatedTextField(
                          label: 'Contraseña',
                          isPasswordField: true,
                          controller: passwordController,
                          onSubmitted: login,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _glassField(
                        CheckboxListTile(
                          title: const Text(
                            "Acceso Admin",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
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
                    height: 55,
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.white70),
                  ),
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
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class HomePage {
  const HomePage();
}

class AnimatedTextField extends StatelessWidget {
  final String label;
  final bool isPasswordField;
  final TextEditingController controller;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  const AnimatedTextField({
    required this.label,
    this.isPasswordField = false,
    required this.controller,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

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
