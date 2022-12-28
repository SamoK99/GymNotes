import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:gymnotes/utilities/Lists/body_part_menu_items_list.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showAddExerciseDialog<T>({
  required BuildContext context,
  required String title,
  required TextEditingController controller,
  required String selectedValue,
  required FirebaseCloudStorage service,
  required String userId,
  required String noteId,
}){
  return showDialog<T>(
    context: context,
    builder: (context){
      return AlertDialog(
        insetPadding: const EdgeInsets.all(10),
        title: Center(child: Text(title)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Builder(
          builder: (context) {
            var width = MediaQuery.of(context).size.width;
            var height = MediaQuery.of(context).size.height;
            return SizedBox(
              width: width - 100,
              height: height - 680,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    inputFormatters: [LengthLimitingTextInputFormatter(30),],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      labelText: 'Exercise Name',
                      suffixIcon: const Icon(Icons.fitness_center)
                    ),
                  ),
                  DropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      labelText: 'Muscle Category'
                    ),
                    value: selectedValue,
                    items: dropdownItems, 
                    onChanged: (String? newValue) {
                        selectedValue = newValue!;
                    },
                  )
                ],
              ),
            );
          }
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.all(0),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close')
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), topLeft: Radius.circular(4)),
                      ),
                    ),
                    onPressed: () {
                      final exerciseNameText = controller.text;
                      final date = DateTime.now();
                      if (exerciseNameText.isEmpty || exerciseNameText == ''){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Exercise requires a name'), backgroundColor: Colors.red[700] ),
                        );
                        Navigator.of(context).pop();
                      }
                      else{
                        service.addExercise(ownerUserId: userId, parentNoteId: noteId, exerciseName: exerciseNameText, bodyCategory: selectedValue, createdAt: date );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$exerciseNameText added'), backgroundColor: Colors.green[600] ),
                        );
                        Navigator.of(context).pop();
                        controller.clear();
                      }
                    },
                    child: const Text('Add')
                  ),
                ),
              ),
            ],
          ) 
        ],
      );
    }
  );
}