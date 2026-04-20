import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'login_page.dart';

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Manager'),
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
          const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Total\nEmployees', '24', Icons.people_outline)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Active\nShifts', '8', Icons.access_time)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Pending\nRequests', '3', Icons.mark_email_unread_outlined)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildMenuItem(context, 'Manage Employees', Icons.badge_outlined),
                const Divider(),
                _buildMenuItem(context, 'Manage Shifts', Icons.calendar_month_outlined),
                const Divider(),
                _buildMenuItem(context, 'Approvals', Icons.fact_check_outlined, trailing: _buildBadge('3')),
                const Divider(),
                _buildMenuItem(context, 'Reports', Icons.bar_chart_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textDark),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textMuted),
      onTap: () {
        // Navigate
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.danger,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
