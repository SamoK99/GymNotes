import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gymnotes/views/login_view.dart';
import 'package:gymnotes/views/register_view.dart';
import 'package:gymnotes/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

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
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

 @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState){
          case ConnectionState.done:
            final user =  FirebaseAuth.instance.currentUser;
            if (user != null){
              if (user.emailVerified){
                return const NotesView();
              }else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
        
      },
    );
  }
}

enum MenuAction{logout}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>( 
            onSelected: (value) async{
              switch(value){
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout){
                    await FirebaseAuth.instance.signOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, 
                  child: Text('Log out')
                )
              ];
          },)
        ],
      ),
      body: const Text('Hello Mathn'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out')
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}



