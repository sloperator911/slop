import 'package:blowjobboard/data/mock_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = {for (final job in mockRepository.jobs) job.id: job};
    final applications = mockRepository.applications;

    if (applications.isEmpty) {
      return const Center(child: Text('Откликов пока нет'));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final application in applications)
          Card(
            child: InkWell(
              onTap: jobs.containsKey(application.jobPostId)
                  ? () => context.push('/jobs/${application.jobPostId}')
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobs[application.jobPostId]?.title ??
                          'Вакансия #${application.jobPostId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (jobs[application.jobPostId] != null) ...[
                      const SizedBox(height: 4),
                      Text(jobs[application.jobPostId]!.company),
                    ],
                    const SizedBox(height: 8),
                    Text('Статус: ${application.status}'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
