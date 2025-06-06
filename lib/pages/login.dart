import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/login_page_comp/my_button.dart';
import 'package:photo_album/components/login_page_comp/text_field.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final AuthService _authService = AuthService();
  
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: 'Welcome back ',
                children: <TextSpan>[
                  TextSpan(text: "Voshon", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "!"),
                ],
              ),
            ),
            Text("Please enter your username and password:"),

            SizedBox(height: 20,),

            AutofillGroup(
              child: Column(
                children: [
                  MyTextfield(
                    hintText: "Username",
                    obscureText: false,
                    controller: _emailController,
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
              onTap: () => {_authService.login(_emailController.text, _pwdController.text, context)}
            ),
          ],
        ),
      ),
    );
  }
}