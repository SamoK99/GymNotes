import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymnotes/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudSet {
  final String documentId;
  final String ownerUserId;
  final String parentNoteId;
  final String parentExerciseId;
  final num setReps;
  final num setWeight;
  const CloudSet({
    required this.documentId,
    required this.ownerUserId,
    required this.parentNoteId,
    required this.parentExerciseId,
    required this.setReps,
    required this.setWeight
  });

 CloudSet.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  ownerUserId = snapshot.data()[ownerUserIdFieldName],
  parentNoteId = snapshot.data()[parentNoteIdFieldName],
  parentExerciseId = snapshot.data()[parentExerciseIdFieldName],
  setReps = snapshot.data()[repsFieldName] as num,
  setWeight = snapshot.data()[weightFieldName] as num;
}