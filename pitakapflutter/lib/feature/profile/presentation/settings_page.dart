import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.settingsTitle)),
      body: const Center(child: Text(Strings.settingsTitle)),
    );
  }
}
