import 'package:flutter/material.dart';
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
      body: Center(
        child: Column(
          children: [
            MyTextfield(
              hintText: "New username",
              obscureText: false,
              controller: _usernameController,
              inputFocus: _usernameFocus
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

            MyButton(
              text: "Change username",
              onTap: () {
                if(_usernameController.text.isNotEmpty || !usernameSame){
                  sendVerificationCode(widget.username);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => VeryifyDialog(userEmail: widget.email, username: widget.username),
                  );
                  // AuthService.updatePassword(_currentPasswordController.text, _newPasswordController.text, username);
                }
              },
              color: 
              _usernameController.text.isEmpty ||
              usernameSame
              ? const Color.fromARGB(255, 222, 222, 222)
              : Colors.white,
              showShadow: 
              _usernameController.text.isEmpty || 
              usernameSame
              ? false
              : true,
            )

          ],
        ),
      ),
    );
  }
}