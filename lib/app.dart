import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/buyer/buyer_dashboard_screen.dart';
import 'screens/seller/seller_dashboard_screen.dart';

class AgroConnectApp extends ConsumerWidget {
  const AgroConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Agro Connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: authAsync.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          final userDoc = ref.watch(currentUserDocProvider);
          return userDoc.when(
            data: (appUser) {
              if (appUser == null) return const AuthScreen();
              return appUser.role == 'seller'
                  ? const SellerDashboardScreen()
                  : const BuyerDashboardScreen();
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}
