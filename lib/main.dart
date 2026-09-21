import 'package:blowjobboard/router.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
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
