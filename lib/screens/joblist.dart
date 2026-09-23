import 'package:blowjobboard/models/jobs_model.dart';
import 'package:flutter/material.dart';
import 'package:blowjobboard/widgets/job_card.dart';
import 'package:blowjobboard/widgets/job_filters.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  String searchQuery = '';
  String selectedTechnology = '';
  String selectedSchedule = '';

  @override
  Widget build(BuildContext context) {
    final jobsModel = context.watch<JobsModel>();

    if (jobsModel.status == JobsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobsModel.status == JobsStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(jobsModel.errorMessage ?? 'Неизвестная ошибка'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: jobsModel.loadJobs,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    final jobs = jobsModel.jobs;
    final technologies = jobs.expand((job) => job.techStack).toSet().toList()
      ..sort();
    final schedules = jobs.map((job) => job.schedule).toSet().toList()..sort();

    final filteredJobs = jobs.where((job) {
      final query = searchQuery.trim().toLowerCase();
      final matchesSearch =
          job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query);
      final matchesTechnology =
          selectedTechnology.isEmpty ||
          job.techStack.contains(selectedTechnology);
      final matchesSchedule =
          selectedSchedule.isEmpty || job.schedule == selectedSchedule;

      return matchesSearch && matchesTechnology && matchesSchedule;
    });

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        JobFilters(
          technologies: technologies,
          schedules: schedules,
          selectedTechnology: selectedTechnology,
          selectedSchedule: selectedSchedule,
          onSearchChanged: (value) {
            setState(() => searchQuery = value);
          },
          onTechnologyChanged: (value) {
            setState(() => selectedTechnology = value);
          },
          onScheduleChanged: (value) {
            setState(() => selectedSchedule = value);
          },
        ),
        for (final job in filteredJobs)
          JobCard(
            title: job.title,
            company: job.company,
            salaryRange: job.salaryRange,
            techStack: job.techStack,
            schedule: job.schedule,
            onTap: () {
              context.push('/jobs/${job.id}');
            },
          ),
        if (filteredJobs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Вакансий не найдено')),
          ),
      ],
    );
  }
}
