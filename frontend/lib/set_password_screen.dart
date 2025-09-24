import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Thiết lập mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text(
              "Bạn đang đăng nhập bằng Google. Để sử dụng email/password, vui lòng đặt mật khẩu.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Mật khẩu mới"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Nhập lại mật khẩu"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                  final pwd = _passwordController.text.trim();
                  final confirm = _confirmController.text.trim();
                  if (pwd.isEmpty || confirm.isEmpty) {
                    _showError("Vui lòng nhập đầy đủ thông tin");
                    return;
                  }
                  if (pwd != confirm) {
                    _showError("Mật khẩu không khớp");
                    return;
                  }
                  if (user == null) {
                    _showError("User chưa đăng nhập");
                    return;
                  }

                  setState(() => _loading = true);

                  try {
                    await _authService.linkEmailPassword(user, pwd);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainTabScreen(),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    _showError(e.message ?? "Đặt mật khẩu thất bại");
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Đặt mật khẩu"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
