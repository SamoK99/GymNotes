import 'package:flutter/material.dart';
import 'package:gymnotes/services/auth/auth_service.dart';
import 'package:gymnotes/services/cloud/cloud_exercise.dart';
import 'package:gymnotes/services/cloud/cloud_set.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/views/notes/exercise_set_view.dart';
import 'package:holding_gesture/holding_gesture.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef ExerciseCallback = void Function(CloudExercise exercise);
String get userId => AuthService.firebase().currentUser!.id;
int reps = 1;
double weight = 60;
Color darkPurple = const Color.fromRGBO(24, 22, 33, 1);

class ExerciseView extends StatelessWidget {

  final Iterable<CloudExercise> exercises;
  final FirebaseCloudStorage notesService;
  final ExerciseCallback onDeleteExercise;
  final ExerciseCallback editExercise;

  const ExerciseView({super.key, required this.exercises, required this.notesService, required this.onDeleteExercise, required this.editExercise});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 75),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises.elementAt(index);
        void showBottomSheet(){
          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (BuildContext c, setState) => ListView(
                shrinkWrap: true, 
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      color: darkPurple,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "REPS",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HoldDetector(
                              onHold: () {
                                if(reps >= 5){
                                  setState(() {
                                    reps -= 5;
                                  });
                                }
                              },
                              enableHapticFeedback: true,
                              child: IconButton(
                                onPressed: () {
                                  if(reps > 0){
                                    setState(() {
                                      reps -= 1;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove, color: Colors.white)
                              ),
                            ),
                            Text(
                              reps.toString(),
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 90
                              ),
                            ),
                            HoldDetector(
                              onHold: () {
                                if(reps < 500){
                                  setState(() {
                                    reps += 5;
                                  });
                                }
                              },
                              enableHapticFeedback: true,
                              child: IconButton(
                                onPressed: () {
                                  if(reps < 500){
                                    setState(() {
                                      reps += 1;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add, color: Colors.white)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "WEIGHT",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HoldDetector(
                              onHold: () {
                                if(weight >= 5){
                                  setState(() {
                                    weight -= 5;
                                  });
                                }
                              },
                              enableHapticFeedback: true,
                              child: IconButton(
                                onPressed: () {
                                  if(weight > 0){
                                    setState(() {
                                      weight -= 0.5;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove, color: Colors.white)
                              ),
                            ),
                            Text(
                              weight.toStringAsFixed(1),
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 90
                              ),
                            ),
                            HoldDetector(
                              onHold: () {
                                if(weight < 1000){
                                  setState(() {
                                    weight += 5;
                                  });
                                }
                              },
                              enableHapticFeedback: true,
                              child: IconButton(
                                onPressed: () {
                                  if(weight < 1000){
                                    setState(() {
                                      weight += 0.5;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add, color: Colors.white)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RawMaterialButton(
                          padding: const EdgeInsets.fromLTRB(130, 20, 130, 20),
                          elevation: 5,
                          fillColor: Colors.white,
                          onPressed: () {
                            final date = DateTime.now();
                            notesService.addSet(ownerUserId: userId, parentNoteId: exercise.parentNoteId, parentExerciseId: exercise.documentId, setReps: reps, setWeight: weight, createdAt: date);
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(10)
                          ),
                          child: Text(
                            "ADD SET",
                            style: TextStyle(color: darkPurple),
                          ),
                        )
                      ],
                    ),
                  )
                ]
              )
            )
          );
        }
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 245, 239, 239)
          ),
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      color: Color.fromRGBO(24, 22, 33, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, 10, 0),
                    child: PopupMenuButton( 
                      icon: const Icon(Icons.more_horiz,),
                      onSelected: (value) async{
                        switch(value){
                          case MenuActionDelete.delete:
                            final shouldDelete = await showDeleteDialog(context);
                            if (shouldDelete){
                              onDeleteExercise(exercise);
                            }
                            break;
                          case MenuActionEdit.edit:
                            editExercise(exercise);
                        }
                      },
                      itemBuilder: (context) {
                        return const [
                          
                          PopupMenuItem<MenuActionEdit>(
                            value: MenuActionEdit.edit,
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<MenuActionDelete>(
                            value: MenuActionDelete.delete, 
                            child: Text('Delete')
                          ),
                        ];
                      }
                    ),
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
                      fontSize: 16,
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
                          return ExerciseSetView(
                            sets: allSets,
                            onDeleteSet: (set) async{
                              await notesService.deleteSet(documentId: set.documentId);
                            },
                          );
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
                      minimumSize: const Size.fromHeight(35)),
                  onPressed: () {
                    showBottomSheet();
                  },
                  child: const Text("ADD SET")
              ),
            ]
          )
        );
        
      }
    );
    //Color.fromRGBO(252, 163, 17, 1)
  }

}