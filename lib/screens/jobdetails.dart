import 'package:blowjobboard/data/mog_data.dart';
import 'package:blowjobboard/widgets/job_salary.dart';
import 'package:blowjobboard/widgets/job_sched.dart';
import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

class JobDetails extends StatelessWidget {
  final JobPost job;

  const JobDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextScroll(
                job.title,
                mode: TextScrollMode.endless,
                pauseBetween: Duration(seconds: 1),
              ),
            ),
            const SizedBox(width: 8),
            Text(job.company),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Описание вакансии',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(job.description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Требования',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(job.requirements),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Технологии',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.techStack
                        .map((technology) => Chip(label: Text(technology)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Условия',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  JobSchedule(schedule: job.schedule),
                  const SizedBox(height: 8),
                  JobSalary(salaryRange: job.salaryRange),
                ],
              ),
            ),
          ),
          FilledButton(onPressed: () {}, child: Text("Откликнутся")),
        ],
      ),
    );
  }
}
