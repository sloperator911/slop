class JobPost {
  final int id;
  final String title;
  final String company;
  final String salaryRange;
  final List<String> techStack;
  final String schedule;
  final String requirements;
  final String description;

  const JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.salaryRange,
    required this.techStack,
    required this.schedule,
    required this.requirements,
    required this.description,
  });

  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost(
    id: json['id'] as int,
    title: json['title'] as String,
    company: json['company'] as String,
    salaryRange: json['salaryRange'] as String,
    techStack: List<String>.from(json['techStack'] as List),
    schedule: json['schedule'] as String,
    requirements: json['requirements'] as String,
    description: json['description'] as String,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'company': company,
    'salaryRange': salaryRange,
    'techStack': techStack,
    'schedule': schedule,
    'requirements': requirements,
    'description': description,
  };
}
