import 'package:blowjobboard/models/applications_model.dart';
import 'package:blowjobboard/models/auth_model.dart';
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
    final auth = context.watch<AuthModel>();
    final user = auth.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null) ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(user.email),
                ],
                if (auth.isLoadingProfile)
                  const Center(child: CircularProgressIndicator()),
                if (auth.errorMessage != null) ...[
                  Text(auth.errorMessage!),
                  TextButton(
                    onPressed: auth.isLoadingProfile ? null : auth.loadProfile,
                    child: const Text('Повторить'),
                  ),
                ],
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
              await auth.logout();
            }
          },
          child: const Text('Выйти'),
        ),
      ],
    );
  }
}
