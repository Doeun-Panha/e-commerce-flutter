import 'dart:io';

import 'package:ecommerce/core/navigation/app_router.dart';
import 'package:ecommerce/features/categories/logic/category_provider.dart';
import 'package:ecommerce/features/products/logic/cart_provider.dart';
import 'package:ecommerce/features/products/logic/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/logic/auth_provider.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global=DevHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus(),),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final router = AppRouter.createRouter(authProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}