import 'package:blowjobboard/data/application.dart';
import 'package:blowjobboard/data/job_repository.dart';
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
  bool _disposed = false;
  static const _limit = 20;
  int _page = 0;
  int _request = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  String? _loadMoreError;

  ApplicationsStatus get status => _status;
  List<Application> get applications => List.unmodifiable(_applications);
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;

  Future<void> loadApplications() async {
    final request = ++_request;
    _status = ApplicationsStatus.loading;
    _errorMessage = null;
    _page = 0;
    _hasMore = false;
    _isLoadingMore = false;
    _loadMoreError = null;
    notifyListeners();

    final result = await _repository.getApplications(limit: _limit);
    if (_disposed || request != _request) return;

    switch (result) {
      case Ok(value: final applications):
        _applications = List.of(applications);
        _page = 1;
        _hasMore = applications.length == _limit;
        _status = ApplicationsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        _status = ApplicationsStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_status != ApplicationsStatus.data || _isLoadingMore || !_hasMore) {
      return;
    }

    final request = _request;
    _isLoadingMore = true;
    _loadMoreError = null;
    final result = await _repository.getApplications(
      page: _page + 1,
      limit: _limit,
    );
    if (_disposed || request != _request) return;

    _isLoadingMore = false;
    switch (result) {
      case Ok(value: final applications):
        _applications = [..._applications, ...applications];
        _page++;
        _hasMore = applications.length == _limit;
      case Err(message: final message):
        _loadMoreError = message;
    }
    notifyListeners();
  }

  Future<void> retryLoadMore() {
    final pending = loadMore();
    notifyListeners();
    return pending;
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
    if (_disposed) return false;

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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
