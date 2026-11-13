import 'package:blowjobboard/data/application.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:blowjobboard/models/applications_model.dart';
import 'package:blowjobboard/models/job_details_model.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:text_scroll/text_scroll.dart';

const cvType = XTypeGroup(label: "PDF", extensions: ["pdf"]);

class ApplicationForm extends StatefulWidget {
  const ApplicationForm({super.key});

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  final formKey = GlobalKey<FormState>();
  XFile? selectedCv;
  String message = '';
  int? jobId;
  late Future<Result<Application?>> existingApplication;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = context.read<JobDetailsModel>().jobId;
    if (jobId == id) return;
    jobId = id;
    existingApplication = context.read<ApplicationsModel>().findApplication(id);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<JobDetailsModel>();
    final applicationsModel = context.watch<ApplicationsModel>();

    return FutureBuilder<Result<Application?>>(
      future: existingApplication,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Отклик')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        switch (snapshot.data!) {
          case Ok(value: final application):
            if (application != null) return _buildApplication(application);
            return _buildForm(model, applicationsModel);
          case Err(message: final error):
            return Scaffold(
              appBar: AppBar(title: const Text('Отклик')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(error),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        existingApplication = applicationsModel.findApplication(
                          jobId!,
                        );
                      }),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }

  Widget _buildApplication(Application application) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ваш отклик')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${application.jobTitle} @ ${application.company}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Вы уже откликнулись на эту вакансию'),
                  if (application.jobDeleted) ...[
                    const SizedBox(height: 8),
                    const Text('Вакансия удалена'),
                  ],
                  const SizedBox(height: 8),
                  Text('Статус: ${application.status}'),
                  const SizedBox(height: 16),
                  const Text('Сопроводительное письмо'),
                  const SizedBox(height: 8),
                  Text(application.message),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.attach_file),
                      SizedBox(width: 8),
                      Text('CV прикреплён'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/applications'),
            child: const Text('Мои отклики'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(
    JobDetailsModel model,
    ApplicationsModel applicationsModel,
  ) {
    final job = model.job;
    if (model.status != JobDetailsStatus.data || job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отклик')),
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
            Text(": Отклик"),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${job.title} @ ${job.company}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("Приложите ваш CV"),
                    SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: applicationsModel.isSubmitting
                          ? null
                          : () async {
                              final file = await openFile(
                                acceptedTypeGroups: [cvType],
                              );
                              if (file == null || !mounted) return;

                              setState(() {
                                selectedCv = file;
                              });
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.attach_file),
                          Flexible(
                            child: Text(
                              selectedCv?.name ?? "Выбрать файл",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("...и добавьте короткое сообщение работодателю"),
                    SizedBox(height: 16),
                    TextFormField(
                      enabled: !applicationsModel.isSubmitting,
                      onChanged: (value) {
                        message = value;
                      },
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return 'Минимум 10 символов';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hint: Opacity(
                          opacity: 0.5,
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              Text("Максимум 300 символов"),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      minLines: 5,
                      maxLines: 5,
                      maxLength: 300,
                    ),
                    SizedBox(height: 16),
                    FilledButton(
                      onPressed: applicationsModel.isSubmitting
                          ? null
                          : () async {
                              final cv = selectedCv;
                              if (cv == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("CV не выбран")),
                                );
                                return;
                              }

                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final messenger = ScaffoldMessenger.of(context);
                              final application = await applicationsModel
                                  .addApplication(
                                    jobPostId: job.id,
                                    cvPath: cv.path,
                                    message: message.trim(),
                                  );

                              if (!context.mounted) return;

                              if (application != null) {
                                setState(() {
                                  existingApplication = Future.value(
                                    Ok(application),
                                  );
                                });
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      applicationsModel.errorMessage ??
                                          'Не удалось отправить отклик',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          Text(
                            applicationsModel.isSubmitting
                                ? "Отправка..."
                                : "Отправить",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
