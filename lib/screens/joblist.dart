import 'package:flutter/material.dart';
import 'package:blowjobboard/widgets/job_card.dart';
import 'package:blowjobboard/data/mock_repository.dart';
import 'package:go_router/go_router.dart';

class JobListPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: mockRepository.jobs.map((job) => JobCard(
        title: job.title,
        company: job.company,
        salaryRange: job.salaryRange,
        techStack: job.techStack,
        schedule: job.schedule,
        onTap: () {
          context.push('/job', extra: job);
        },
      ),
      ).toList()
    );
  }
}
