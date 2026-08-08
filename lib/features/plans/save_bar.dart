import 'package:flutter/material.dart';

/// The commit control for the full-screen editors: a full-width button pinned
/// to the bottom of the screen.
///
/// It lives at the bottom because that is where the bottom sheet these screens
/// replaced put it, and because a form is committed after it has been filled
/// in, not before. As a `bottomNavigationBar` it stays put while the body
/// scrolls, and the keyboard pushes it up rather than covering it.
///
/// There must be exactly one Save per screen — an app bar action *and* one of
/// these gives two things called "Save" that do the same thing.
class SaveBar extends StatelessWidget {
  const SaveBar({required this.onSave, this.label = 'Save', super.key});

  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      // Matches the app bar's surface so the bar reads as chrome rather than as
      // another card in the list.
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onSave, child: Text(label)),
          ),
        ),
      ),
    );
  }
}
