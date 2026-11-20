// import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
// import 'package:client/Server/Model/Recruiter.dart';
// import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';

// class JobSearchRepository {
//   final JobOfferRepository _jobRepo = JobOfferRepository();
//   final RecruiterRepository _recruiterRepo = RecruiterRepository();

//   Future<List<JobOfferWithRecruiter>> getAllJobsWithRecruiter() async {
//     // 1. Get all job offers
//     final jobs = await _jobRepo.getAll();

//     // 2. Cache recruiters (important for performance)
//     final Map<String, Recruiter> recruiterCache = {};

//     final List<JobOfferWithRecruiter> result = [];

//     for (final job in jobs) {
//       // Check cache first
//       Recruiter? recruiter = recruiterCache[job.userId];

//       if (recruiter == null) {
//         recruiter = await _recruiterRepo.getByUid(job.userId);
//         if (recruiter != null) {
//           recruiterCache[job.userId] = recruiter;
//         }
//       }

//       if (recruiter != null) {
//         result.add(
//           JobOfferWithRecruiter(
//             recruiter: recruiter, jobOffer: job,
//           ),
//         );
//       }
//     }

//     return result;
//   }

//   Future<List<JobOfferWithRecruiter>> getAllJobsWithRecruiters(String userId) async {
//     // 1. Get all job offers
//     final jobs = await _jobRepo.getByUserId(userId);

//     // 2. Cache recruiters (important for performance)
//     final Map<String, Recruiter> recruiterCache = {};

//     final List<JobOfferWithRecruiter> result = [];

//     for (final job in jobs) {
//       // Check cache first
//       Recruiter? recruiter = recruiterCache[job.userId];

//       if (recruiter == null) 
//       {
//         recruiter = await _recruiterRepo.getByUid(job.userId);
//         if (recruiter != null) 
//         {
//           recruiterCache[job.userId] = recruiter;
//         }
//       }

//       if (recruiter != null) {
//         result.add(
//           JobOfferWithRecruiter(
//             recruiter: recruiter, jobOffer: job,
//           ),
//         );
//       }
//     }

//     return result;
//   }
//   Future<JobOfferWithRecruiter?> getJobWithRecruiterByJobId(String jobId) async {
//     // 1. Get the job offer by its document ID
//     final job = await _jobRepo.getByDocId(jobId);
//     if (job == null) return null;

//     // 2. Get the recruiter using the job's userId
//     final recruiter = await _recruiterRepo.getByUid(job.userId);
//     if (recruiter == null) return null;

//     // 3. Return combined model
//     return JobOfferWithRecruiter(
//       jobOffer: job,
//       recruiter: recruiter,
//     );
//   }
// }
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/RecruiterWithJobStats.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const int kJobPageSize = 4; // max jobs loaded per page

class JobSearchRepository {
  final JobOfferRepository  _jobRepo       = JobOfferRepository();
  final RecruiterRepository _recruiterRepo = RecruiterRepository();

  // Recruiter cache — shared across all paginated calls.
  // Avoids re-fetching the same pharmacy for every job card.
  final Map<String, Recruiter> _recruiterCache = {};

