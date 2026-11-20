class UserRole {
  static const String jobSeeker = 'JobSeeker';
  static const String recruiter = 'Recruiter';
}


class ReportedUserView {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;

  ReportedUserView({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
  });
}
