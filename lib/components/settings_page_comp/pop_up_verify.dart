import 'package:flutter/material.dart';
import 'package:verification_code_field/verification_code_field.dart';

class VeryifyDialog extends StatelessWidget {
  final String userEmail;
  const VeryifyDialog({
    super.key,
    required this.userEmail
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              children: [
                Text(
                  "Verify",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold
                  ),
                ),
            
                SizedBox(height: 10,),
        
                Text("Enter verification code sent to "),
                
                Text(
                  userEmail,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.visible,
                  ),
                ),
        
                SizedBox(height: 10,),
        
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 201, 201, 201),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Text(
                          "If you don't see the verification code in your inbox, "
                          "check your span box. If you have not received a verification code, "
                          "please try again soon.",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 67, 67, 67)
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                SizedBox(height: 20,),
            
                VerificationCodeField(
                  codeDigit: CodeDigit.four,
                  onSubmit: (value) => print("Submitted"),
                  enabled: true,
                  filled: true,
                  showCursor: true,
                  cursorColor: Colors.blue,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 88, 88, 88), width: 1.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 26,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold
                  ),
                ),

                SizedBox(height: 30,),

                Text(
                  "Resend code",
                  style: TextStyle(
                    color: Colors.blue
                  ),
                ),


                SizedBox(height: 50,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}