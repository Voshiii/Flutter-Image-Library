import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/verification.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/password_checker.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/components/settings_page_comp/pop_up_verify.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String username;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.username,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _currentPasswFocus = FocusNode();
  final FocusNode _newPasswFocus = FocusNode();
  final FocusNode _confirmPasswFocus = FocusNode();
  
  bool currPassTouched = false;
  bool newPassTouched = false;
  bool confirmPassTouched = false;

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

  @override
  void initState() {
    super.initState();

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

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              MyTextfield(hintText: "Current password",
                obscureText: true,
                controller: _currentPasswordController,
                inputFocus: _currentPasswFocus,
                touched: currPassTouched,
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
                inputFocus: _newPasswFocus,
                touched: newPassTouched,
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
              else if(newPassTouched && checkPasswordDiff(_currentPasswordController.text, _newPasswordController.text)) ... [
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
                inputFocus: _confirmPasswFocus,
                touched: confirmPassTouched,
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
          
              
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 70,
                child: MyButton(
                  text: "Change password",
                  onTap: () async {
                    if(!showErrCurrPass && !showErrNewPass && !showErrConfirmPass && !confirmPassMismatch && !checkPasswordDiff(_currentPasswordController.text, _newPasswordController.text)){
                      sendVerificationCode(widget.username);
                      final result = await showDialog(
                        context: context,
                        builder: (BuildContext context) => VeryifyDialog(userEmail: widget.email, username: widget.username,),
                      );
                      if(result){
                        final res = await AuthService.updatePassword(_currentPasswordController.text, _newPasswordController.text, AuthService.currentUsernameTest.value!);
                        if(res) {
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                          setState(() {
                            currPassTouched = false;
                            newPassTouched = false;
                            confirmPassTouched = false;
                          });
                        }
                      }
                    }
                  },
                  color: 
                  _currentPasswordController.text.isEmpty ||
                  _newPasswordController.text.isEmpty ||
                  _confirmPasswordController.text.isEmpty ||
                  _newPasswordController.text != _confirmPasswordController.text ||
                  checkPasswordDiff(_currentPasswordController.text, _newPasswordController.text)
                  ? const Color.fromARGB(255, 222, 222, 222)
                  : Colors.white,
                  showShadow: 
                  _currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty
                  ? false
                  : true,
                ),
              ),
            ),
          )
        ]
      ),
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