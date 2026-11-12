class JobFilterOptions {
  final List<String> technologies;
  final List<String> schedules;

  const JobFilterOptions({required this.technologies, required this.schedules});

  factory JobFilterOptions.fromJson(Map<String, dynamic> json) =>
      JobFilterOptions(
        technologies: List<String>.from(json['technologies'] as List),
        schedules: List<String>.from(json['schedules'] as List),
      );
}
