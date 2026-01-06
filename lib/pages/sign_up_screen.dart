import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/blocked_email.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/pages/login_screen.dart';
import 'package:photo_album/services/fetch_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _confirmEmailFocus = FocusNode();
  final FocusNode _pwdFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  
  final AuthService _authService = AuthService();

  bool emailTouched = false;
  bool confirmEmailTouched = false;
  bool usernameTouched = false;
  bool passwordTouched = false;
  bool blockedEmail = false;

  bool userNameTaken = false;
  bool emailTaken = false;

  // ! TODO FIX THIS: CHECK change_pass_screen.dart
  // ! Add constraints to password
  @override
  void initState() {
    super.initState();
    void listener() => setState(() {});
    _usernameController.addListener(listener);
    _emailController.addListener(listener);
    _confirmEmailController.addListener(listener);
    _pwdController.addListener(listener);

    _usernameFocus.addListener(() async {
      if (!_usernameFocus.hasFocus) {
        setState(() => usernameTouched = true);

        // Check if the username is available
        final usernameAvailable = await FetchService().checkUsernameAvailable(_usernameController.text);
        if(usernameAvailable){
          setState(() => userNameTaken = false);
        } else{
          setState(() => userNameTaken = true);
        }
      }
    });

    _emailFocus.addListener(() async {
      if (!_emailFocus.hasFocus) {
        if(isBlockedEmail(_emailController.text.trim()) || !_emailController.text.contains("@")){
          blockedEmail = true;
          emailTaken = false;
        }
        else{
          blockedEmail = false;

          // Check if the email is available
          final mailAvailable = await FetchService().checkEmailvailable(_emailController.text);
          if(mailAvailable){
            setState(() => emailTaken = false);
          } else{
            setState(() => emailTaken = true);
          }
        }
        setState(() => emailTouched = true,);
      }
    });
    
    _confirmEmailFocus.addListener(() {if (!_confirmEmailFocus.hasFocus) {setState(() => confirmEmailTouched = true);}});
    
    _pwdFocus.addListener(() {if (!_pwdFocus.hasFocus) {setState(() => passwordTouched = true);}});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocus.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    _confirmEmailController.dispose();
    _confirmEmailFocus.dispose();
    _pwdController.dispose();
    _pwdFocus.dispose();
    super.dispose();
  }

  bool checkFormIsValid(){
    if (_usernameController.text.isEmpty) {return false;}
    else if(_emailController.text.isEmpty) {return false;}
    else if(_confirmEmailController.text.isEmpty) {return false;}
    else if(_pwdController.text.isEmpty) {return false;}
    else if(blockedEmail) {return false;}
    else if(_emailController.text != _confirmEmailController.text) {return false;}
    else if(emailTaken || userNameTaken) {return false;}

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final showErrorUsername = usernameTouched && _usernameController.text.isEmpty;
    final showErrorEmail = emailTouched && _emailController.text.isEmpty;
    final showErrorconfirmEmail = confirmEmailTouched && _confirmEmailController.text.isEmpty;
    final showErrorPwd = passwordTouched && _pwdController.text.isEmpty;

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

                      // Text fields for signup
                      MyTextfield(
                        hintText: "Username",
                        obscureText: false,
                        controller: _usernameController,
                        inputFormatter: [
                          LengthLimitingTextInputFormatter(12),
                        ],
                        inputFocus: _usernameFocus,
                        touched: usernameTouched,
                      ),
                      if(showErrorUsername) ... [
                        SizedBox(height: 3,),
                        const Text(
                          "Please enter a username",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      if(!showErrorUsername && userNameTaken) ... [
                        SizedBox(height: 3,),
                        const Text(
                          "Username already taken!",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      
                  
                      SizedBox(height: 10,),

                      MyTextfield(
                        hintText: "Email address",
                        obscureText: false,
                        controller: _emailController,
                        inputFocus: _emailFocus,
                        touched: emailTouched,
                      ),
                      
                      if(showErrorEmail) ...[
                        SizedBox(height: 3,),
                        const Text(
                          "Please enter an email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      if(blockedEmail && !emailTaken) ...[
                        SizedBox(height: 3,),
                        Text(
                          "Please use a valid email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      if(!showErrorEmail && emailTaken) ... [
                        SizedBox(height: 3,),
                        const Text(
                          "Email already in use!",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],

                      SizedBox(height: 10,),

                      MyTextfield(
                        hintText: "Confirm email address",
                        obscureText: false,
                        controller: _confirmEmailController,
                        inputFocus: _confirmEmailFocus,
                        touched: confirmEmailTouched,
                      ),
                      if(showErrorconfirmEmail) ...[
                        SizedBox(height: 3,),
                        Text(
                          "Please re-enter your valid email",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                      if(_emailController.text != _confirmEmailController.text && confirmEmailTouched && !showErrorconfirmEmail) ... [
                        SizedBox(height: 3,),
                        Text(
                          "Your emails do not match",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                  
                      SizedBox(height: 10,),
                  
                      MyTextfield(
                        // TODO ADD password enforcements
                        hintText: "Password",
                        obscureText: true,
                        controller: _pwdController,
                        inputFocus: _pwdFocus,
                        touched: passwordTouched,
                      ),
                      SizedBox(height: 3,),
                      if(showErrorPwd) ... [
                        SizedBox(height: 3,),
                        const Text(
                          "Please enter a password",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                  
                      SizedBox(height: 30,),
                  
                      MyButton(
                        text: "Sign up",
                        onTap: () => {
                          if(
                            // _emailController.text.isNotEmpty && 
                            // _pwdController.text.isNotEmpty && 
                            // _usernameController.text.isNotEmpty &&
                            // _confirmEmailController.text.isNotEmpty &&
                            checkFormIsValid()
                            ){
                            _authService.register(
                              _emailController.text,
                              _pwdController.text,
                              _usernameController.text,
                            ),
                            // Push back to login. User must first verify their email before they can log in

                            showDialog(
                              context: context,
                              builder: (BuildContext context) => signUpSuccess(),
                            ),
                          },
                        },
                        color:
                        //  _emailController.text.isEmpty || _pwdController.text.isEmpty || _usernameController.text.isEmpty
                        !checkFormIsValid()
                        ? const Color.fromARGB(255, 222, 222, 222)
                        : Colors.white, // Valid
                        showShadow:
                        // _emailController.text.isEmpty || _pwdController.text.isEmpty || _usernameController.text.isEmpty
                        !checkFormIsValid()
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

  Widget signUpSuccess(){
    return CupertinoAlertDialog(
      title: Text("Successfully created account!"),
      content: Text("An email has been sent to verify your account.\nPlease check your spam email as well."),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "Ok",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () => {
            // Remove popup
            Navigator.pop(context),
            
            // Move back to login page
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
            ),
          },
        )
      ],
    );
  }
}