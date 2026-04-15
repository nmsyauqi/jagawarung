import 'package:flutter/material.dart';
import '../theme.dart';

import 'owner_dashboard.dart';
import 'employee_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    setState(() => _isLoading = false);

    final email = _emailCtrl.text.toLowerCase().trim();
    if (email == 'owner@x.com') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OwnerDashboard()));
    } else {
      // Default to employee
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const EmployeeDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Brand ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_outline_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text('Company Portal', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('Sign in to manage your shifts and attendance.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 48),

              // ── Login Form Card ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email Address', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. employee@company.com'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    Text('Password', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'Enter your password'),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('Demo Note: Use "owner@x.com" for Manager Dashboard, any other email for Employee Dashboard.', 
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
