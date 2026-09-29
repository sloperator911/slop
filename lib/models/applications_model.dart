import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/mog_data.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:flutter/foundation.dart';

enum ApplicationsStatus { loading, data, error }

class ApplicationsModel extends ChangeNotifier {
  ApplicationsModel(this._repository);

  final JobRepository _repository;

  ApplicationsStatus _status = ApplicationsStatus.loading;
  List<Application> _applications = const [];
  String? _errorMessage;
  bool _isSubmitting = false;

  ApplicationsStatus get status => _status;
  List<Application> get applications => List.unmodifiable(_applications);
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  Future<void> loadApplications() async {
    _status = ApplicationsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getApplications();

    switch (result) {
      case Ok(value: final applications):
        _applications = List.of(applications);
        _status = ApplicationsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        _status = ApplicationsStatus.error;
    }

    notifyListeners();
  }

  Future<bool> addApplication({
    required int jobPostId,
    required String cvName,
    required String message,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.addApplication(
      jobPostId: jobPostId,
      cvName: cvName,
      message: message,
    );

    _isSubmitting = false;

    switch (result) {
      case Ok(value: final application):
        _applications = [..._applications, application];
        _status = ApplicationsStatus.data;
        notifyListeners();
        return true;
      case Err(message: final message):
        _errorMessage = message;
        notifyListeners();
        return false;
    }
  }
}
