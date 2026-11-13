import 'application.dart';
import 'job_filter_options.dart';
import 'job_post.dart';
import 'result.dart';

abstract interface class JobRepository {
  Future<Result<List<JobPost>>> getJobs({
    int page = 1,
    int limit = 20,
    String? search,
    String? technology,
    String? schedule,
  });

  Future<Result<JobPost>> getJob(int id);

  Future<Result<JobFilterOptions>> getJobFilters();

  Future<Result<List<Application>>> getApplications({
    int page = 1,
    int limit = 20,
  });

  Future<Result<String>> uploadCv(String path);

  Future<Result<Application?>> getApplicationForJob(int jobPostId);

  Future<Result<Application>> addApplication({
    required int jobPostId,
    required String cvUrl,
    required String message,
  });
}
