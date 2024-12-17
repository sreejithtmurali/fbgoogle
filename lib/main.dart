import 'package:fbgoogle/home.dart';
import 'package:fbgoogle/login.dart';
import 'package:fbgoogle/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'notificationservice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await Firebase.initializeApp(
    options:FirebaseOptions(
        apiKey: "AIzaSyDgvoiBoQ3LU14B8ps3NmGtTGiMV--fT_M",
        appId: "1:170873898477:android:a7168a0ce94c129b21d3e4",
        messagingSenderId: "170873898477",
        projectId: "luminaraug"),
  );
  runApp(const MyApp());

  await NotificationService().registerPushNotificationHandler();

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHome(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignIn _googleSignIn=GoogleSignIn();
  GoogleSignInAccount? _user;


  Future<GoogleSignInAccount?> signIn() async {
    try{
      final GoogleSignInAccount? user=await _googleSignIn.signIn();
      if(user!=null){
        setState(() {
          _user=user;
        });
      }
      return user;
    }
    catch(e){
      print(e);
    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
    body: _user!=null?Text("${_user!.displayName}"):Center(child: ElevatedButton(
        onPressed: () async {
      await signIn();
    },
        child: Text("signup with google")),),

    // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
