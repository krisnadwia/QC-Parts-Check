import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qc_parts_check/support_pages/login_screen.dart';
import 'package:qc_parts_check/utils/auth.dart';

class RegisterScreenManager extends StatefulWidget {
  const RegisterScreenManager({super.key});

  @override
  State<RegisterScreenManager> createState() => _RegisterScreenManagerState();
}

class _RegisterScreenManagerState extends State<RegisterScreenManager>
    with TickerProviderStateMixin {
  String _pwd = "";
  String _mail = "";
  String _displayName = "";
  String _phoneNumber = "";
  String _role = "Manager";
  bool _isObscure = true;
  bool _isLoading = false;

  final TextEditingController _roleController =
      TextEditingController(text: "Manager");

  @override
  void initState() {
    super.initState();

    // Retrieve logged in user data
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {});
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
          "Buat Akun untuk Manager",
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
                  "Hai,",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: const Text(
                  "Silakan Isi Data Berikut Untuk Membuat Akun!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Center(
                    child: ScaleTransition(
                      scale: _animation,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/images/img-registerscreen.png",
                          width: 300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  _displayName = value;
                                });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.greenAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                ),
                                hintText: "Masukkan Nama Anda",
                                label: Text(
                                  "Nama",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  _mail = value;
                                });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.greenAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
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
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              // Only numbers can be entered
                              keyboardType: TextInputType.number,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  _phoneNumber = value;
                                });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.greenAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone,
                                ),
                                hintText: "Masukkan Nomor Telepon",
                                label: Text(
                                  "Nomor Telepon",
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              obscureText: _isObscure,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  _pwd = value;
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(20),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.greenAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
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
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              readOnly: true,
                              controller: _roleController,
                              textInputAction: TextInputAction.next,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                setState(() {
                                  _role = value;
                                });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                ),
                                label: Text(
                                  "Posisi",
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    HapticFeedback.vibrate();
                    var res = await Auth.mailRegister(
                      _mail,
                      _pwd,
                      _displayName,
                      _phoneNumber,
                      _role,
                    );

                    setState(() {
                      _isLoading = true;
                    });
                    await Future.delayed(
                      const Duration(
                        seconds: 1,
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            res == null ? Colors.green : Colors.red,
                        content: Text(
                          res ?? "Selamat, Akun Berhasil Dibuat!",
                        ),
                      ),
                    );
                  },
                  child: (_isLoading)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Text(
                          "Buat Akun",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white30,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Auth.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Kembali ke Halaman Login",
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
