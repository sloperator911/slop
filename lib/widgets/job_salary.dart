import 'package:flutter/material.dart';

class JobSalary extends StatelessWidget {
  const JobSalary({
    super.key,
    required this.salaryRange
  });

  final String salaryRange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.money),
        SizedBox(width: 8,),
        Text(salaryRange)
      ],
      );
  }
}