import 'package:blowjobboard/models/applications_model.dart';
import 'package:blowjobboard/models/jobs_model.dart';
import 'package:blowjobboard/models/network_settings_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final networkSettings = context.watch<NetworkSettingsModel>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Алексей',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('alex@example.com'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Симулировать сбой сети'),
            value: networkSettings.simulateError,
            onChanged: (value) {
              networkSettings.setSimulateError(value);

              if (value) {
                context.read<JobsModel>().loadJobs();
                context.read<ApplicationsModel>().loadApplications();
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выйти из аккаунта?'),
                content: const Text('Вы уверены, что хотите выйти?'),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => context.pop(true),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            );

            if (confirmed == true && context.mounted) {
              context.go('/login');
            }
          },
          child: const Text('Выйти'),
        ),
      ],
    );
  }
}
