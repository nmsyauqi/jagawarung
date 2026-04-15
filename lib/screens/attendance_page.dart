import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 10,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final isLate = index == 2;
          return Container(
            color: AppTheme.surfaceWhite,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text('Monday, ${15 - index}th Oct', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.login, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(isLate ? '08:15 AM' : '07:55 AM', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    const Icon(Icons.logout, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    const Text('04:05 PM', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLate ? AppTheme.warningOrange.withOpacity(0.1) : AppTheme.secondaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isLate ? 'Late' : 'Present',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLate ? AppTheme.warningOrange : AppTheme.secondaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
