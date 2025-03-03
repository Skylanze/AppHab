import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:apphab/screens/mainScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true; // Para alternar entre Iniciar Sesión y Registrarse
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  /// Verifica si hay un usuario ya logueado
  void _checkIfAlreadyLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si ya hay un usuario, navegar a MainScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      });
    }
  }

  /// Inicia sesión o crea una cuenta con Email/Password en Firebase
  Future<void> _signInWithEmailPassword() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;
      if (_isLogin) {
        // Iniciar sesión
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Registrarse
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // Si el UserCredential no es nulo, significa que se autenticó correctamente
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showErrorDialog(
            'No se pudo obtener el usuario después de la autenticación.');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Error desconocido');
    } catch (e) {
      _showErrorDialog('Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Inicia sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // El usuario canceló el flujo de Google Sign-In
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con las credenciales de Google
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        _showErrorDialog(
            'No se pudo obtener el usuario después de la autenticación con Google.');
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'Error desconocido');
    } catch (e) {
      _showErrorDialog('Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Muestra un AlertDialog con el mensaje de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error de autenticación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonText = _isLogin ? 'Iniciar Sesión' : 'Registrarse';
    final toggleText = _isLogin
        ? '¿No tienes cuenta? Regístrate'
        : '¿Ya tienes cuenta? Inicia Sesión';

    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Botón de iniciar sesión / registrarse
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signInWithEmailPassword();
                          }
                        },
                        child: Text(buttonText),
                      ),

                    // Toggle entre login y registro
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(toggleText),
                    ),
                    const SizedBox(height: 16),

                    // Botón de Google
                    if (!_isLoading)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Iniciar con Google'),
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
