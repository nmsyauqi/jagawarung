import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'login_page.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Sarah!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          _buildTodayScheduleCard(),
          const SizedBox(height: 24),
          
          const Text('Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('CHECK IN NOW', style: TextStyle(fontSize: 16, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.surfaceDim,
                    child: Icon(Icons.notifications_none, color: AppTheme.primary, size: 20),
                  ),
                  title: Text(index == 0 ? 'Shift swap approved' : 'New schedule posted', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('2 hours ago', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Morning Shift', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Upcoming', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.access_time, size: 16, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Text('08:00 AM - 04:00 PM', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                SizedBox(width: 8),
                Text('Main Store Branch', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
