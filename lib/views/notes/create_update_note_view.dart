import 'package:flutter/material.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/cloud/cloud_exercise.dart';
import 'package:gymnotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:gymnotes/utilities/generics/get_arguments.dart';
import 'package:gymnotes/services/cloud/cloud_note.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/views/notes/exercise_view.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updatedNote(
      documentId: note.documentId,
      text: text
    );
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final date = DateTime.now();
    final newNote = await _notesService.createNewNote(ownerUserId: userId, createdAt: date);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfNotEmpty() async{
    final note = _note;
    final text = _textController.text;
    if (note != null && text.isNotEmpty){
      await _notesService.updatedNote(
        documentId: note.documentId,
        text: text
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('New Note'),
        actions: [
          IconButton(
            onPressed: () async{
              final text = _textController.text;
              if (_note == null || text.isEmpty){
                await showCannotShareEmptyNoteDialog(context);
              } else{
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share)
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              _setupTextControllerListener();
              final thisNoteOwner = _note!.ownerUserId;
              final thisNoteId = _note!.documentId;
              final getExercises = _notesService.getExercises(ownerUserId: thisNoteOwner, parentNoteId: thisNoteId);
              //final getSets = _notesService.getSets(ownerUserId: thisNoteOwner, parentNoteId: thisNoteId, parentExerciseId: );
              return StreamBuilder(
                stream: getExercises,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData){
                        final allExercises = snapshot.data as Iterable<CloudExercise>;
                        if(allExercises.isNotEmpty){
                          return ExerciseView(exercises: allExercises, notesService: _notesService,);
                        }
                        else{
                          return const Center(child: Text('No exercises in this session'));
                        }
                      }else{
                        return const Center(child: CircularProgressIndicator());
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              );
              /* return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...'
                ),
              ); */
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: 
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {},
            label: const Text('Add Exercise'),
            icon: const Icon(Icons.add)
          ),
        )
    );
  }
}