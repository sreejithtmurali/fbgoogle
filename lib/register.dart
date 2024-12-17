import 'dart:developer';

import 'package:fbgoogle/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailctrlr=TextEditingController();
  TextEditingController passwordctr=TextEditingController();
  TextEditingController namectrlr=TextEditingController();
  TextEditingController phctrlr=TextEditingController();
  int Lumin=0;
  void updatelumin(){
    setState(() {
      Lumin++;
    });
  }
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Future<bool> save(String uid, String name, String phone,String email,String pass)
  async {
           try {
                    await  _database.child("users/$uid").set({
                       'name': name,
                       'phone': phone,
                       'email': email,
                       'password': pass
                     });
                    updatelumin();
                    return true;
           }
           catch(e)
           {
             print("Exception:::::$e");
             return false;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        TextFormField(
          controller: namectrlr,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Name"
          ),
        ),
        TextFormField(
          controller: phctrlr,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Phone"
          ),
        ),
        TextFormField(
          controller: emailctrlr,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Email"
          ),
        ),

        TextFormField(
          obscureText: true,
          controller: passwordctr,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Password"
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              await save("Lumin$Lumin", namectrlr.text, phctrlr.text, emailctrlr.text, passwordctr.text).then((value){
                if(value==true){
                  namectrlr.clear();
                  passwordctr.clear();
                  phctrlr.clear();
                  emailctrlr.clear();
                }
              });
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {  return MyHome();}));

        }, child: Text("Register")),

      ],),
    );
  }
}
