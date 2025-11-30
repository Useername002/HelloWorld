import 'package:flutter/material.dart';
import 'package:helloworld/LoginUI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:helloworld/splash.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HelloWorld());
}
class HelloWorld extends StatefulWidget{
  @override
 State<HelloWorld> createState()=>HelloWorldState();
}
class HelloWorldState extends State<HelloWorld>{
 @override
  Widget build(BuildContext context)
 {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     title: "HelloWorld",
     theme: ThemeData(
       primaryColor: Colors.blue,
       appBarTheme: AppBarTheme(
         backgroundColor: Colors.blue[400],
         elevation: 2,
       ),
       colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
     ),
     home: Splash(),
   );
 }
}
