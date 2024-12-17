import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailctrlr=TextEditingController();
  TextEditingController password=TextEditingController();
  UserCredential?userCredential;
  // Future<void> login2(BuildContext context, String email, String password) async {
  //   try{
  //     final credentials=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${credentials.user!.email}")));
  //
  //   }catch(E){
  //     ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("${E}"))
  //     );
  //   }
  // }


  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> saveUserData(String uid, String name, String phone) async {
    try {
      await _database.child('users/$uid').set({
        'name': name,
        'phone': phone,
      });
      print('User data saved successfully.');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAllUsers() async {
    try {
      final snapshot = await _database.child('users').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        print('No users found in the database.');
        return {};
      }
    } catch (e) {
      print('Error fetching users: $e');
      return {};
    }
  }
  Future<void> login(BuildContext context, String email, String password) async {
    try {
      // Attempt to sign in
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      log("User logged in: ${credential.user?.email ?? "No email"}");
      setState(() {
        userCredential=credential;
      });
      saveUserData(userCredential!.user!.uid,email,password);
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful! Welcome ${credential.user?.displayName}')),
      );
    }
    on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      log("FirebaseAuthException: ${e.code}");
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email address format.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please try again.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again.';
      }
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Handle other exceptions
      log("Exception: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        TextFormField(
          controller: emailctrlr,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Email"
          ),
        ),
        TextFormField(
          obscureText: true,
          controller: password,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Password"
          ),
        ),
        ElevatedButton(onPressed: (){
          login(context,emailctrlr.text, password.text);
        }, child: Text("Login")),
        userCredential?.user!.email!=null?Container(
          height: 200,
          width: double.infinity,
          child: Row(children: [
            CircleAvatar(backgroundImage: NetworkImage("${userCredential!.user!.photoURL}"),),
            Text("${userCredential!.user!.email}")
          ],),
        ):Text("No data")
      ],),
    );
  }
}
