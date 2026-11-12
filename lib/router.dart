import 'package:blowjobboard/data/job_repository.dart';
import 'package:blowjobboard/models/auth_model.dart';
import 'package:blowjobboard/models/job_details_model.dart';
import 'package:blowjobboard/screens/application_form.dart';
import 'package:blowjobboard/screens/auth.dart';
import 'package:blowjobboard/screens/jobdetails.dart';
import 'package:blowjobboard/screens/joblist.dart';
import 'package:blowjobboard/screens/my_applications.dart';
import 'package:blowjobboard/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter createRouter(AuthModel auth) => GoRouter(
  initialLocation: auth.isAuthenticated ? '/jobs' : '/login',
  refreshListenable: auth,
  redirect: (context, state) {
    final atLogin = state.uri.path == '/login';
    if (!auth.isAuthenticated && !atLogin) return '/login';
    if (auth.isAuthenticated && atLogin) return '/jobs';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(
        navigationShell: navigationShell,
        showAppBar:
            state.uri.path == '/jobs' ||
            state.uri.path == '/applications' ||
            state.uri.path == '/profile',
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const JobListPage(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ChangeNotifierProvider(
                    key: ValueKey(state.pathParameters['id']),
                    create: (context) => JobDetailsModel(
                      context.read<JobRepository>(),
                      int.tryParse(state.pathParameters['id']!) ?? -1,
                    )..loadJob(),
                    child: const JobDetails(),
                  ),
                  routes: [
                    GoRoute(
                      path: 'apply',
                      builder: (context, state) => ChangeNotifierProvider(
                        key: ValueKey(state.pathParameters['id']),
                        create: (context) => JobDetailsModel(
                          context.read<JobRepository>(),
                          int.tryParse(state.pathParameters['id']!) ?? -1,
                        )..loadJob(),
                        child: const ApplicationForm(),
                      ),
                    ),
                  ],
                ),
              ],
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
  ],
);

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    required this.showAppBar,
  });

  final StatefulNavigationShell navigationShell;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('BlowJobBoard'),
            )
          : null,
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
