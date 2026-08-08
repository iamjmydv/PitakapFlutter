import 'package:flutter/material.dart';
import 'package:pitakapflutter/core/resources/strings.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.dashboardTitle)),
      body: const Center(child: Text(Strings.dashboardTitle)),
    );
  }
}
