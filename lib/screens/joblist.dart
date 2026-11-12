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
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsModel = context.watch<JobsModel>();

    final jobs = jobsModel.jobs;
    final showJobs = jobsModel.status == JobsStatus.data && jobs.isNotEmpty;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: showJobs ? 1 + jobs.length + (jobsModel.hasMore ? 1 : 0) : 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              JobFilters(
                technologies: jobsModel.technologies,
                schedules: jobsModel.schedules,
                selectedTechnology: jobsModel.technology,
                selectedSchedule: jobsModel.schedule,
                searchController: searchController,
                onSearchSubmitted: (value) => jobsModel.loadJobs(search: value),
                onTechnologyChanged: (value) =>
                    jobsModel.loadJobs(technology: value),
                onScheduleChanged: (value) =>
                    jobsModel.loadJobs(schedule: value),
              ),
              if (jobsModel.isLoadingFilters) const LinearProgressIndicator(),
              if (jobsModel.filtersErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(jobsModel.filtersErrorMessage!),
                      TextButton(
                        onPressed: jobsModel.loadFilters,
                        child: const Text('Повторить загрузку фильтров'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
        if (jobsModel.status == JobsStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (jobsModel.status == JobsStatus.error) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
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
        if (jobs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('Вакансий не найдено')),
          );
        }
        if (index == jobs.length + 1) {
          final error = jobsModel.loadMoreError;
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(error),
                  TextButton(
                    onPressed: jobsModel.retryLoadMore,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          jobsModel.loadMore();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final job = jobs[index - 1];
        return JobCard(
          title: job.title,
          company: job.company,
          salaryRange: job.salaryRange,
          techStack: job.techStack,
          schedule: job.schedule,
          onTap: () {
            context.push('/jobs/${job.id}');
          },
        );
      },
    );
  }
}
