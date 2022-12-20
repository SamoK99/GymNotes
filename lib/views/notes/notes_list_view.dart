import 'package:flutter/material.dart';
import 'package:gymnotes/services/cloud/cloud_note.dart';
import 'package:intl/intl.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {

  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({super.key, required this.notes, required this.onDeleteNote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        String formattedDate = DateFormat('dd.MMM yyyy - ').format(note.createdAt);
        String formattedTime = DateFormat.Hm().format(note.createdAt);
        return ListTile(
          onTap: (){
            onTap(note);
          },
          title: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.black
              ),
              children: <TextSpan>[
                TextSpan(text: formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: formattedTime)
              ]
            )
          ),
          /* title: Text(
            formattedDate,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ), */
          trailing: IconButton(
            onPressed: () async{
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete){
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}