  // ─────────────────────────────────────────────────────────────────────────
  //  PAGINATED — used by JobSeekerHomeScreen
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetches [kJobPageSize] jobs starting after [lastDocument].
  /// Pass lastDocument = null to get the first page.
  Future<JobPage> getJobsPage({DocumentSnapshot? lastDocument}) async {
    Query query = FirebaseFirestore.instance
        .collection('JobOffers')          // ← your collection name
        .orderBy('createdAt', descending: true)
        .limit(kJobPageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final docs     = snapshot.docs;

    if (docs.isEmpty) {
      return JobPage(jobs: [], lastDoc: null, hasMore: false);
    }

    final List<JobOfferWithRecruiter> result = [];

    for (final doc in docs) {
      final job = _jobRepo.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      Recruiter? recruiter = _recruiterCache[job.userId];
      if (recruiter == null) {
        recruiter = await _recruiterRepo.getByUid(job.userId);
        if (recruiter != null) _recruiterCache[job.userId] = recruiter;
      }

      if (recruiter != null) {
        result.add(JobOfferWithRecruiter(recruiter: recruiter, jobOffer: job));
      }
    }

    return JobPage(
      jobs:    result,
      lastDoc: docs.last,
      hasMore: docs.length == kJobPageSize,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  NEW MAP FETCH — fetches recruiters and their job count dynamically
  // ─────────────────────────────────────────────────────────────────────────
  Future<RecruiterStatsPage> getMapRecruitersPage({DocumentSnapshot? lastDocument}) async {
    final page = await _recruiterRepo.getRecruitersPage(lastDocument: lastDocument);
    final List<RecruiterWithJobStats> results = [];

    for (final recruiter in page.recruiters) {
      // Use aggregate count query to safely and quickly get job count
      final countQuery = await FirebaseFirestore.instance
          .collection('JobOffers')
          .where('userId', isEqualTo: recruiter.userId)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      
      results.add(
        RecruiterWithJobStats(
          recruiter: recruiter,
          jobCount: countQuery.count ?? 0,
        )
      );
    }

    return RecruiterStatsPage(
      recruiters: results,
      lastDoc: page.lastDoc,
      hasMore: page.hasMore,
    );
  }

  /// Get specific active jobs for a recruiter 
  Future<List<JobOfferWithRecruiter>> getJobsByRecruiter(String recruiterId) async {
    final jobs = await _jobRepo.getByUserId(recruiterId);
    final activeJobs = jobs.where((j) => j.isActive).toList();
    
    // We already know the recruiter, but to reuse existing models we fetch/cache it
    Recruiter? recruiter = _recruiterCache[recruiterId];
    if (recruiter == null) {
      recruiter = await _recruiterRepo.getByUid(recruiterId);
      if (recruiter != null) _recruiterCache[recruiterId] = recruiter;
    }
    
    if (recruiter == null) return [];

    return activeJobs.map((j) => JobOfferWithRecruiter(jobOffer: j, recruiter: recruiter!)).toList();
  }

  /// Clear cache when filters change so stale data isn't shown.
  void clearCache() => _recruiterCache.clear();

  // ─────────────────────────────────────────────────────────────────────────
  //  LEGACY — kept for other screens that still call these
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<JobOfferWithRecruiter>> getAllJobsWithRecruiter() async {
    final jobs = await _jobRepo.getAll();
    final List<JobOfferWithRecruiter> result = [];
    for (final job in jobs) {
      Recruiter? r = _recruiterCache[job.userId];
      if (r == null) {
        r = await _recruiterRepo.getByUid(job.userId);
        if (r != null) _recruiterCache[job.userId] = r;
      }
      if (r != null) result.add(JobOfferWithRecruiter(recruiter: r, jobOffer: job));
    }
    return result;
  }

  Future<List<JobOfferWithRecruiter>> getAllJobsWithRecruiters(String userId) async {
    final jobs = await _jobRepo.getByUserId(userId);
    final List<JobOfferWithRecruiter> result = [];
    for (final job in jobs) {
      Recruiter? r = _recruiterCache[job.userId];
      if (r == null) {
        r = await _recruiterRepo.getByUid(job.userId);
        if (r != null) _recruiterCache[job.userId] = r;
      }
      if (r != null) result.add(JobOfferWithRecruiter(recruiter: r, jobOffer: job));
    }
    return result;
  }

  Future<JobOfferWithRecruiter?> getJobWithRecruiterByJobId(String jobId) async {
    final job = await _jobRepo.getByDocId(jobId);
    if (job == null) return null;
    final recruiter = await _recruiterRepo.getByUid(job.userId);
    if (recruiter == null) return null;
    return JobOfferWithRecruiter(jobOffer: job, recruiter: recruiter);
  }
}

// ── Value object returned by getJobsPage ─────────────────────────────────────
class JobPage {
  final List<JobOfferWithRecruiter> jobs;
  final DocumentSnapshot?           lastDoc; // cursor for next page
  final bool                        hasMore;

  const JobPage({
    required this.jobs,
    required this.lastDoc,
    required this.hasMore,
  });
}

// ── Value object returned by getMapRecruitersPage ────────────────────────────
class RecruiterStatsPage {
  final List<RecruiterWithJobStats> recruiters;
  final DocumentSnapshot?           lastDoc;
  final bool                        hasMore;

  const RecruiterStatsPage({
    required this.recruiters,
    required this.lastDoc,
    required this.hasMore,
  });
}