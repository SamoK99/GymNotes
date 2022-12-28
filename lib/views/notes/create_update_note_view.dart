import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/cloud/cloud_exercise.dart';
import 'package:gymnotes/utilities/dialogs/add_exercise_dialog.dart';
import 'package:gymnotes/utilities/dialogs/edit_exercise_dialog.dart';
import 'package:gymnotes/utilities/generics/get_arguments.dart';
import 'package:gymnotes/services/cloud/cloud_note.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/views/notes/exercise_view.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  String get userId => AuthService.firebase().currentUser!.id;
  String get thisNoteId => _note!.documentId;
  String selectedValue = "Chest";
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  final exerciseNameController = TextEditingController();

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
    
    final date = DateTime.now();
    final newNote = await _notesService.createNewNote(ownerUserId: userId, createdAt: date);
    _note = newNote;
    return newNote;
  }

  void _saveNoteIfNotEmpty() async{
    final note = _note;
    var text = _textController.text;
    if (text == ''){
      text = 'Workout Session';
    }
    if (note != null && text.isNotEmpty){
      await _notesService.updatedNote(
        documentId: note.documentId,
        text: text
      );
    }
  }

  @override
  void dispose() {
    _saveNoteIfNotEmpty();
    _textController.dispose();
    exerciseNameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          inputFormatters: [
            LengthLimitingTextInputFormatter(26),
          ],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Name your session',
            hintStyle: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: createOrGetExistingNote(context),
            builder: (context, snapshot) {
              switch(snapshot.connectionState){
                case ConnectionState.done:
                  _setupTextControllerListener();
                  final getExercises = _notesService.getExercises(ownerUserId: userId, parentNoteId: thisNoteId);
                  return StreamBuilder(
                    stream: getExercises,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData){
                            final allExercises = snapshot.data as Iterable<CloudExercise>;
                            if(allExercises.isNotEmpty){
                              return ExerciseView(
                                exercises: allExercises,
                                notesService: _notesService,
                                onDeleteExercise: (exercise) async{
                                  await _notesService.deleteExercise(documentId: exercise.documentId, ownerUserId: userId);
                                },
                                editExercise: (exercise) async{
                                  exerciseNameController.text = exercise.exerciseName;
                                  await showEditExerciseDialog(
                                    context: context,
                                    title: 'Edit Exercise',
                                    controller: exerciseNameController,
                                    selectedValue: selectedValue,
                                    service: _notesService,
                                    exerciseId: exercise.documentId
                                  );
                                },
                              );
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
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned.fill(
            bottom: 15,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  showAddExerciseDialog(
                    context: context,
                    title: 'Add Exercise',
                    controller: exerciseNameController,
                    selectedValue: selectedValue,
                    service: _notesService,
                    userId: userId,
                    noteId: thisNoteId
                  );
                },
                label: const Text('Add Exercise'),
                icon: const Icon(Icons.add)
              ),
            ),
          )
        ],
      ),
    );
  }
}