import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/password_checker.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _currentPasswFocus = FocusNode();
  final FocusNode _newPasswFocus = FocusNode();
  final FocusNode _confirmPasswFocus = FocusNode();
  
  bool currPassTouched = false;
  bool newPassTouched = false;
  bool confirmPassTouched = false;

  String username = "";

  // The new password should not be the old password
  bool checkPasswordDiff(String newPass, String currPass){
    return newPass == currPass;
  }

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onCurrentFocusChange() {
    if (!_currentPasswFocus.hasFocus) {
      if (!mounted) return;
      setState(() => currPassTouched = true);
    }
  }

  void _onNewFocusChange() {
    if (!_newPasswFocus.hasFocus) {
      if (!mounted) return;
      setState(() => newPassTouched = true);
    }
  }

  void _onConfirmFocusChange() {
    if (!_confirmPasswFocus.hasFocus) {
      if (!mounted) return;
      setState(() => confirmPassTouched = true);
    }
  }

  setName() async {
    username = await AuthService.getUsername() ?? "";
  }

  @override
  void initState() {
    super.initState();
    setName();

    _currentPasswordController.addListener(_onTextChanged);
    _newPasswordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);

    _currentPasswFocus.addListener(_onCurrentFocusChange);
    _newPasswFocus.addListener(_onNewFocusChange);
    _confirmPasswFocus.addListener(_onConfirmFocusChange);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onTextChanged);
    _newPasswordController.removeListener(_onTextChanged);
    _confirmPasswordController.removeListener(_onTextChanged);

    _currentPasswFocus.removeListener(_onCurrentFocusChange);
    _newPasswFocus.removeListener(_onNewFocusChange);
    _confirmPasswFocus.removeListener(_onConfirmFocusChange);

    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _currentPasswFocus.dispose();
    _newPasswFocus.dispose();
    _confirmPasswFocus.dispose();

    super.dispose();
  }


  Widget _changePassBody(){
    final showErrCurrPass = currPassTouched && _currentPasswordController.text.isEmpty && !_currentPasswFocus.hasFocus;
    final showErrNewPass = newPassTouched && _newPasswordController.text.isEmpty && !_newPasswFocus.hasFocus;
    final showErrConfirmPass = confirmPassTouched && _confirmPasswordController.text.isEmpty && !_confirmPasswFocus.hasFocus;
    final confirmPassMismatch = confirmPassTouched && _confirmPasswordController.text.isNotEmpty && _newPasswordController.text != _confirmPasswordController.text;

    return Column(
      children: [
        MyTextfield(hintText: "Current password",
          obscureText: true,
          controller: _currentPasswordController,
          inputFocus: _currentPasswFocus
        ),
        if(showErrCurrPass) ... [
          SizedBox(height: 3,),
          const Text(
            "Please enter your current password!",
            style: TextStyle(color: Colors.red),
          ),
        ],

        SizedBox(height: 10,),

        MyTextfield(hintText: "New password",
          obscureText: true,
          controller: _newPasswordController,
          inputFocus: _newPasswFocus
        ),
        if(showErrNewPass) ... [
          SizedBox(height: 3,),
          const Text(
            "Please enter your new password!",
            style: TextStyle(color: Colors.red),
          ),
        ]
        else if(newPassTouched && !checkPasswordConstraints(_newPasswordController.text)) ... [
          SizedBox(height: 3,),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: const Text(
              "Your password must be at least 8 characters long and include special characters!",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12
              ),
            ),
          ),
        ]
        // TODO: Check if this works
        else if(checkPasswordDiff(_currentPasswordController.text, _newPasswordController.text)) ... [
          SizedBox(height: 3,),
          const Text(
            "The new password cannot be the same as the old one!",
            style: TextStyle(color: Colors.red),
          ),
        ], 

        SizedBox(height: 10,),

        MyTextfield(hintText: "Confirm password",
          obscureText: true,
          controller: _confirmPasswordController,
          inputFocus: _confirmPasswFocus
        ),
        if(showErrConfirmPass) ... [
          SizedBox(height: 3,),
          const Text(
            "Please confirm your new password!",
            style: TextStyle(color: Colors.red),
          ),
        ]
        else if(confirmPassMismatch) ... [
          SizedBox(height: 3,),
          const Text(
            "Your passwords do not match!",
            style: TextStyle(color: Colors.red,),
          ),
        ],

        SizedBox(height: 20,),

        MyButton(text: "Change password",
          onTap: () {
            AuthService.updatePassword(_currentPasswordController.text, _newPasswordController.text, username);
          },
          color: 
          _currentPasswordController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _newPasswordController.text != _confirmPasswordController.text
          ? const Color.fromARGB(255, 222, 222, 222)
          : Colors.white,
          showShadow: 
          _currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty
          ? false
          : true,
        )
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ),
      body: _changePassBody(),
    );
  }
}