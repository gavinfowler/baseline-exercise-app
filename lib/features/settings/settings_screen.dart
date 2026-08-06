import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/units/unit_system.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/backup/backup_service.dart';
import '../ads/ad_slot.dart';

/// Units, rest defaults, alerts, and the backup controls.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitSystemProvider).value ?? UnitSystem.metric;
    final rest = ref.watch(defaultRestSecondsProvider).value;
    final settings = ref.watch(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const _SectionHeader('Units'),
                RadioGroup<UnitSystem>(
                  groupValue: units,
                  onChanged: (value) async {
                    if (value == null) return;
                    await settings.setUnitSystem(value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<UnitSystem>(
                        value: UnitSystem.metric,
                        title: Text('Metric'),
                        subtitle: Text('kilograms, kilometres'),
                      ),
                      RadioListTile<UnitSystem>(
                        value: UnitSystem.imperial,
                        title: Text('Imperial'),
                        subtitle: Text('pounds, miles'),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Everything is stored in metric and converted for display, '
                    'so switching never changes your recorded data.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                const Divider(),
                const _SectionHeader('Rest timer'),
                ListTile(
                  title: const Text('Default rest between sets'),
                  subtitle: Text(
                    rest == null ? '—' : UnitFormatter.formatDuration(rest),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editRest(context, ref, rest ?? 90),
                ),
                const _FlagTile(
                  label: 'Sound',
                  settingKey: SettingsRepository.keyRestSoundEnabled,
                ),
                const _FlagTile(
                  label: 'Vibration',
                  settingKey: SettingsRepository.keyRestVibrationEnabled,
                ),
                const _FlagTile(
                  label: 'Notification when the app is in the background',
                  settingKey: SettingsRepository.keyRestNotificationEnabled,
                ),

                const Divider(),
                const _SectionHeader('Backup'),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Your data lives only on this device. Export a backup file '
                    'and keep it somewhere safe — it is the only way to recover '
                    'if the device is lost or wiped.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('Export backup'),
                  subtitle: const Text('Writes everything to a JSON file'),
                  onTap: () => _export(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore from backup'),
                  subtitle: const Text('Replaces everything on this device'),
                  onTap: () => _restore(context, ref),
                ),

                const Divider(),
                const _SectionHeader('About'),
                const ListTile(
                  leading: Icon(Icons.wifi_off),
                  title: Text('Works entirely offline'),
                  subtitle: Text(
                    'No account, no sync, and no network access. There are no '
                    'ads and no tracking.',
                  ),
                ),
              ],
            ),
          ),
          const AdSlot(),
        ],
      ),
    );
  }

  Future<void> _editRest(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final controller = TextEditingController(text: current.toString());

    final seconds = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default rest'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Seconds',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (seconds == null || seconds < 0) return;
    await ref.read(settingsRepositoryProvider).setDefaultRestSeconds(seconds);
    ref.invalidate(defaultRestSecondsProvider);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final json = await ref.read(backupServiceProvider).exportToJson();
    final suggested =
        'exercise-backup-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';

    final location = await getSaveLocation(suggestedName: suggested);
    if (location == null || !context.mounted) return;

    await File(location.path).writeAsString(json);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Backup written to ${location.path}')),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    const typeGroup = XTypeGroup(label: 'Backups', extensions: ['json']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null || !context.mounted) return;

    // Restoring is destructive, so it is confirmed explicitly rather than
    // happening the moment a file is chosen.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace all data?'),
        content: Text(
          'Everything currently on this device — workouts, plans, history — '
          'is replaced with the contents of ${file.name}. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final source = await File(file.path).readAsString();
      final summary = await ref
          .read(backupServiceProvider)
          .restoreFromJson(source);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Restored ${summary.sessions} sessions, ${summary.plans} plans '
            'and ${summary.exercises} exercises.',
          ),
        ),
      );
    } on BackupFormatException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } on FileSystemException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read the file: ${e.message}')),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _FlagTile extends ConsumerWidget {
  const _FlagTile({required this.label, required this.settingKey});

  final String label;
  final String settingKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(settingFlagProvider(settingKey));

    return SwitchListTile(
      title: Text(label),
      value: value.value ?? true,
      onChanged: (enabled) => ref
          .read(settingsRepositoryProvider)
          .setFlag(settingKey, value: enabled),
    );
  }
}
