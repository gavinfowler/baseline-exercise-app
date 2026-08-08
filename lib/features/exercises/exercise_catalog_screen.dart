import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/models/enums.dart';
import '../shell/app_drawer.dart';
import 'exercise_editor_sheet.dart';

/// Browse, search, filter, add and archive exercises of a single [type].
///
/// Strength and cardio get a destination each rather than one list with a type
/// filter: the two have almost nothing in common to narrow by — a run has no
/// muscle group, a bench press has no activity — so a shared screen could only
/// ever offer the union and grey half of it out.
class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({required this.type, super.key});

  final ExerciseType type;

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen> {
  String _search = '';
  CardioActivity? _activity;
  String? _muscleGroup;
  String? _equipment;
  bool _includeArchived = false;

  bool get _isCardio => widget.type == ExerciseType.cardio;

  /// Everything except the name, which is matched in Dart against several
  /// fields at once and so cannot be pushed into the query.
  ExerciseFilter get _filter => (
    type: widget.type,
    cardioActivity: _activity,
    muscleGroup: _muscleGroup,
    equipment: _equipment,
    includeArchived: _includeArchived,
  );

  bool get _hasNarrowing =>
      _activity != null ||
      _muscleGroup != null ||
      _equipment != null ||
      _includeArchived ||
      _search.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(exerciseCatalogProvider(_filter));

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_isCardio ? 'Cardio' : 'Strength'),
        actions: [
          if (_hasNarrowing)
            TextButton(onPressed: _clearFilters, child: const Text('Clear')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // The shell keeps every tab mounted in an IndexedStack, so the tabs'
        // buttons share one Hero subtree and cannot use the default tag. Both
        // catalog screens are mounted at once, hence the type in the tag.
        heroTag: 'exercises-fab-${widget.type.wireName}',
        onPressed: () =>
            showExerciseEditor(context, ref, initialType: widget.type),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _search = value),
            ),
          ),
          _FilterBar(
            type: widget.type,
            activity: _activity,
            muscleGroup: _muscleGroup,
            equipment: _equipment,
            includeArchived: _includeArchived,
            onActivityChanged: (value) => setState(() => _activity = value),
            onMuscleGroupChanged: (value) =>
                setState(() => _muscleGroup = value),
            onEquipmentChanged: (value) => setState(() => _equipment = value),
            onArchivedChanged: (value) =>
                setState(() => _includeArchived = value),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (rows) {
                final filtered = _applySearch(rows);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _hasNarrowing
                            ? 'Nothing matches these filters.'
                            : _isCardio
                            ? 'No cardio exercises yet.'
                            : 'No strength exercises yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _ExerciseTile(exercise: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() => setState(() {
    _search = '';
    _activity = null;
    _muscleGroup = null;
    _equipment = null;
    _includeArchived = false;
  });

  /// Name search only. Muscle group and equipment are filters of their own now,
  /// so folding them into the text match would make "Barbell" return every
  /// barbell exercise even when the user filtered to dumbbells.
  List<ExerciseRow> _applySearch(List<ExerciseRow> rows) {
    final needle = _search.trim().toLowerCase();
    if (needle.isEmpty) return rows;
    return rows.where((e) => e.nameKey.contains(needle)).toList();
  }
}

/// The narrowing controls, which differ by type: cardio narrows by activity,
/// strength by muscle group. Equipment applies to both.
class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.type,
    required this.activity,
    required this.muscleGroup,
    required this.equipment,
    required this.includeArchived,
    required this.onActivityChanged,
    required this.onMuscleGroupChanged,
    required this.onEquipmentChanged,
    required this.onArchivedChanged,
  });

  final ExerciseType type;
  final CardioActivity? activity;
  final String? muscleGroup;
  final String? equipment;
  final bool includeArchived;
  final ValueChanged<CardioActivity?> onActivityChanged;
  final ValueChanged<String?> onMuscleGroupChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final ValueChanged<bool> onArchivedChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCardio = type == ExerciseType.cardio;
    final equipmentOptions = ref.watch(usedEquipmentProvider(type));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              avatar: const Icon(Icons.archive_outlined, size: 18),
              label: const Text('Archived'),
              selected: includeArchived,
              onSelected: onArchivedChanged,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: isCardio
                    ? _FilterDropdown<CardioActivity>(
                        label: 'Activity',
                        value: activity,
                        options: ref.watch(usedCardioActivitiesProvider),
                        labelOf: (a) => a.label,
                        onChanged: onActivityChanged,
                      )
                    : _FilterDropdown<String>(
                        label: 'Muscle group',
                        value: muscleGroup,
                        options: ref.watch(usedMuscleGroupsProvider(type)),
                        labelOf: (value) => value,
                        onChanged: onMuscleGroupChanged,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FilterDropdown<String>(
                  label: 'Equipment',
                  value: equipment,
                  options: equipmentOptions,
                  labelOf: (value) => value,
                  onChanged: onEquipmentChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A nullable dropdown whose null entry reads as "Any".
///
/// Options come from the catalog rather than the standard vocabulary, so the
/// filter can never offer a choice that returns an empty list.
class _FilterDropdown<T extends Object> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    // A stale selection would otherwise assert: archiving the last barbell
    // exercise can remove "Barbell" from the options while it is still chosen.
    final selected = options.contains(value) ? value : null;

    return DropdownButtonFormField<T?>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(child: Text('Any')),
        for (final option in options)
          DropdownMenuItem(value: option, child: Text(labelOf(option))),
      ],
      onChanged: options.isEmpty ? null : onChanged,
    );
  }
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({required this.exercise});

  final ExerciseRow exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = exercise.isArchived;
    final subtitle = [
      if (exercise.type == ExerciseType.cardio)
        exercise.cardioActivity?.label ?? 'Cardio',
      if (exercise.muscleGroup != null) exercise.muscleGroup!,
      if (exercise.equipment != null) exercise.equipment!,
    ].join(' · ');

    return ListTile(
      leading: Icon(
        exercise.type == ExerciseType.cardio
            ? Icons.directions_run
            : Icons.fitness_center,
        color: archived ? Theme.of(context).disabledColor : null,
      ),
      title: Row(
        children: [
          Flexible(child: Text(exercise.name)),
          if (archived) ...[
            const SizedBox(width: 8),
            const Chip(
              label: Text('Archived'),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () => showExerciseEditor(context, ref, existing: exercise),
      trailing: archived
          ? IconButton(
              tooltip: 'Restore',
              icon: const Icon(Icons.unarchive_outlined),
              onPressed: () => ref
                  .read(exerciseRepositoryProvider)
                  .setArchived(exercise.id, archived: false),
            )
          : IconButton(
              tooltip: 'Archive',
              icon: const Icon(Icons.archive_outlined),
              onPressed: () => _archive(context, ref),
            ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(exerciseRepositoryProvider);
    await repo.setArchived(exercise.id, archived: true);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Archived ${exercise.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.setArchived(exercise.id, archived: false),
        ),
      ),
    );
  }
}
