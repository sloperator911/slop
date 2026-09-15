import 'package:blowjobboard/screens/jobdetails.dart';
import 'package:flutter/material.dart';
import 'package:blowjobboard/widgets/job_card.dart';
import 'package:blowjobboard/data/mog_data.dart';

class JobListPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(8),
      children: mockJobs.map((job) => JobCard(
        title: job.title,
        company: job.company,
        salaryRange: job.salaryRange,
        techStack: job.techStack,
        schedule: job.schedule,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_)=>JobDetails(job: job))
            );
        },
      ),
      ).toList()
    );
  }
}