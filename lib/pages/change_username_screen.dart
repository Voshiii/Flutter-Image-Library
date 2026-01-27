import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/verification.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';
import 'package:photo_album/components/settings_page_comp/pop_up_verify.dart';
import 'package:photo_album/services/fetch_service.dart';

class ChangeUsernameScreen extends StatefulWidget {
  final String username;
  final String email;
  const ChangeUsernameScreen(
      {super.key, required this.username, required this.email});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final _fetchService = FetchService();

  Timer? _countdownTimer;
  int animationTime = 5;

  bool usernameTouched = false;
  bool usernameTaken = false;

  bool _isLoading = false;

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onUsernameFocusChange() async {
    if (!_usernameFocus.hasFocus) {
      if (!mounted) return;
      setState(() => usernameTouched = true);
    }
  }

  // ! TODO check if there's a better way to check username without sending a request every time
  void checkUsername() async {
    if (_usernameController.text.isNotEmpty) {
      final res =
          await _fetchService.checkUsernameAvailable(_usernameController.text);
      if (!res) {
        if (!mounted) return;
        setState(() => usernameTaken = true);
      } else {
        if (!mounted) return;
        setState(() => usernameTaken = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onTextChanged);
    _usernameFocus.addListener(_onUsernameFocusChange);
    _usernameController.addListener(checkUsername);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onTextChanged);
    _usernameFocus.removeListener(_onUsernameFocusChange);
    _usernameController.dispose();
    _usernameFocus.dispose();
    _usernameController.removeListener(checkUsername);
    super.dispose();
    _countdownTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    bool usernameSame = _usernameController.text == AuthService.currentUsername;

    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text(
            "Change Username",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Stack(children: [
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
                  if (usernameTouched && _usernameController.text.isEmpty) ...[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Field cannot be empty!",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ] else if (usernameTaken) ...[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Username already been taken!",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ] else if (usernameSame) ...[
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "Username can't be the same!",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                  SizedBox(
                    height: 10,
                  ),
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
                      if (_usernameController.text.isNotEmpty &&
                          !usernameSame &&
                          !usernameTaken) {
                        sendVerificationCode(AuthService.currentUsernameTest.value!);

                        // setState(() {
                        //   _isLoading = true;
                        // });

                        final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) => VeryifyDialog(
                            userEmail: widget.email,
                            username: AuthService.currentUsernameTest.value!
                          ),
                        );

                        // Check that result is true and dialog not popped by clicking outside
                        if (result != null && result) {
                          final res = await AuthService.updateUsername(
                            AuthService.currentUsernameTest.value!,
                            _usernameController.text
                          );
                          if (res) {
                            AuthService.saveUsername(_usernameController.text);
                            _usernameController.clear();

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                usernameTouched = false;
                                _isLoading = true;
                              });
                            });
                          }
                        }
                        _countdownTimer = Timer(const Duration(seconds: 2), () {
                          setState(() {
                            _isLoading = false;
                          });
                          
                        });

                      }
                    },
                    color: _usernameController.text.isEmpty ||
                        usernameSame ||
                        usernameTaken
                        ? const Color.fromARGB(88, 222, 222, 222)
                        : Colors.white,
                    showShadow: _usernameController.text.isEmpty ||
                        usernameSame ||
                        usernameTaken
                        ? false
                        : true,
                  ),
                ),
              ),
            ),
            
          ],),
        ),
      ),

        // Loading overlay
      if(_isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black54, // semi-transparent dark background
            child: Center(
              child: LoadingAnimationWidget.waveDots(
                color: Colors.white,
                size: 150,
              ),
            ),
          ),
        ),
    ]);
  }
}
