import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestWithJobSeeker.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';

class SkillVerificationRequestRepository
    extends FirestoreRepository<SkillVerificationRequest> {
  SkillVerificationRequestRepository() : super('SkillVerificationRequests');

  @override
  SkillVerificationRequest fromMap(Map<String, dynamic> map, String id) =>
      SkillVerificationRequest.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(SkillVerificationRequest entity) =>
      entity.toMap();

  /// 🔹 Job seeker submits request to a specific recruiter
  Future<void> submitRequest(SkillVerificationRequest request) async {
    await collection.add(request.toMap());
  }

  /// 🔹 Get all pending requests for a specific recruiter
  Future<List<SkillVerificationRequest>> getRequestsForRecruiter(
    String recruiterId,
  ) async {
    final query = await collection
        .where('recruiterId', isEqualTo: recruiterId)
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// 🔹 Get all requests (any status) for a recruiter
  Future<List<SkillVerificationRequest>> getAllRequestsForRecruiter(
    String recruiterId,
  ) async {
    final query = await collection
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// 🔹 Get single request by ID
  Future<SkillVerificationRequest?> getById(String docId) async {
    final doc = await collection.doc(docId).get();
    if (!doc.exists) return null;
    return fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// 🔹 Get request for specific job seeker, recruiter, and job
  /// This checks if a request already exists for this combination
  Future<SkillVerificationRequest?> getRequestForJobAndRecruiter({
    required String jobSeekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .where('recruiterId', isEqualTo: recruiterId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return fromMap(
      query.docs.first.data() as Map<String, dynamic>,
      query.docs.first.id,
    );
  }

  /// 🔹 Get all requests for a specific job seeker
  /// Shows which recruiters they've requested verification from
  Future<List<SkillVerificationRequest>> getRequestsForJobSeeker(
    String jobSeekerId,
  ) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// 🔹 Recruiter sees ONLY their assigned requests WITH job seeker data
  Future<List<SkillVerificationRequestWithJobSeeker>>
      getRequestsWithJobSeekersForRecruiter(
    String recruiterId,
  ) async {
    final jobSeekerRepo = JobSeekerRepository();

    // 1️⃣ Get pending requests for this recruiter
    final requests = await getRequestsForRecruiter(recruiterId);

    if (requests.isEmpty) return [];

    // 2️⃣ Collect unique job seeker IDs
    final jobSeekerIds = requests.map((r) => r.jobSeekerId).toSet();

    // 3️⃣ Fetch job seekers in parallel (FAST)
    final jobSeekers = await Future.wait(
      jobSeekerIds.map((id) => jobSeekerRepo.getByUid(id)),
    );

    // 4️⃣ Create lookup map
    final Map<String, JobSeekerModel> seekerMap = {
      for (var js in jobSeekers)
        if (js != null) js.userId: js,
    };

    // 5️⃣ Join data
    return requests
        .where((r) => seekerMap.containsKey(r.jobSeekerId))
        .map(
          (r) => SkillVerificationRequestWithJobSeeker(
            request: r,
            jobSeeker: seekerMap[r.jobSeekerId]!,
          ),
        )
        .toList();
  }

  /// 🔹 Update request status (e.g., from Pending to Completed)
  Future<void> updateRequestStatus({
    required String requestId,
    required String newStatus,
  }) async {
    await collection.doc(requestId).update({
      'status': newStatus,
    });
  }

  /// 🔹 Check if request exists for a specific job
  Future<bool> requestExists({
    required String jobSeekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    final request = await getRequestForJobAndRecruiter(
      jobSeekerId: jobSeekerId,
      recruiterId: recruiterId,
      jobId: jobId,
    );

    return request != null;
  }

  /// 🔹 Count how many pending requests a job seeker has
  Future<int> countPendingRequestsForJobSeeker(String jobSeekerId) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .where('status', isEqualTo: 'Pending')
        .get();

    return query.docs.length;
  }

  /// 🔹 Count how many completed verifications a job seeker has
  Future<int> countCompletedRequestsForJobSeeker(String jobSeekerId) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .where('status', isEqualTo: 'Completed')
        .get();

    return query.docs.length;
  }

  /// 🔹 Stream of pending requests for recruiter (real-time updates)
  Stream<List<SkillVerificationRequest>> streamRequestsForRecruiter(
    String recruiterId,
  ) {
    return collection
        .where('recruiterId', isEqualTo: recruiterId)
        .where('status', isEqualTo: 'Pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// 🔹 Stream of requests for job seeker (real-time updates)
  Stream<List<SkillVerificationRequest>> streamRequestsForJobSeeker(
    String jobSeekerId,
  ) {
    return collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// 🔹 Delete a request (in case job seeker wants to cancel)
  Future<void> deleteRequest(String requestId) async {
    await collection.doc(requestId).delete();
  }
}