// signup.dart

import 'package:flutter/material.dart';
import 'package:flutter_parse/login.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpEnabled = false;

  @override
  void initState() {
    super.initState();
    _userIdController.addListener(_checkSignUpEnable);
    _emailController.addListener(_checkSignUpEnable);
    _passwordController.addListener(_checkSignUpEnable);
  }

  void _checkSignUpEnable() {
    setState(() {
      _isSignUpEnabled =
          _userIdController.text.trim().isNotEmpty &&
              _emailController.text.trim().isNotEmpty &&
              _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signUpUser(
      String userId, String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    final user = ParseUser(userId, password, email)
      ..set('userId', userId);
    final response = await user.signUp();

    setState(() {
      _isLoading = false;
    });

    if (response.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(response.error!.message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.teal],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _userIdController,
                        decoration: InputDecoration(
                          labelText: 'Username *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email*',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password*',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _isSignUpEnabled
                            ? () {
                          _signUpUser(
                            _userIdController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
