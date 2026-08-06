import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import 'vocabulary_field.dart';

/// Creates a new exercise, or edits an existing one when [existing] is given.
Future<void> showExerciseEditor(
  BuildContext context,
  WidgetRef ref, {
  ExerciseRow? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _ExerciseEditor(existing: existing),
    ),
  );
}

class _ExerciseEditor extends ConsumerStatefulWidget {
  const _ExerciseEditor({this.existing});

  final ExerciseRow? existing;

  @override
  ConsumerState<_ExerciseEditor> createState() => _ExerciseEditorState();
}

class _ExerciseEditorState extends ConsumerState<_ExerciseEditor> {
  late final TextEditingController _name;
  late ExerciseType _type;
  late CardioActivity? _activity;
  String? _muscleGroup;
  String? _equipment;

  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _muscleGroup = existing?.muscleGroup;
    _equipment = existing?.equipment;
    _type = existing?.type ?? ExerciseType.strength;
    _activity = existing?.cardioActivity ?? CardioActivity.run;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Edit exercise' : 'New exercise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<ExerciseType>(
            segments: const [
              ButtonSegment(
                value: ExerciseType.strength,
                label: Text('Strength'),
                icon: Icon(Icons.fitness_center),
              ),
              ButtonSegment(
                value: ExerciseType.cardio,
                label: Text('Cardio'),
                icon: Icon(Icons.directions_run),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (values) =>
                setState(() => _type = values.first),
          ),
          if (_type == ExerciseType.cardio) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<CardioActivity>(
              initialValue: _activity,
              decoration: const InputDecoration(
                labelText: 'Activity',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final a in CardioActivity.values)
                  DropdownMenuItem(value: a, child: Text(a.label)),
              ],
              onChanged: (value) => setState(() => _activity = value),
            ),
          ],
          const SizedBox(height: 12),
          // Keyed so switching the exercise type — which inserts the activity
          // dropdown above — cannot reset a selection the user already made.
          VocabularyField(
            key: const ValueKey('muscleGroup'),
            label: 'Muscle group',
            options: ref.watch(muscleGroupOptionsProvider),
            value: _muscleGroup,
            onChanged: (value) => _muscleGroup = value,
          ),
          const SizedBox(height: 12),
          VocabularyField(
            key: const ValueKey('equipment'),
            label: 'Equipment',
            options: ref.watch(equipmentOptionsProvider),
            value: _equipment,
            onChanged: (value) => _equipment = value,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: Text(isEditing ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the exercise a name');
      return;
    }

    final repo = ref.read(exerciseRepositoryProvider);
    final existing = widget.existing;

    // Names are unique, so catch a collision here rather than letting the
    // database constraint surface as an unreadable error.
    final clash = await repo.findByName(name);
    if (clash != null && clash.id != existing?.id) {
      setState(
        () => _error = 'An exercise called "${clash.name}" already exists',
      );
      return;
    }

    final activity = _type == ExerciseType.cardio ? _activity : null;

    if (existing == null) {
      await repo.create(
        name: name,
        type: _type,
        cardioActivity: activity,
        muscleGroup: _muscleGroup,
        equipment: _equipment,
      );
    } else {
      if (name != existing.name) await repo.rename(existing.id, name);
      await repo.updateDetails(
        existing.id,
        cardioActivity: Value(activity),
        muscleGroup: Value(_muscleGroup),
        equipment: Value(_equipment),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }
}
