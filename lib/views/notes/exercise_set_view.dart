import 'package:flutter/material.dart';
import 'package:gymnotes/services/cloud/cloud_set.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef SetCallback = void Function(CloudSet set);

class ExerciseSetView extends StatelessWidget {

  final Iterable<CloudSet> sets;
  final SetCallback onDeleteSet;
  //final ExerciseCallback onTap;

  const ExerciseSetView({super.key, required this.sets, required this.onDeleteSet});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets.elementAt(index);
        final setCount = index +1;
        return Container(
          padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
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
              Material(
                color: const Color.fromARGB(255, 245, 239, 239),
                child: IconButton(
                  splashRadius: 24,
                  tooltip: 'Delete',
                  onPressed: () {
                    onDeleteSet(set);
                  },
                   icon: const Icon(Icons.delete, color: Color.fromARGB(255, 99, 96, 96),)
                ),
              )
            ],
          ),
        );
      }
    );
    //Color.fromRGBO(252, 163, 17, 1)
    
  }
}