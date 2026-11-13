import 'package:blowjobboard/models/applications_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final applicationsModel = context.watch<ApplicationsModel>();

    return RefreshIndicator(
      onRefresh: () async {
        await applicationsModel.loadApplications(refresh: true);
        if (!context.mounted) return;
        final error = applicationsModel.errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      },
      child: _buildList(context, applicationsModel),
    );
  }

  Widget _buildList(BuildContext context, ApplicationsModel applicationsModel) {
    if (applicationsModel.status == ApplicationsStatus.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (applicationsModel.status == ApplicationsStatus.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(applicationsModel.errorMessage ?? 'Неизвестная ошибка'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: applicationsModel.loadApplications,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    final applications = applicationsModel.applications;

    if (applications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [Center(child: Text('Откликов пока нет'))],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: applications.length + (applicationsModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == applications.length) {
          final error = applicationsModel.loadMoreError;
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(error),
                  TextButton(
                    onPressed: applicationsModel.retryLoadMore,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          applicationsModel.loadMore();
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final application = applications[index];
        return Card(
          child: InkWell(
            onTap: application.jobDeleted
                ? null
                : () => context.push('/jobs/${application.jobPostId}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(application.company),
                  if (application.jobDeleted) ...[
                    const SizedBox(height: 8),
                    const Text('Вакансия удалена'),
                  ],
                  const SizedBox(height: 8),
                  Text('Статус: ${application.status}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
