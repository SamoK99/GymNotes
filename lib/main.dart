import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Homepage(),
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Color.fromRGBO(252, 163, 17, 1.0),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.done:
              final user =  FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print('You are verified');
              }
              else{
                print('You need to be verified');
              }
              return const Text('Done');
            default:
              return const Text('Loading...');
          }
          
        },
      ),
    );
  }
}





