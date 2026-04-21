import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_page.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _currentIndex = 0;
  bool _isCheckedIn = false;

  void _toggleCheckIn() {
    setState(() => _isCheckedIn = !_isCheckedIn);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCheckedIn ? 'Successfully checked in.' : 'Successfully checked out.'),
        backgroundColor: _isCheckedIn ? AppTheme.present : AppTheme.textMuted,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Space', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: _logout),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz_rounded), label: 'Swap'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome
        Text('Good morning,\nEmployee', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 24),

        // Check-in Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.access_time_filled_rounded, size: 48, color: AppTheme.primary),
              const SizedBox(height: 16),
              const Text('Friday, Oct 25', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
              Text('09:00 AM - 05:00 PM', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _toggleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCheckedIn ? AppTheme.absent : AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isCheckedIn ? 'Check Out' : 'Check In', style: const TextStyle(fontSize: 16)),
                ),
              ),
              if (_isCheckedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.present, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('You are currently clocked in.', style: TextStyle(color: AppTheme.present, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Notifications
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        _buildNotificationItem('Shift swap approved', 'Your request to swap shifts with Sarah Smith has been approved.', Icons.check_circle_outline_rounded, AppTheme.present),
        const SizedBox(height: 12),
        _buildNotificationItem('Upcoming shift', 'You have a shift tomorrow at 08:00 AM.', Icons.calendar_today_outlined, AppTheme.primary),
      ],
    );
  }

  Widget _buildNotificationItem(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
