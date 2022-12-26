import 'package:flutter/material.dart';
import 'package:gymnotes/services/cloud/cloud_set.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef SetCallback = void Function(CloudSet set);

class ExerciseSetView extends StatelessWidget {

  final Iterable<CloudSet> sets;
  //final ExerciseCallback onDeleteExercise;
  //final ExerciseCallback onTap;

  const ExerciseSetView({super.key, required this.sets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets.elementAt(index);
        final setCount = index +1;
        return Container(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(setCount.toString(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 16)
              ),
              Text('${set.setReps} reps',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16)
              ),
                Text('${set.setWeight} kg',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16)
              ),
            ],
          ),
        );
      }
    );
    //Color.fromRGBO(252, 163, 17, 1)
    
  }
}