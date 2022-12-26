import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymnotes/services/cloud/cloud_exercise.dart';
import 'package:gymnotes/services/cloud/cloud_note.dart';
import 'package:gymnotes/services/cloud/cloud_set.dart';
import 'package:gymnotes/services/cloud/cloud_storage_constants.dart';
import 'package:gymnotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {

  final notes = FirebaseFirestore.instance.collection('notes');
  final exercises = FirebaseFirestore.instance.collection('exercises');
  final exerciseSets = FirebaseFirestore.instance.collection('exercise_sets');

  // Note CRUD
  Future<void> deleteNote({required String documentId}) async {
    try{
      await notes.doc(documentId).delete();
    } catch (e){
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updatedNote({
    required String documentId,
    required String text,
  }) async {
    try{
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e){
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    final allNotes = notes
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .orderBy(dateFieldName, descending: true)
      .snapshots().map((event) => event.docs.map((doc) => CloudNote.fromSnapshot(doc)));
        
    return allNotes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId, required DateTime createdAt}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      dateFieldName: createdAt,
      textFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      createdAt: createdAt,
      text: '',
    );
  }

  /* Future<Iterable<CloudExercise>> getExercise({required String parentNoteId}) async{
    try{
      return await exercises.where(
        parentNoteIdFieldName, isEqualTo: parentNoteId
      )
      .get()
      .then(
        (value) => value.docs.map((doc) => CloudExercise.fromSnapshot(doc))
      );
    } catch (e){
      throw CouldNotGetExercisesException();
    }
  } */

  // Exercise CRUD
  Future<CloudExercise> addExercise({
    required String ownerUserId,
    required String parentNoteId,
    required String exerciseName,
    required String bodyCategory,
  }) async{
    final document = await exercises.add({
      ownerUserIdFieldName: ownerUserId,
      parentNoteIdFieldName: parentNoteId,
      exerciseFieldName: exerciseName,
      bodyCategoryFieldName: bodyCategory
    });
    final fetchedExercise = await document.get();
    return CloudExercise(
      documentId: fetchedExercise.id,
      ownerUserId: ownerUserId,
      parentNoteId: parentNoteId,
      exerciseName: exerciseName,
      bodyCategory: bodyCategory
    );
  }
  Stream<Iterable<CloudExercise>> getExercises({required String ownerUserId, required String parentNoteId}) {
    final allExercises = exercises
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .where(parentNoteIdFieldName, isEqualTo: parentNoteId)
      .snapshots().map((event) => event.docs.map((doc) => CloudExercise.fromSnapshot(doc)));

    return allExercises;
  }

  // Sets CRUD
  Stream<Iterable<CloudSet>> getSets({required String ownerUserId, required String parentExerciseId}) {
    final allSets = exerciseSets
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .where(parentExerciseIdFieldName, isEqualTo: parentExerciseId)
      .snapshots().map((event) => event.docs.map((doc) => CloudSet.fromSnapshot(doc)));

    return allSets;
  }

  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}