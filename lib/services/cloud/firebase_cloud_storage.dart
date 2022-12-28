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
  Future<void> deleteNote({required String documentId, required String ownerUserId}) async {
    try{
      await exerciseSets
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .where(parentNoteIdFieldName, isEqualTo: documentId)
        .get().then((snapshot){
          List<DocumentSnapshot> setsToDelete = snapshot.docs
          .toList();
          for (DocumentSnapshot set in setsToDelete){
            set.reference.delete();
          }
        });
      await exercises
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .where(parentNoteIdFieldName, isEqualTo: documentId)
        .get().then((snapshot){
          List<DocumentSnapshot> exercisesToDelete = snapshot.docs
          .toList();
          for (DocumentSnapshot exercise in exercisesToDelete){
            exercise.reference.delete();
          }
        });
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
      textFieldName: 'Workout Session',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      createdAt: createdAt,
      text: 'Workout Session',
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
    required DateTime createdAt
  }) async{
    final document = await exercises.add({
      ownerUserIdFieldName: ownerUserId,
      parentNoteIdFieldName: parentNoteId,
      exerciseFieldName: exerciseName,
      bodyCategoryFieldName: bodyCategory,
      dateFieldName: createdAt
    });
    final fetchedExercise = await document.get();
    return CloudExercise(
      documentId: fetchedExercise.id,
      ownerUserId: ownerUserId,
      parentNoteId: parentNoteId,
      exerciseName: exerciseName,
      bodyCategory: bodyCategory, 
      createdAt: createdAt
    );
  }
  Stream<Iterable<CloudExercise>> getExercises({required String ownerUserId, required String parentNoteId}) {
    final allExercises = exercises
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .where(parentNoteIdFieldName, isEqualTo: parentNoteId)
      .orderBy(dateFieldName, descending: false)
      .snapshots().map((event) => event.docs.map((doc) => CloudExercise.fromSnapshot(doc)));

    return allExercises;
  }

  Future<void> updatedExercise({
    required String documentId,
    required String exerciseName,
    required String bodyCategory
  }) async {
    try{
      await exercises.doc(documentId).update({
        exerciseFieldName: exerciseName,
        bodyCategoryFieldName: bodyCategory,
      });
    } catch (e){
      throw CouldNotUpdateExerciseException();
    }
  }

  Future<void> deleteExercise({required String documentId, required String ownerUserId}) async {
    try{
      await exerciseSets
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .where(parentExerciseIdFieldName, isEqualTo: documentId)
        .get().then((snapshot){
          List<DocumentSnapshot> setsToDelete = snapshot.docs
          .toList();
          for (DocumentSnapshot set in setsToDelete){
            set.reference.delete();
          }
        });
      await exercises.doc(documentId).delete();
    } catch (e){
      throw CouldNotDeleteExerciseException();
    }
  }

  // Sets CRUD
  Future<CloudSet> addSet({
    required String ownerUserId,
    required String parentNoteId,
    required String parentExerciseId,
    required num setReps,
    required num setWeight,
    required DateTime createdAt
  }) async{
    final document = await exerciseSets.add({
      ownerUserIdFieldName: ownerUserId,
      parentNoteIdFieldName: parentNoteId,
      parentExerciseIdFieldName: parentExerciseId,
      repsFieldName: setReps,
      weightFieldName: setWeight,
      dateFieldName: createdAt
    });
    final fetchedSet = await document.get();
    return CloudSet(
      documentId: fetchedSet.id,
      ownerUserId: ownerUserId,
      parentNoteId: parentNoteId,
      parentExerciseId: parentExerciseId,
      setReps: setReps,
      setWeight: setWeight,
      createdAt: createdAt
    );
  }

  Stream<Iterable<CloudSet>> getSets({required String ownerUserId, required String parentExerciseId}) {
    final allSets = exerciseSets
      .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
      .where(parentExerciseIdFieldName, isEqualTo: parentExerciseId)
      .orderBy(dateFieldName, descending: false)
      .snapshots().map((event) => event.docs.map((doc) => CloudSet.fromSnapshot(doc)));

    return allSets;
  }

  Future<void> deleteSet({required String documentId}) async {
    try{
      await exerciseSets.doc(documentId).delete();
    } catch (e){
      throw CouldNotDeleteSetException();
    }
  }

  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}