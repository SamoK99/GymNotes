import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymnotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudExercise {
  final String documentId;
  final String parentNoteId;
  final String exerciseName;
  final String bodyCategory;
  final String ownerUserId;
  const CloudExercise({
    required this.documentId,
    required this.parentNoteId,
    required this.exerciseName,
    required this.bodyCategory,
    required this.ownerUserId
  });

 CloudExercise.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  parentNoteId = snapshot.data()[parentNoteIdFieldName],
  exerciseName = snapshot.data()[exerciseFieldName] as String,
  bodyCategory = snapshot.data()[bodyCategoryFieldName] as String,
  ownerUserId = snapshot.data()[ownerUserIdFieldName];
}