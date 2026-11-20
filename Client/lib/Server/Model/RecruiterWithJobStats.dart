import 'package:client/Server/Model/Recruiter.dart';

class RecruiterWithJobStats {
  final Recruiter recruiter;
  final int jobCount;

  RecruiterWithJobStats({
    required this.recruiter,
    required this.jobCount,
  });
}
