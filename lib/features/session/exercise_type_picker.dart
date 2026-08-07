import 'package:flutter/material.dart';

import '../../domain/models/enums.dart';

/// Asks whether the user is adding strength work or cardio.
///
/// This runs *before* the exercise picker rather than being inferred from
/// whatever exercise happens to get tapped. The two disciplines are prescribed
/// and logged in completely different terms, so letting the choice fall out of
/// a search result is how a bench press ends up in a superset with a treadmill.
///
/// Returns null if dismissed.
Future<ExerciseType?> pickExerciseType(
  BuildContext context, {
  String title = 'Add exercise',
}) {
  return showDialog<ExerciseType>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(title),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(ExerciseType.strength),
          child: const ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text('Strength exercise'),
            subtitle: Text('Sets, reps and weight'),
          ),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(ExerciseType.cardio),
          child: const ListTile(
            leading: Icon(Icons.directions_run),
            title: Text('Cardio exercise'),
            subtitle: Text('Time, distance, pace and intervals'),
          ),
        ),
      ],
    ),
  );
}

/// The icon standing for each discipline, so the picker, the plan editor and
/// the workout list all mark them the same way.
IconData iconForExerciseType(ExerciseType type) => switch (type) {
  ExerciseType.cardio => Icons.directions_run,
  ExerciseType.strength => Icons.fitness_center,
};
