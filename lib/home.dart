import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  DatabaseReference _reference = FirebaseDatabase.instance.ref();
  Future<Map<String, dynamic>?> fetchdata() async {
    try {
      updateloading();
      final snapshot = await _reference.child('users').get();
      if (snapshot.exists) {
        updateloading();
        final rawData = snapshot.value as Map<Object?, Object?>;
        setState(() {
          usermap=rawData.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map),
          ));
        });
        // Safely convert the map
        return rawData.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map),
        ));
      } else {
        updateloading();
        throw Exception("No data");
      }
    } catch (e) {
      print("exception::::::::::::$e");
    }
  }

  Map<String, dynamic>? usermap;
  bool isloding = false;
  void updateloading() {
    setState(() {
      isloding = !isloding;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isloding
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: usermap!.length,
              itemBuilder: (BuildContext context, int index) {
                String userId = usermap!.keys.elementAt(index);
                Map<String, dynamic> user = usermap![userId];
                return ListTile(
                  title: Text("${user["name"]}"),
                  subtitle: Text("${user["email"]}"),
                );

              },
            ),
    );
  }
}
