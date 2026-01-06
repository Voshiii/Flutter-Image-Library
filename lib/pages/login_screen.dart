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

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _pwdFocus = FocusNode();

  bool usernameTouched = false;
  bool passwordTouched = false;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // ! TODO FIX THIS: CHECK change_pass_screen.dart
  @override
  void initState() {
    super.initState();
    void listener() => setState(() {});
    _usernameController.addListener(listener);
    _pwdController.addListener(listener);
    _usernameFocus.addListener(() {if (!_usernameFocus.hasFocus) {setState(() => usernameTouched = true);}});
    _pwdFocus.addListener(() {if (!_pwdFocus.hasFocus) {setState(() => passwordTouched = true);}});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocus.dispose();
    _pwdController.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showErrorUsername = usernameTouched && _usernameController.text.isEmpty;
    final showErrorPwd = passwordTouched && _pwdController.text.isEmpty;

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
                            inputFocus: _usernameFocus,
                            touched: usernameTouched,
                          ),
                          if(showErrorUsername) ... [
                            SizedBox(height: 3,),
                            const Text(
                              "Please enter a username!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                          
                          SizedBox(height: 10,),
                          
                          MyTextfield(
                            hintText: "Password",
                            obscureText: true,
                            controller: _pwdController,
                            autofillHints: [AutofillHints.password],
                            inputFocus: _pwdFocus,
                            touched: passwordTouched,
                          ),
                          // SizedBox(height: 3,),
                          if(showErrorPwd) ... [
                            SizedBox(height: 3,),
                            const Text(
                              "Please enter a password!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                          SizedBox(height: 3,),
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
                          // success
                          final res = await _authService.login(_usernameController.text, _pwdController.text, context);
                          if(res.$1 == 200 && mounted){
                            if(!context.mounted) return;
                            pushToHomeScreen(context, "");
                          }
                          // Not found
                          else if (res.$1 == 404 && mounted){
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
                          // Not verified
                          else if (res.$1 == 400 && mounted){
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              // builder: (BuildContext context) => failedLoginDialog(context),
                              builder: (BuildContext context) => errorDialog(
                                context,
                                "Error",
                                res.$2
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