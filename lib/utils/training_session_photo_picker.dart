import 'dart:math';

import 'package:physical_activity_log_app/constants/training_session_photos.dart';
import 'package:physical_activity_log_app/models/training_session.dart';

final _random = Random();

String pickTrainingSessionPhoto(List<TrainingSession> existingSessions) {
  final usedPhotos = existingSessions.map((session) => session.photoName).toSet();
  var availablePhotos = TrainingSessionPhotos.all
      .where((photo) => !usedPhotos.contains(photo))
      .toList();

  if (availablePhotos.isEmpty) {
    final sessionPhotos =
        existingSessions.map((session) => session.photoName).toList();
    final stillUsedPhotos = _photosToAvoidWhenAllUsed(sessionPhotos);
    availablePhotos = TrainingSessionPhotos.all
        .where((photo) => !stillUsedPhotos.contains(photo))
        .toList();
  }

  if (availablePhotos.isEmpty) {
    availablePhotos = List<String>.from(TrainingSessionPhotos.all);
  }

  return availablePhotos[_random.nextInt(availablePhotos.length)];
}

Set<String> _photosToAvoidWhenAllUsed(List<String> sessionPhotos) {
  if (sessionPhotos.length <= 8) {
    return sessionPhotos.toSet();
  }

  return sessionPhotos.sublist(4, sessionPhotos.length - 4).toSet();
}
