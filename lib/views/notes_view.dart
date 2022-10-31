import 'package:flutter/material.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;

import 'package:gymnotes/services/auth/auth_service.dart';

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
                    await AuthService.firebase().logOut();
                    if(mounted){
                      Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
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