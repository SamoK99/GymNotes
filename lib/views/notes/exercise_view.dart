import 'package:flutter/material.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/cloud/cloud_exercise.dart';
import 'package:gymnotes/services/cloud/cloud_set.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/views/notes/exercise_set_view.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef ExerciseCallback = void Function(CloudExercise exercise);
typedef SetCallback = void Function(CloudSet set);
String get userId => AuthService.firebase().currentUser!.id;

class ExerciseView extends StatelessWidget {

  final Iterable<CloudExercise> exercises;
  final FirebaseCloudStorage notesService;
  //final Iterable<CloudSet> sets;
  //final ExerciseCallback onDeleteExercise;
  //final ExerciseCallback onTap;

  const ExerciseView({super.key, required this.exercises, required this.notesService});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises.elementAt(index);
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 245, 239, 239)
          ),
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      color: Color.fromRGBO(24, 22, 33, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    )
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.bodyCategory,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 165, 164, 167),
                      fontWeight: FontWeight.normal,
                      fontSize: 16
                    )
                  )
                ],
              ),
              StreamBuilder(
                stream: notesService.getSets(ownerUserId: userId, parentExerciseId: exercise.documentId),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData){
                        final allSets = snapshot.data as Iterable<CloudSet>;
                        if(allSets.isNotEmpty){
                          return ExerciseSetView(sets: allSets);
                        }
                        else{
                          return const Center(child: Text('No sets added'));
                        }
                      }else{
                        return const Center(child: CircularProgressIndicator());
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 34, 53, 1),
                      padding: const EdgeInsets.fromLTRB(128, 10, 128, 10)),
                  onPressed: () {},
                  child: const Text("ADD SET",)
              ),
            ]
          )
        );
      }
    );
    //Color.fromRGBO(252, 163, 17, 1)
    
  }
}