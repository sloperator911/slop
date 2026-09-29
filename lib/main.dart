import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/mock_repository.dart';
import 'package:blowjobboard/models/applications_model.dart';
import 'package:blowjobboard/models/jobs_model.dart';
import 'package:blowjobboard/router.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

void main() {
  final repository = MockRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<JobRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (context) =>
              JobsModel(context.read<JobRepository>())..loadJobs(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ApplicationsModel(context.read<JobRepository>())
                ..loadApplications(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'blowjobboard',
        routerConfig: router,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ??
              ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 127, 61, 61),
              ),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ??
              ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 127, 61, 61),
                brightness: Brightness.dark,
              ),
        ),
      ),
    );
  }
}
