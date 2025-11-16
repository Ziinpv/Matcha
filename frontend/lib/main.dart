import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/blocklist_service.dart';
import 'services/auth_service.dart';
import 'register_screen.dart';
import 'main_tab_screen.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Bắt buộc cho Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BlocklistService(),
      child: MaterialApp(
        title: 'Matcha',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF4B91),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF4B91),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget để quyết định hiển thị màn hình nào
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // Đã đăng nhập → kiểm tra profile và điều hướng
          return _ProfileCheckWrapper();
        } else {
          // Chưa đăng nhập → mở RegisterScreen
          return const RegisterScreen();
        }
      },
    );
  }
}

/// Widget kiểm tra profile và điều hướng đến onboarding nếu chưa có
class _ProfileCheckWrapper extends StatefulWidget {
  const _ProfileCheckWrapper();

  @override
  State<_ProfileCheckWrapper> createState() => _ProfileCheckWrapperState();
}

class _ProfileCheckWrapperState extends State<_ProfileCheckWrapper> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final hasProfile = await _authService.userHasCompleteProfile(user.uid);
      if (mounted) {
        setState(() {
          _hasProfile = hasProfile;
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Nếu chưa có profile → điều hướng đến onboarding
    if (!_hasProfile) {
      return const OnboardingScreen();
    }

    // Đã có profile → vào MainTabScreen
    return const MainTabScreen();
  }
}
