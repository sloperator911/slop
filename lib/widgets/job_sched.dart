import 'package:flutter/material.dart';

class JobSchedule extends StatelessWidget {
  const JobSchedule({super.key, required this.schedule});
  final String schedule;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.calendar_month),
        SizedBox(width: 8),
        Text(schedule),
      ],
    );
  }
}
