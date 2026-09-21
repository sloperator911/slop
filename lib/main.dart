import 'package:blowjobboard/data/mog_data.dart';
import 'package:blowjobboard/screens/application_form.dart';
import 'package:blowjobboard/screens/jobdetails.dart';
import 'package:flutter/material.dart';
import 'package:blowjobboard/screens/joblist.dart';
import 'package:blowjobboard/screens/my_applications.dart';
import 'package:blowjobboard/screens/profile.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
}

final router = GoRouter(
  initialLocation: '/jobs',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const JobListPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/applications',
              builder: (context, state) => const MyApplicationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/job',
      builder: (context, state) => JobDetails(job: state.extra! as JobPost),
    ),
    GoRoute(
      path: '/apply',
      builder: (context, state) =>
          ApplicationForm(job: state.extra! as JobPost),
    ),
  ],
);

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

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BlowJobBoard'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: "Вакансии",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Мои отклики",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
        ],
        onTap: (index) {
          navigationShell.goBranch(index);
        },
      ),
      body: navigationShell,
    );
  }
}
