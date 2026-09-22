import 'mog_data.dart';
import 'result.dart';

abstract interface class JobRepository {
  Future<Result<List<JobPost>>> getJobs();

  Future<Result<List<Application>>> getApplications();

  Future<Result<Application>> addApplication({
    required int jobPostId,
    required String cvName,
    required String message,
  });
}
