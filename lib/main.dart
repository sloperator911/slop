import 'dart:async';

import 'package:blowjobboard/data/auth_api.dart';
import 'package:blowjobboard/data/error_simulation.dart';
import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/data/mock_repository.dart';
import 'package:blowjobboard/data/token_store.dart';
import 'package:blowjobboard/models/applications_model.dart';
import 'package:blowjobboard/models/auth_model.dart';
import 'package:blowjobboard/models/jobs_model.dart';
import 'package:blowjobboard/models/network_settings_model.dart';
import 'package:blowjobboard/router.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';

const apiBase = 'http://localhost:8080';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthModel(const AuthApi(apiBase, TokenStore()));
  await auth.restoreSession();
  runApp(
    ChangeNotifierProvider(
      create: (context) => auth,
      child: Consumer<AuthModel>(
        builder: (context, auth, child) =>
            MyApp(key: ValueKey(auth.isAuthenticated), auth: auth),
      ),
    ),
  );
  if (auth.isAuthenticated) unawaited(auth.loadProfile());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.auth});

  final AuthModel auth;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final repository = MockRepository();
  late final router = createRouter(widget.auth);

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<JobRepository>.value(value: repository),
        Provider<ErrorSimulation>.value(value: repository),
        ChangeNotifierProvider(
          create: (context) =>
              JobsModel(context.read<JobRepository>())..loadJobs(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ApplicationsModel(context.read<JobRepository>())
                ..loadApplications(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              NetworkSettingsModel(context.read<ErrorSimulation>()),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) => MaterialApp.router(
          title: 'blowjobboard',
          routerConfig: router,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 127, 61, 61),
                ),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme:
                darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 127, 61, 61),
                  brightness: Brightness.dark,
                ),
          ),
        ),
      ),
    );
  }
}
