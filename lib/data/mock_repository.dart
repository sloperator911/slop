import 'mog_data.dart';

class MockRepository {
  final List<JobPost> _jobs = List.of(mockJobs);
  final List<Application> _applications = List.of(mockApplications);

  List<JobPost> get jobs => List.unmodifiable(_jobs);
  List<Application> get applications => List.unmodifiable(_applications);
}

final mockRepository = MockRepository();
