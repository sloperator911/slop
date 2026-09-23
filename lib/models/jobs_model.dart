import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/mog_data.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:flutter/foundation.dart';

enum JobsStatus { loading, data, error }

class JobsModel extends ChangeNotifier {
  JobsModel(this._repository);

  final JobRepository _repository;

  JobsStatus _status = JobsStatus.loading;
  List<JobPost> _jobs = const [];
  String? _errorMessage;

  JobsStatus get status => _status;
  List<JobPost> get jobs => List.unmodifiable(_jobs);
  String? get errorMessage => _errorMessage;

  JobPost? jobById(int id) {
    for (final job in _jobs) {
      if (job.id == id) return job;
    }
    return null;
  }

  Future<void> loadJobs() async {
    _status = JobsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getJobs();

    switch (result) {
      case Ok(value: final jobs):
        _jobs = List.of(jobs);
        _status = JobsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        _status = JobsStatus.error;
    }

    notifyListeners();
  }
}
