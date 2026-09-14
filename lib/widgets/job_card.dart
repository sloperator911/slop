import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,

    required this.title,
    required this.company,
    required this.salaryRange,
    required this.techStack,
    required this.schedule,

    required this.onTap,
  });

  final String title;
  final String company;
  final String salaryRange;
  final List<String> techStack;
  final String schedule;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title)),
                  SizedBox(width: 8),
                  Text(company),
                ],
              ),
              SizedBox(height: 8),
              Text(salaryRange),
              Wrap(
                spacing: 8,
                children: techStack
                    .map((technology) => Chip(label: Text(technology)))
                    .toList(),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(width: 8),
                  Text(schedule),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
