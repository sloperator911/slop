import 'package:blowjobboard/models/job_details_model.dart';
import 'package:blowjobboard/widgets/job_salary.dart';
import 'package:blowjobboard/widgets/job_sched.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

class JobDetails extends StatelessWidget {
  const JobDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<JobDetailsModel>();
    final job = model.job;

    if (model.status != JobDetailsStatus.data || job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Вакансия')),
        body: Center(
          child: model.status == JobDetailsStatus.loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(model.errorMessage ?? 'Вакансия не найдена'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: model.loadJob,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: !TickerMode.valuesOf(context).enabled
                  ? Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : TextScroll(
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
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.push('/jobs/${job.id}/apply');
            },
            child: Text("Откликнуться"),
          ),
        ],
      ),
    );
  }
}
