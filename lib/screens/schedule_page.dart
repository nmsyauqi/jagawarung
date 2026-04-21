import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'shift_swap_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          final isToday = index == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isToday ? AppTheme.primary : AppTheme.border, width: isToday ? 2 : 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date indicator
                    Container(
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text('MON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                          Text('${15 + index}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Morning Shift', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('08:00 AM - 04:00 PM', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          const SizedBox(height: 8),
                          if (!isToday) 
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftSwapPage()));
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              child: const Text('Request Swap', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
