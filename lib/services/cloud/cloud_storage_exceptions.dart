class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C
class CouldNotCreateNoteException extends CloudStorageException {}

// R
class CouldNotGetAllNoteException extends CloudStorageException {}
class CouldNotGetExercisesException extends CloudStorageException {}

// U
class CouldNotUpdateNoteException extends CloudStorageException {}
class CouldNotUpdateExerciseException extends CloudStorageException {}

// D
class CouldNotDeleteNoteException extends CloudStorageException {}
class CouldNotDeleteSetException extends CloudStorageException {}
class CouldNotDeleteExerciseException extends CloudStorageException {}