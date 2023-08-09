import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qc_parts_check/manager/register_screen_manager.dart';
import 'package:qc_parts_check/operator/register_screen_operator.dart';
import 'package:qc_parts_check/operator/bottom_navbar_operator.dart';

import '../manager/bottom_navbar_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool visible = false;
  bool _isObscure = true;
  final _formkey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
      });
    });
  }

  // Animation function
  late final AnimationController _controller = AnimationController(
    duration: const Duration(
      seconds: 2,
    ),
    vsync: this,
  )..forward();

  // Animation settings
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login Operator/Manager",
        ),
        flexibleSpace: Material(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: <Color>[
                  Color(0x28e3caca),
                  Color(0x2ad8de32),
                  Color(0x49ead66e),
                ],
                // Gradient from https://learnui.design/tools/gradient-generator.html
                tileMode: TileMode.mirror,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
          ),
          tooltip: "Kembali",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),

      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color(0x28e3caca),
                Color(0x2ad8de32),
                Color(0x49ead66e),
                Color(0x35f3cd0a),
                Color(0xfff3f19e),
                Color(0x76ecba17),
                Color(0x8cf39060),
                Color(0xa3fae927),
              ],
              // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Hero(
                      tag: "wima-logo",
                      child: Image.asset(
                        "assets/images/wima-logo.png",
                        width: 150,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Hero(
                      tag: "gesits-logo",
                      child: Image.asset(
                        "assets/images/gesits-logo.png",
                        width: 150,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Halo,",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: const Text(
                  "Silakan Login Dahulu Untuk Melanjutkan!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Column(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/ls.gif",
                          height: 250,
                        ),
                      ),
                      Center(
                        child: ScaleTransition(
                          scale: _animation,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              "assets/images/img-loginscreen.png",
                              width: 250,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Email tidak boleh kosong!";
                                      }
                                      if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                          .hasMatch(value)) {
                                        return ("Masukkan email yang valid!");
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      emailController.text = value!;
                                    },
                                    textInputAction: TextInputAction.next,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(10),
                                      prefixIcon: Icon(
                                        Icons.mail,
                                      ),
                                      hintText: "Masukkan Email",
                                      label: Text(
                                        "Email",
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: TextFormField(
                                    controller: passwordController,
                                    validator: (value) {
                                      RegExp regex = RegExp(r'^.{6,}$');
                                      if (value!.isEmpty) {
                                        return "Password tidak boleh kosong!";
                                      }
                                      if (!regex.hasMatch(value)) {
                                        return ("Minimal 6 karakter!");
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      passwordController.text = value!;
                                    },
                                    textInputAction: TextInputAction.done,
                                    obscureText: _isObscure,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      hintText: "Masukkan Password",
                                      label: const Text(
                                        "Password",
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isObscure
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isObscure = !_isObscure;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(30),
                            backgroundColor: Colors.orange,
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              HapticFeedback.vibrate();
                              signIn(
                                emailController.text,
                                passwordController.text,
                              );
                              route();
                            }
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Text(
                          "Anda Operator dan Belum Punya Akun? Daftar Sekarang Juga!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreenOperator(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register Operator",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        width: 150,
                        child: Text(
                          "Anda Manager dan Belum Punya Akun? Daftar Sekarang Juga!",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(20),
                            shape: BeveledRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreenManager(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register Manager",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get("role") == "Operator") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BottomNavbarOperator(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BottomNavbarManager(),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('Document does not exist on the database');
        }
      }
    });
  }

  void signIn(String mail, String pwd) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: pwd,
      );
      route();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Email tidak terdaftar!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
        if (kDebugMode) {
          print('No user found for that email.');
        }
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Password salah!",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        );
        if (kDebugMode) {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}