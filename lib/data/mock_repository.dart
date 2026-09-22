import 'job_repository.dart';
import 'mog_data.dart';
import 'result.dart';

class MockRepository implements JobRepository {
  final List<JobPost> _jobs = List.of(mockJobs);
  final List<Application> _applications = List.of(mockApplications);

  bool simulateError = false;

  List<JobPost> get jobs => List.unmodifiable(_jobs);
  List<Application> get applications => List.unmodifiable(_applications);

  @override
  Future<Result<List<JobPost>>> getJobs() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      return const Err('Не удалось загрузить вакансии');
    }

    return Ok(List.unmodifiable(_jobs));
  }

  @override
  Future<Result<List<Application>>> getApplications() async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      return const Err('Не удалось загрузить отклики');
    }

    return Ok(List.unmodifiable(_applications));
  }

  JobPost? jobById(int id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  @override
  Future<Result<Application>> addApplication({
    required int jobPostId,
    required String cvName,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      return const Err('Не удалось отправить отклик');
    }

    final nextId = _applications.isEmpty ? 1 : _applications.last.id + 1;
    final application = Application(
      id: nextId,
      jobPostId: jobPostId,
      userId: 1,
      cvUrl: cvName,
      message: message,
      status: 'Отправлен',
    );

    _applications.add(application);
    return Ok(application);
  }
}

final mockRepository = MockRepository();
