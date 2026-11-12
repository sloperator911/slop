import 'package:blowjobboard/data/job_filter_options.dart';
import 'package:blowjobboard/data/job_post.dart';
import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/result.dart';
import 'package:flutter/foundation.dart';

enum JobsStatus { loading, data, error }

class JobsModel extends ChangeNotifier {
  JobsModel(this._repository);

  final JobRepository _repository;

  JobsStatus _status = JobsStatus.loading;
  List<JobPost> _jobs = const [];
  String? _errorMessage;
  bool _disposed = false;
  static const _limit = 20;
  int _page = 0;
  int _request = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;
  String? _loadMoreError;
  String _search = '';
  String _technology = '';
  String _schedule = '';
  JobFilterOptions _filters = const JobFilterOptions(
    technologies: [],
    schedules: [],
  );
  bool _isLoadingFilters = false;
  String? _filtersErrorMessage;

  JobsStatus get status => _status;
  List<JobPost> get jobs => List.unmodifiable(_jobs);
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get loadMoreError => _loadMoreError;
  String get search => _search;
  String get technology => _technology;
  String get schedule => _schedule;
  bool get isLoadingFilters => _isLoadingFilters;
  String? get filtersErrorMessage => _filtersErrorMessage;
  List<String> get technologies => {
    ..._filters.technologies,
    if (_technology.isNotEmpty) _technology,
  }.toList()..sort();
  List<String> get schedules =>
      {..._filters.schedules, if (_schedule.isNotEmpty) _schedule}.toList()
        ..sort();

  Future<void> loadJobs({
    String? search,
    String? technology,
    String? schedule,
  }) async {
    _search = search?.trim() ?? _search;
    _technology = technology ?? _technology;
    _schedule = schedule ?? _schedule;
    final request = ++_request;
    _status = JobsStatus.loading;
    _errorMessage = null;
    _page = 0;
    _hasMore = false;
    _isLoadingMore = false;
    _loadMoreError = null;
    notifyListeners();

    final result = await _repository.getJobs(
      limit: _limit,
      search: _search,
      technology: _technology,
      schedule: _schedule,
    );
    if (_disposed || request != _request) return;

    switch (result) {
      case Ok(value: final jobs):
        _jobs = List.of(jobs);
        _page = 1;
        _hasMore = jobs.length == _limit;
        _status = JobsStatus.data;
      case Err(message: final message):
        _errorMessage = message;
        _status = JobsStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_status != JobsStatus.data || _isLoadingMore || !_hasMore) return;

    final request = _request;
    _isLoadingMore = true;
    _loadMoreError = null;
    // The list tail calls this during build; notify only after the request.
    final result = await _repository.getJobs(
      page: _page + 1,
      limit: _limit,
      search: _search,
      technology: _technology,
      schedule: _schedule,
    );
    if (_disposed || request != _request) return;

    _isLoadingMore = false;
    switch (result) {
      case Ok(value: final jobs):
        _jobs = [..._jobs, ...jobs];
        _page++;
        _hasMore = jobs.length == _limit;
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

  Future<void> loadFilters() async {
    if (_isLoadingFilters) return;

    _isLoadingFilters = true;
    _filtersErrorMessage = null;
    notifyListeners();

    final result = await _repository.getJobFilters();
    if (_disposed) return;

    _isLoadingFilters = false;
    switch (result) {
      case Ok(value: final filters):
        _filters = filters;
      case Err(message: final message):
        _filtersErrorMessage = message;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
