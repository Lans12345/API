import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sample_app/views/auth/login_page.dart';
import 'package:sample_app/views/auth/register_page.dart';
import 'package:sample_app/views/pages/home_page.dart';
import 'package:sample_app/views/pages/product_page.dart';

GoRouter routes = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterPage();
      },
    ),
    GoRoute(
      path: '/product',
      builder: (BuildContext context, GoRouterState state) {
        return ProductPage();
      },
    ),
  ],
);