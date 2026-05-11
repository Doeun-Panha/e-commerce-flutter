import 'package:ecommerce/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:ecommerce/features/auth/logic/auth_provider.dart';
import 'package:ecommerce/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce/features/auth/presentation/screens/start_up_screen.dart';
import 'package:ecommerce/features/user/presentation/screens/user_storefront_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  //Use a private key for the navigator to handle dialogs/snackbars globally later
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
        initialLocation: '/',
        navigatorKey: rootNavigatorKey,

        //Run every time the authProvider changes
        refreshListenable: authProvider,

        //Check statements when authProvider changes
        redirect: (context, state) {
          final bool isAuthenticated = authProvider.isAuthenticated;
          final bool isAdmin = authProvider.isAdmin;
          final String location = state.matchedLocation;

          //If not logged in and trying to access shop or admin, redirect to startup
          if(!isAuthenticated){
            if(location.startsWith('/admin') || location.startsWith('/shop')){
              return '/';
            }
            return null;
          }

          //If logged in and at startup/login, redirect to their screen
          if(location == '/' || location == '/login'){
            return isAdmin ? '/admin' : '/shop';
          }

          //If not admin, can't enter admin
          if(location.startsWith('/admin') && !isAdmin){
            return '/shop';
          }

          return null;
        },

        routes: [
          //Auth
          GoRoute(path: '/', builder: (context, state) => const StartUpScreen(),),
          GoRoute(path: '/login', builder: (context, state) => const LoginScreen(),),
          GoRoute(path: '/register', builder: (context, state) => const LoginScreen(),),

          //User
          GoRoute(path: '/shop', builder: (context, state) => const UserStorefrontScreen(),),

          //Admin
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen(),)
        ],

        //Error handling
        errorBuilder: (context, state) =>
          const Scaffold(
            body: Center(
              child: Text('Page not found!'),
            ),
          )
    );
  }
}