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
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'BlowJobBoard'),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  final pages = [JobListPage(), MyApplicationsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Мои отклики",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Мой профиль",
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: pages[selectedIndex],
    );
  }
}
