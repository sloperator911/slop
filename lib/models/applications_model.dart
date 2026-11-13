import 'dart:async';

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
  bool _isRefreshing = false;

  ApplicationsStatus get status => _status;
  List<Application> get applications => List.unmodifiable(_applications);
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;

  Future<void> loadApplications({bool refresh = false}) async {
    if (refresh && _isRefreshing) return;

    final keepData = refresh && _status == ApplicationsStatus.data;
    final request = ++_request;
    _isRefreshing = refresh;
    if (!keepData) _status = ApplicationsStatus.loading;
    _errorMessage = null;
    if (!keepData) {
      _page = 0;
      _hasMore = false;
    }
    _isLoadingMore = false;
    _loadMoreError = null;
    notifyListeners();

    final result = await _repository.getApplications(limit: _limit);
    if (_disposed || request != _request) return;

    _isRefreshing = false;
    switch (result) {
      case Ok(value: final applications):
        _applications = List.of(applications);
        _page = 1;
        _hasMore = applications.length == _limit;
        _status = ApplicationsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        if (!keepData) _status = ApplicationsStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_status != ApplicationsStatus.data ||
        _isLoadingMore ||
        _isRefreshing ||
        !_hasMore) {
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
        final byId = {
          for (final application in [..._applications, ...applications])
            application.id: application,
        };
        _applications = byId.values.toList();
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

  Future<Result<Application?>> findApplication(int jobPostId) =>
      _repository.getApplicationForJob(jobPostId);

  Future<Application?> addApplication({
    required int jobPostId,
    required String cvPath,
    required String message,
  }) async {
    if (_isSubmitting) return null;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final upload = await _repository.uploadCv(cvPath);
    if (_disposed) return null;

    final String cvUrl;
    switch (upload) {
      case Ok(value: final url):
        cvUrl = url;
      case Err(message: final message):
        _isSubmitting = false;
        _errorMessage = message;
        notifyListeners();
        return null;
    }

    final result = await _repository.addApplication(
      jobPostId: jobPostId,
      cvUrl: cvUrl,
      message: message,
    );
    if (_disposed) return null;

    _isSubmitting = false;

    switch (result) {
      case Ok(value: final application):
        _request++;
        _isRefreshing = false;
        _isLoadingMore = false;
        _loadMoreError = null;
        _applications = [
          application,
          ..._applications.where((item) => item.id != application.id),
        ];
        _applications.sort((a, b) => b.id.compareTo(a.id));
        _status = ApplicationsStatus.data;
        notifyListeners();
        unawaited(loadApplications(refresh: true));
        return application;
      case Err(message: final message):
        _errorMessage = message;
        notifyListeners();
        return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
