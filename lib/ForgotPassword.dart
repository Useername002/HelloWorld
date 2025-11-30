import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/LoginUI.dart';


class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController Emailcontroller = TextEditingController();
  bool isLoading = false;
  Future<void> Resetpassword() async {
    final email = Emailcontroller.text.trim();
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.purple[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          title: Text("Error"),
          content: Text("Enter a valid email address"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.purple[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.0),
          ),
          title: Row(
            children: [
              Icon(Icons.mark_email_read),
              SizedBox(width: 8),
              Text("Email sent"),
            ],
          ),
          content: Text(
            "Email sent to $email."
                "Check your inbox(and spam folder)",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginUI()),
                      (route) => false,
                );
              },
              child: Text("ok"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "An error occured.";
      if (e.code == "user-not-found") {
        message = "user not found with that email.";
      } else if (e.code == "invalid-email") {
        message = "invalid email address.";
      }
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.purple[50],
          title: Row(
            children: [Icon(Icons.error), SizedBox(width: 5), Text("Error")],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Ok"),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HelloWorld",
          style: TextStyle(fontSize: 25, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  "Forgot password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[600],
                  ),
                ),
                SizedBox(height: 50),
                TextField(
                  controller: Emailcontroller,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(11.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(11.0),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      elevation: 2,
                      shadowColor: Colors.grey,
                    ),
                    onPressed: isLoading ? null : Resetpassword,
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text("Send"),
                  ),
                ),
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Note:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                        "An email will be sent to above address with a link to reset password.",
                      ),
                      TextSpan(
                        text:
                        "\nEmail will be sent only on registered Email ID.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginUI()),
                          (route) => false,
                    ),
                    child: Text(
                      "Remember password?",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                        decorationThickness: 2,
                        height: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
