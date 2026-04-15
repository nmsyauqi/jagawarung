import 'package:flutter/material.dart';
import '../theme.dart';
import '../data_dummy.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Manager', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Shifts'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total\nEmployees', '24', Icons.people_outline_rounded, AppTheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Active\nShifts', '8', Icons.access_time_rounded, AppTheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Pending\nRequests', '3', Icons.mark_email_unread_outlined, AppTheme.primaryDark)),
          ],
        ),
        const SizedBox(height: 32),

        Text('Management', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildMenuCard('Manage Employees', Icons.badge_outlined),
        const SizedBox(height: 12),
        _buildMenuCard('Manage Shifts', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        _buildMenuCard('Approvals', Icons.fact_check_outlined, badgeCount: 3),
        const SizedBox(height: 12),
        _buildMenuCard('Reports', Icons.bar_chart_rounded),
        
        const SizedBox(height: 32),
        Text('Today\'s Attendance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: MockData.todayAttendance.map((a) {
              final user = MockData.employees.firstWhere((e) => e.id == a.employeeId);
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.surfaceDim,
                      child: Text(user.name[0], style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Check-in: ${a.time}'),
                    trailing: _buildStatusBadge(a.status),
                  ),
                  if (a != MockData.todayAttendance.last)
                    const Divider(height: 1, indent: 72),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(count, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, {int badgeCount = 0}) {
    return Material(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textDark),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.absent, borderRadius: BorderRadius.circular(12)),
                  child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, text;
    if (status == 'Present') {
      bg = AppTheme.presentLight; text = AppTheme.present;
    } else if (status == 'Absent') {
      bg = AppTheme.absentLight; text = AppTheme.absent;
    } else {
      bg = AppTheme.lateLight; text = AppTheme.lateStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
