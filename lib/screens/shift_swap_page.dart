import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ShiftSwapPage extends StatefulWidget {
  const ShiftSwapPage({super.key});

  @override
  State<ShiftSwapPage> createState() => _ShiftSwapPageState();
}

class _ShiftSwapPageState extends State<ShiftSwapPage> {
  String? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Shift Swap'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Swap your shift on:', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            const Text('Monday, 16th (08:00 AM - 04:00 PM)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            const Text('Select Employee to Swap With', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Choose employee'),
                  ),
                  value: _selectedEmployee,
                  items: const [
                    DropdownMenuItem(value: 'John Doe', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('John Doe'))),
                    DropdownMenuItem(value: 'Emily Smith', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Emily Smith'))),
                    DropdownMenuItem(value: 'Mike Johnson', child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Mike Johnson'))),
                  ],
                  onChanged: (val) => setState(() => _selectedEmployee = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Reason (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason for swap...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedEmployee == null ? null : () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Swap request submitted.')));
                Navigator.pop(context);
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
