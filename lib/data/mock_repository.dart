import 'mog_data.dart';

class MockRepository {
  final List<JobPost> _jobs = List.of(mockJobs);
  final List<Application> _applications = List.of(mockApplications);

  List<JobPost> get jobs => List.unmodifiable(_jobs);
  List<Application> get applications => List.unmodifiable(_applications);

  JobPost? jobById(int id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  void addApplication({
    required int jobPostId,
    required String cvName,
    required String message,
  }) {
    final nextId = _applications.isEmpty ? 1 : _applications.last.id + 1;

    _applications.add(Application(
      id: nextId,
      jobPostId: jobPostId,
      userId: 1,
      cvUrl: cvName,
      message: message,
      status: 'Отправлен',
    ));
  }
}

final mockRepository = MockRepository();
