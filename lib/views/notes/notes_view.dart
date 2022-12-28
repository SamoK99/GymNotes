import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymnotes/constants/routes.dart';
import 'package:gymnotes/enums/menu_action.dart';
import 'dart:developer' as devtools show log;
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/auth/bloc/auth_bloc.dart';
import 'package:gymnotes/services/auth/bloc/auth_event.dart';
import 'package:gymnotes/services/cloud/cloud_note.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/views/notes/notes_list_view.dart';
import '../../utilities/dialogs/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Workouts'),
        actions: [
          PopupMenuButton<MenuActionLogout>( 
            onSelected: (value) async{
              switch(value){
                case MenuActionLogout.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout){
                    if(mounted){
                      context.read<AuthBloc>().add(
                      const AuthEventLogOut()
                    );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuActionLogout>(
                  value: MenuActionLogout.logout, 
                  child: Text('Log out')
                )
              ];
            }
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData){
                final allNotes = snapshot.data as Iterable<CloudNote>;
                if(allNotes.isNotEmpty){
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async{
                      await _notesService.deleteNote(documentId: note.documentId, ownerUserId: userId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note
                      );
                    },
                  );
                }
                else{
                  return const Center(child: Text('You have no workout logs'));
                }
              }else{
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        }),
      ),

      floatingActionButton: 
        FloatingActionButton(
          tooltip: 'Create a workout',
          onPressed: () {
            Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
          },
          child: const Icon(Icons.add),
        ),
    );
  }
}
