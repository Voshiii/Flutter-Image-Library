import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/pages/login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    void listener() => setState(() {});
    _usernameController.addListener(listener);
    _emailController.addListener(listener);
    _pwdController.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true, // ! TODO: there is an overflow issue when the keyboard pops up
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocus all text fields
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.purple.shade200,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Text(
                        "Welcome to",
                        style: GoogleFonts.blinker(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                        ),
                      ),
                      Text(
                        "Voshi's Cloud",
                        style: GoogleFonts.blinker(
                          fontWeight: FontWeight.bold,
                          fontSize: 60
                        ),
                      ),
                      
                      SizedBox(height: 30,),
                                
                      Text(
                        "Create your account to get started!",
                        style: GoogleFonts.blinker(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                                
                      SizedBox(height: 10,),
                  
                      MyTextfield(
                        hintText: "Email address",
                        obscureText: false,
                        controller: _emailController,
                      ),
                  
                      SizedBox(height: 10,),
                  
                      MyTextfield(
                        hintText: "Username",
                        obscureText: false,
                        controller: _usernameController,
                        inputFormatter: [
                          LengthLimitingTextInputFormatter(12),
                        ],
                      ),
                  
                      SizedBox(height: 10,),
                  
                      MyTextfield(
                        hintText: "Password",
                        obscureText: true,
                        controller: _pwdController,
                      ),
                  
                      SizedBox(height: 30,),
                  
                      MyButton(
                        text: "Sign up",
                        onTap: () => {
                          // TODO add a widget if the user did not fill in a field
                          if(_emailController.text.isNotEmpty && _pwdController.text.isNotEmpty && _usernameController.text.isNotEmpty)
                            _authService.register(
                              _emailController.text,
                              _pwdController.text,
                              _usernameController.text,
                              context
                            )}, 
                        color: _emailController.text.isEmpty || _pwdController.text.isEmpty || _usernameController.text.isEmpty
                        ? const Color.fromARGB(255, 222, 222, 222)
                        : Colors.white,
                        showShadow: _emailController.text.isEmpty || _pwdController.text.isEmpty || _usernameController.text.isEmpty
                        ? false
                        : true
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text.rich(
                      TextSpan(
                        // ! TODO: Fix this overflow issue with the keyboard
                        text: "Already have an account? ",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Login Now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration: Duration(milliseconds: 160),
                                    pageBuilder: (_, __, ___) => LoginPage(),
                                    transitionsBuilder: (_, animation, __, child) {
                                      final offset = Tween<Offset>(
                                        begin: Offset(-1, 0),  // From left
                                        end: Offset.zero,
                                      ).animate(animation);
                  
                                      return SlideTransition(position: offset, child: child);
                                    },
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}