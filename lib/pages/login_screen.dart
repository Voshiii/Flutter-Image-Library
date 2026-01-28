import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/blocked_email.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/password_checker.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/components/push_homescreen.dart';
import 'package:photo_album/components/error_dialog.dart';
import 'package:photo_album/services/fetch_service.dart';

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

  bool showPasswordConstraintError = false;

  bool isLogin = true;

  // TODO merge sign up with login screen
  // Sign up items
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _confirmEmailFocus = FocusNode();

  bool emailTouched = false;
  bool confirmEmailTouched = false;
  // bool usernameTouched = false;
  // bool passwordTouched = false;
  bool blockedEmail = false;

  bool userNameTaken = false;
  bool emailTaken = false;

  bool showConfirmEmail = false;

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _usernameFocus.addListener(() async {
      if (!_usernameFocus.hasFocus) {
        setState(() => usernameTouched = true);

        // Only check if username is taken when registering
        if(!isLogin){
          // Check if the username is available
          if (_usernameController.text.isEmpty) return;
          final usernameAvailable = await FetchService()
              .checkUsernameAvailable(_usernameController.text);
          if (usernameAvailable) {
            setState(() => userNameTaken = false);
          } else {
            setState(() => userNameTaken = true);
          }
        }
      }
    });

    _usernameController.addListener(() {setState(() {});});

    // _pwdController.addListener(listener);

    _pwdController.addListener(() {
      if(!isLogin){
          final res = checkPasswordConstraints(_pwdController.text);
          if(!res){
            setState(() {
              showPasswordConstraintError = true;
            });
          }
          else{
            showPasswordConstraintError = false;
          }
        }
    });
    
    _pwdFocus.addListener(() {
      if (!_pwdFocus.hasFocus) {
        setState(() => passwordTouched = true);
      }
    });

    _pwdController.addListener((){setState(() {});});
    
    _emailFocus.addListener(() async {
      if (!_emailFocus.hasFocus) {
        if (isBlockedEmail(_emailController.text.trim()) ||
            !_emailController.text.contains("@")) {
          blockedEmail = true;
          emailTaken = false;
        } else {
          blockedEmail = false;

          // Check if the email is available
          if (_emailController.text.isEmpty) return;
          final mailAvailable =
              await FetchService().checkEmailvailable(_emailController.text);
          if (mailAvailable) {
            setState(() => emailTaken = false);
          } else {
            setState(() => emailTaken = true);
          }
        }
        setState(
          () => emailTouched = true,
        );
      }
    });

    _emailController.addListener((){setState(() {});});

    _confirmEmailController.addListener(() {setState(() {});});
    
    _confirmEmailFocus.addListener(() {
      if (!_confirmEmailFocus.hasFocus) {
        setState(() => confirmEmailTouched = true);
      }      
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocus.dispose();
    _pwdController.dispose();
    _pwdFocus.dispose();
    _emailController.dispose();
    _confirmEmailController.dispose();
    _emailFocus.dispose();
    _confirmEmailFocus.dispose();
    
    super.dispose();
  }

  bool checkFormIsValid() {
    if (_usernameController.text.isEmpty) {
      return false;
    } else if (_emailController.text.isEmpty) {
      return false;
    } else if (_confirmEmailController.text.isEmpty) {
      return false;
    } else if (_pwdController.text.isEmpty) {
      return false;
    } else if (blockedEmail) {
      return false;
    } else if (_emailController.text != _confirmEmailController.text) {
      return false;
    } else if (emailTaken || userNameTaken) {
      return false;
    } else if (showPasswordConstraintError){
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool showErrorUsername = usernameTouched && _usernameController.text.isEmpty;
    final bool showErrorPwd = passwordTouched && _pwdController.text.isEmpty;

    final bool showErrorEmail = emailTouched && _emailController.text.isEmpty;
    final bool showErrorconfirmEmail =
        confirmEmailTouched && _confirmEmailController.text.isEmpty;

    return Stack(
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

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      isLogin 
                      ? "Please enter your username and password:" 
                      : "Welcome to Voshi's cloud!",
                      key: ValueKey(isLogin),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
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
                          autofillHints: isLogin ? [AutofillHints.username] : [],
                          inputFocus: _usernameFocus,
                          touched: usernameTouched,
                          inputFormatter: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                        ),
                        if(showErrorUsername) ... [
                          SizedBox(height: 3,),
                          const Text(
                            "Please enter a username!",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        if(!isLogin)...[
                          if(!showErrorUsername && userNameTaken) ... [
                            SizedBox(height: 3,),
                            const Text(
                              "Username already taken!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ]
                        ],
                        
                        SizedBox(height: 10,),
                        
                        MyTextfield(
                          hintText: "Password",
                          obscureText: true,
                          controller: _pwdController,
                          autofillHints: isLogin ? [AutofillHints.password] : [],
                          inputFocus: _pwdFocus,
                          touched: passwordTouched,
                          inputFormatter: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                        ),
                        // SizedBox(height: 3,),
                        if(showErrorPwd) ... [
                          SizedBox(height: 3,),
                          const Text(
                            "Please enter a password!",
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                        else if(showPasswordConstraintError && passwordTouched)...[
                          SizedBox(height: 3,),
                          const Text(
                            "Your password must be at least 8 characters long\n and include special characters '!#\$()'",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                        if(isLogin)...[SizedBox(height: 3,),]
                        else...[SizedBox(height: 10,),]
                        
                      ],
                    ),
                  ),
                  // Animated email field only for signup
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isLogin
                        ? SizedBox.shrink()
                        : Column(
                          children: [
                            MyTextfield(
                              obscureText: false,
                                hintText: "Email address",
                                controller: _emailController,
                                inputFocus: _emailFocus,
                                touched: emailTouched,
                                inputFormatter: [
                                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                ],
                              ),

                            if(showErrorEmail) ...[
                              SizedBox(height: 3,),
                              const Text(
                                "Please enter an email!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                            else if(blockedEmail && !emailTaken) ...[
                              SizedBox(height: 3,),
                              Text(
                                "Please use a valid email",
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                            else if(!showErrorEmail && emailTaken) ... [
                              SizedBox(height: 3,),
                              const Text(
                                "Email already in use!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                            SizedBox(height: 10,),
                          ],
                        ),
                  ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    child: !showConfirmEmail
                        ? SizedBox.shrink()
                        : Column(
                          children: [
                            MyTextfield(
                              obscureText: false,
                                hintText: "Confirm email address",
                                controller: _confirmEmailController,
                                inputFocus: _confirmEmailFocus,
                                touched: confirmEmailTouched,
                                inputFormatter: [
                                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                ],
                              ),
                            
                            if(showErrorconfirmEmail) ...[
                              SizedBox(height: 3,),
                              Text(
                                "Please re-enter your valid email!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                            if(_emailController.text != _confirmEmailController.text && confirmEmailTouched && !showErrorconfirmEmail) ... [
                              SizedBox(height: 3,),
                              Text(
                                "Your emails do not match!",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],

                          ],
                        ),
                  ),

                  SizedBox(height: 13,),
            
                  MyButton(
                    // text: "Login", 
                    text: isLogin ? "Login" : "Sign Up",
                    onTap: () async {

                      if(isLogin){
                        if(_usernameController.text.isEmpty || _pwdController.text.isEmpty){return;} // If any of the buttons are not filled in.
                      
                        setState(() => _isLoading = true);
          
                        try {
                          // success
                          final res = await _authService.login(_usernameController.text, _pwdController.text);
                          if(res.$1 == 200 && mounted){
                            if (mounted) setState(() => _isLoading = false);
                            if(!context.mounted) return;
                            pushToHomeScreen(context, "");
                          }
                          else{
                            if(!context.mounted) return;
                            showDialog(
                              context: context,
                              // builder: (BuildContext context) => failedLoginDialog(context),
                              builder: (BuildContext context) => errorDialog(
                                context,
                                res.$2,
                                res.$3
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
                      }
                      else{
                        if(checkFormIsValid()) {
                          final res = await _authService.register(
                            _emailController.text,
                            _pwdController.text,
                            _usernameController.text,
                          );
                          // Push back to login. User must first verify their email before they can log in
                                
                          if(res.$1 == 200){
                            if(!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => signUpSuccess(),
                            );
                            setState(() {
                              isLogin = true;
                              showConfirmEmail = false;
                              usernameTouched = false;
                              passwordTouched = false;
                              confirmEmailTouched = false;
                              emailTouched = false;
                              // Clear all values
                              _usernameController.clear();
                              _pwdController.clear();
                              _emailController.clear();
                              _confirmEmailController.clear();
                            });
                          }
                          else{
                            if(!context.mounted) return;
                            showDialog(
                              context: context,
                              // builder: (BuildContext context) => failedLoginDialog(context),
                              builder: (BuildContext context) => errorDialog(
                                context,
                                res.$2,
                                res.$3
                              ),
                            );
                          } 
                        }
                      }

                      
                    },
                    // Disable button (change color) when input text is empty
                    color: isLogin
                    ? _usernameController.text.isEmpty || _pwdController.text.isEmpty
                      ? const Color.fromARGB(255, 222, 222, 222)
                      : Colors.white
                    : checkFormIsValid()
                      ? const Color.fromARGB(255, 251, 240, 250)
                      : const Color.fromARGB(255, 243, 219, 242),

                    showShadow: isLogin 
                    ? _usernameController.text.isEmpty || _pwdController.text.isEmpty
                      ? false
                      : true
                    : checkFormIsValid()
                      ? true
                      : false
                  ),
        
                  SizedBox(height: 10,),
        
                  // Button to change from login -> signup -> login
                  MyButton(
                    text: !isLogin ? "Login" : "Sign Up",
                    reverseAnimation: true,
                    onTap: () => {
                      // Current state is login going to sign up
                      if(isLogin){
                        setState(() {
                          checkFormIsValid();
                          isLogin = !isLogin;
                          showPasswordConstraintError = !checkPasswordConstraints(_pwdController.text);
                        }),
                  
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (!mounted) return;
                          setState(() {
                            showConfirmEmail = !showConfirmEmail;
                          });
                        })
                      }
                      // Current state is sign up going to login
                      else{
                        setState(() {
                          showConfirmEmail = !showConfirmEmail;
                          showPasswordConstraintError = false;
                          emailTouched = false;
                          confirmEmailTouched = false;
                          blockedEmail = false;
                        }),
                  
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (!mounted) return;
                          setState(() {
                            isLogin = !isLogin;
                          });
                        })
                      }
                      
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
    );
  }

  Widget signUpSuccess() {
    return CupertinoAlertDialog(
      title: Text("Successfully created account!"),
      content: Text(
          "An email has been sent to verify your account.\nPlease check your spam email as well."),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "Ok",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: () => {
            // Remove popup
            Navigator.pop(context),
          },
        )
      ],
    );
  }
}

