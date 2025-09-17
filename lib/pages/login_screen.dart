import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/components/push_homescreen.dart';
import 'package:photo_album/pages/sign_up_screen.dart';
import 'package:photo_album/components/error_dialog.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _pwdController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    void listener() => setState(() {});
    _usernameController.addListener(listener);
    _pwdController.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus(); // Unfocus all text fields
      },
      child: Stack(
        children: [
          Scaffold(
            body: Container(
              decoration: BoxDecoration(
                // Set background colors
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade300,
                    Colors.purple.shade200,
                  ],
                ),
              ),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      // TODO check the color with different themes
                      "Voshi's Cloud",
                      style: GoogleFonts.blinker(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                      )
                    ),
          
                    Text(
                      "Please enter your username and password:",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
              
                    SizedBox(height: 20,),
              
                    AutofillGroup( // "Autofill" so the user can save the password and use it
                      child: Column(
                        children: [
                          MyTextfield(
                            hintText: "Username",
                            obscureText: false,
                            controller: _usernameController,
                            autofillHints: [AutofillHints.username],
                          ),
                          
                          SizedBox(height: 10,),
                          
                          MyTextfield(
                            hintText: "Password",
                            obscureText: true,
                            controller: _pwdController,
                            autofillHints: [AutofillHints.password],
                          ),
                        ],
                      ),
                    ),
              
                    SizedBox(height: 10,),
              
                    MyButton(
                      text: "Login", 
                      onTap: () async {
                        if(_usernameController.text.isEmpty || _pwdController.text.isEmpty){return;} // If any of the buttons are not filled in.
                        
                        setState(() => _isLoading = true);
          
                        try {
                          final res = await _authService.login(_usernameController.text, _pwdController.text, context);
                          if(res == 200 && mounted){
                            if(!context.mounted) return;
                            pushToHomeScreen(context, "");
                          }
                          else if (res == 401 && mounted){
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              // builder: (BuildContext context) => failedLoginDialog(context),
                              builder: (BuildContext context) => errorDialog(
                                context,
                                "Invalid Credentials",
                                "Username or Password Incorrect!"
                              ),
                            );
                          }
                          else{
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => errorDialog(
                                context,
                                "Server Error",
                                "Please try again later!"
                              ),
                            );
                          }
                        } catch (e) {
                          // handle error if needed
                          print("AN ERROR OCCURED TRYING TO LOGIN: $e");
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            // builder: (BuildContext context) => failedLoginDialog(context),
                            builder: (BuildContext context) => errorDialog(
                              context, 
                              "Server Error",
                              "Please try again later!"
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      // Disable button (change color) when input text is empty
                      color: _usernameController.text.isEmpty || _pwdController.text.isEmpty
                      ? const Color.fromARGB(255, 222, 222, 222)
                      : Colors.white,
                      showShadow: _usernameController.text.isEmpty || _pwdController.text.isEmpty
                      ? false
                      : true,
                    ),
          
                    SizedBox(height: 10,),
          
                    MyButton(
                      text: "Sign Up",
                      onTap: () => {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        )
                      },
                      color: Colors.transparent,
                      showShadow: false,
                    )
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54, // semi-transparent dark background
                child: Center(
                  child: CupertinoActivityIndicator(radius: 20),
                ),
              ),
            ),

        ],
      ),
    );
  }
}