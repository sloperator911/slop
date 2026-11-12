import 'package:blowjobboard/data/job_post.dart';
import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:flutter/foundation.dart';

enum JobDetailsStatus { loading, data, error }

class JobDetailsModel extends ChangeNotifier {
  JobDetailsModel(this._repository, this._jobId);

  final JobRepository _repository;
  final int _jobId;

  JobDetailsStatus _status = JobDetailsStatus.loading;
  JobPost? _job;
  String? _errorMessage;
  bool _disposed = false;

  JobDetailsStatus get status => _status;
  JobPost? get job => _job;
  String? get errorMessage => _errorMessage;

  Future<void> loadJob() async {
    _status = JobDetailsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getJob(_jobId);
    if (_disposed) return;

    switch (result) {
      case Ok(value: final job):
        _job = job;
        _status = JobDetailsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        _status = JobDetailsStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
