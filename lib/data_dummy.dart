class User {
  final String id;
  final String name;
  final String role; // 'owner' or 'employee'
  final String email;

  User({required this.id, required this.name, required this.role, required this.email});
}

class Attendance {
  final String employeeId;
  final String status; // 'Present', 'Absent', 'Late'
  final String time;

  Attendance({required this.employeeId, required this.status, required this.time});
}

class ShiftSwapRequest {
  final String id;
  final String fromEmployeeId;
  final String toEmployeeId;
  final String date;
  final String status; // 'Pending', 'Approved', 'Rejected'

  ShiftSwapRequest({
    required this.id,
    required this.fromEmployeeId,
    required this.toEmployeeId,
    required this.date,
    required this.status,
  });
}

class MockData {
  static final User owner = User(id: 'o1', name: 'Admin (Owner)', role: 'owner', email: 'owner@x.com');
  static final User employee = User(id: 'e1', name: 'John Doe', role: 'employee', email: 'employee@x.com');

  static final List<User> employees = [
    User(id: 'e1', name: 'John Doe', role: 'employee', email: 'john@x.com'),
    User(id: 'e2', name: 'Sarah Smith', role: 'employee', email: 'sarah@x.com'),
    User(id: 'e3', name: 'Michael Lee', role: 'employee', email: 'mike@x.com'),
    User(id: 'e4', name: 'Emma Wilson', role: 'employee', email: 'emma@x.com'),
  ];

  static final List<Attendance> todayAttendance = [
    Attendance(employeeId: 'e1', status: 'Present', time: '08:00 AM'),
    Attendance(employeeId: 'e2', status: 'Late', time: '08:30 AM'),
    Attendance(employeeId: 'e3', status: 'Absent', time: '-'),
    Attendance(employeeId: 'e4', status: 'Present', time: '07:55 AM'),
  ];

  static final List<ShiftSwapRequest> swapRequests = [
    ShiftSwapRequest(id: 's1', fromEmployeeId: 'e1', toEmployeeId: 'e2', date: 'Tomorrow, 09:00 AM', status: 'Pending'),
  ];
}
