import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';

/// Lets the user choose an exercise to add to a workout.
///
/// Returns the chosen exercise, or null if dismissed.
Future<ExerciseRow?> pickExercise(BuildContext context, {ExerciseType? type}) {
  return showModalBottomSheet<ExerciseRow>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _ExercisePicker(type: type),
    ),
  );
}

class _ExercisePicker extends ConsumerStatefulWidget {
  const _ExercisePicker({this.type});

  final ExerciseType? type;

  @override
  ConsumerState<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<_ExercisePicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(
      exerciseCatalogProvider((
        type: widget.type,
        muscleGroup: null,
        equipment: null,
        includeArchived: false,
      )),
    );

    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Add exercise', style: Theme.of(context).textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        Expanded(
          child: catalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('$error')),
            data: (rows) {
              final needle = _search.trim().toLowerCase();
              final filtered = needle.isEmpty
                  ? rows
                  : rows.where((e) => e.nameKey.contains(needle)).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No matching exercises.'));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final exercise = filtered[i];
                  return ListTile(
                    leading: Icon(
                      exercise.type == ExerciseType.cardio
                          ? Icons.directions_run
                          : Icons.fitness_center,
                    ),
                    title: Text(exercise.name),
                    subtitle: exercise.muscleGroup == null
                        ? null
                        : Text(exercise.muscleGroup!),
                    onTap: () => Navigator.of(context).pop(exercise),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
