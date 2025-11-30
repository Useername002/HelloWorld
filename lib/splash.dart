import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helloworld/HomePage.dart';
import 'package:helloworld/LoginUI.dart';
import 'package:helloworld/Database/Remote/firebase_auth.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() {
    return SplashState();
  }
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    CheckLoginStatus();
  }

  //shared preferences code
  // Future<void>CheckLoginStatus()async{
  //   await Future.delayed(Duration(seconds: 3));
  //   final prefs=await SharedPreferences.getInstance();
  //   final isLoggedin=prefs.getBool('isLoggedin')??false;
  //   final userName=prefs.getString('userName')??'user';
  //   if(isLoggedin)
  //     {
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomePage(userName: userName)),
  //       );
  //     }
  //   else
  //     {
  //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>Login_UI()),);
  //     }
  //
  // }
  Future<void> CheckLoginStatus() async {
    await Future.delayed(Duration(seconds: 3));
    final user = RemoteDb.instance.getCurrentUser();
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final userData = doc.data()!;
        final userName = userData['name'] ?? "User";
        final userPhone = userData['phone'] ?? "Not available";
        final profileUrl = userData["profileUrl"] ?? " ";
        final userRole = userData["role"];
        if (userRole == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(
                userName: userName,
                phoneNumber: userPhone,
                profileUrl: profileUrl,
              ),
            ),
          );
        }
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginUI()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Text(
            "HelloWorld",
            style: TextStyle(
              fontSize: 55,
              fontWeight: FontWeight.w800,
              color: Colors.blue[600],
            ),
          ),
        ),
      ),
    );
  }
}
