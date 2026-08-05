import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranav_mechinetest/core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of AppRouter
    final appRouter = AppRouter();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Van Sales App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(),
    );
  }
}
