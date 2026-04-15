import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_page.dart';
import 'package:provider/provider.dart';
import 'providers/shift_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
      ],
      child: MaterialApp(
        title: 'Company Portal',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }
}
