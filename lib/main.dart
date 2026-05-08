import 'dart:io';

import 'package:ecommerce/features/categories/logic/category_provider.dart';
import 'package:ecommerce/features/products/logic/cart_provider.dart';
import 'package:ecommerce/features/products/logic/product_provider.dart';
import 'package:ecommerce/features/products/presentation/admin/admin_dashboard_screen.dart';
import 'package:ecommerce/features/products/presentation/user/start_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/products/presentation/user/user_storefront_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-commerce Admin',
      theme: AppTheme.lightTheme,
      home:Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isAuthenticated) {
            return const StartUpScreen();
          }
          return auth.isAdmin
            ? const AdminDashboardScreen()
            : const UserStorefrontScreen();
        },
      ),
    );
  }
}