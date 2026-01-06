import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/verification.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/components/settings_page_comp/pop_up_verify.dart';

class ChangeUsernameScreen extends StatefulWidget {
  final String username;
  final String email;
  const ChangeUsernameScreen({
    super.key,
    required this.username,
    required this.email
  });

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();

  bool usernameTouched = false;

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocus.hasFocus) {
      if (!mounted) return;
      setState(() => usernameTouched = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onTextChanged);
    _usernameFocus.addListener(_onUsernameFocusChange);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onTextChanged);
    _usernameFocus.removeListener(_onUsernameFocusChange);
    _usernameController.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool usernameSame = _usernameController.text == widget.username;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Username",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  MyTextfield(
                    hintText: "New username",
                    obscureText: false,
                    controller: _usernameController,
                    inputFocus: _usernameFocus,
                    touched: usernameTouched,
                  ),
                  if(usernameTouched && _usernameController.text.isEmpty) ... [
                    SizedBox(height: 3,),
                    Text(
                      "Field cannot be empty!",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ]
                  else if(usernameSame) ... [
                    SizedBox(height: 3,),
                    Text(
                      "Username can't be the same!",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
            
                  SizedBox(height: 10,),
            
                  // MyButton(
                  //   text: "Change username",
                  //   onTap: () async {
                  //     if(_usernameController.text.isNotEmpty && !usernameSame){
                  //       sendVerificationCode(widget.username);
                  //       final result = await showDialog(
                  //         context: context,
                  //         builder: (BuildContext context) => VeryifyDialog(userEmail: widget.email, username: widget.username),
                  //       );
                  //       if(result){
                  //         final res = await AuthService.updateUsername(widget.username, _usernameController.text);
                  //         if(res) {
                  //           AuthService.saveUsername(_usernameController.text);
                  //         }
                  //       }
                  //     }
                  //   },
                  //   color: 
                  //   _usernameController.text.isEmpty ||
                  //   usernameSame
                  //   ? const Color.fromARGB(255, 222, 222, 222)
                  //   : Colors.white,
                  //   showShadow: 
                  //   _usernameController.text.isEmpty || 
                  //   usernameSame
                  //   ? false
                  //   : true,
                  // )
            
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 70,
                  // ! TODO change the currentUsernameTest to a solid variable which is used everywhere
                  child: MyButton(
                        text: "Change username",
                        onTap: () async {
                          if(_usernameController.text.isNotEmpty && !usernameSame){
                            sendVerificationCode(AuthService.currentUsernameTest.value!);
                            final result = await showDialog(
                              context: context,
                              builder: (BuildContext context) => VeryifyDialog(userEmail: widget.email, username: AuthService.currentUsernameTest.value!),
                            );
                            if(result){
                              final res = await AuthService.updateUsername(AuthService.currentUsernameTest.value!, _usernameController.text);
                              if(res) {
                                AuthService.saveUsername(_usernameController.text);
                                _usernameController.clear();
                                setState(() {
                                  usernameTouched = false;
                                });
                              }
                            }
                          }
                        },
                        color: 
                        _usernameController.text.isEmpty ||
                        usernameSame
                        ? const Color.fromARGB(88, 222, 222, 222)
                        : Colors.white,
                        showShadow: 
                        _usernameController.text.isEmpty || 
                        usernameSame
                        ? false
                        : true,
                      ),
                ),
              ),
            ),
            // SizedBox(height: 40,)
          ]
        ),
      ),
    );
  }
}