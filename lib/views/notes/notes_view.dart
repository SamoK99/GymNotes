import 'package:flutter/material.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/crud/notes_service.dart';
import 'package:gymnotes/views/notes/notes_list_view.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState(){
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add)
          ),
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: ((context, snapshot) {
                  switch (snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData){
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async{
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      }else{
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                }),
              );
            default:
              return const CircularProgressIndicator();
          }
        }
      ),
    );
  }
}

/* Future<bool> showLogOutDialog(BuildContext context){
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
} */