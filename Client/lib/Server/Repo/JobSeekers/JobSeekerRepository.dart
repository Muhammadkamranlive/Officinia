// ============================================================================
// 1. CREATE NEW ENRICHED MODEL
// ============================================================================

import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillVerificationMetaRepository.dart';

/// Enriched job seeker model with skill verification data
/// This combines JobSeekerModel with SkillVerificationMeta data
class JobSeekerWithSkills {
  final JobSeekerModel jobSeeker;
  final List<SkillVerificationMeta> skillMetas;
  
  JobSeekerWithSkills({
    required this.jobSeeker,
    required this.skillMetas,
  });

  // ✅ Computed properties for easy access
  
  /// Total number of verified skills (status == 'Verified')
  int get totalVerifiedSkills => 
      skillMetas.where((m) => m.status == 'Verified').length;
  
  /// Total number of pending skills
  int get totalPendingSkills => 
      skillMetas.where((m) => m.status == 'Pending').length;
  
  /// Total number of rejected skills
  int get totalRejectedSkills => 
      skillMetas.where((m) => m.status == 'Rejected').length;
  
  /// Total verification count across all skills
  int get totalVerifications => 
      skillMetas.fold(0, (sum, meta) => sum + meta.verifiedCount);
  
  /// Total rejection count across all skills
  int get totalRejections => 
      skillMetas.fold(0, (sum, meta) => sum + meta.rejectedCount);
  
  /// Profile completion score (0-100)
  double get profileScore {
    if (jobSeeker.skills.isEmpty) return 0;
    final verifiedRatio = totalVerifiedSkills / jobSeeker.skills.length;
    return (verifiedRatio * 100).roundToDouble();
  }
  
  /// Get status for a specific skill
  String getSkillStatus(String skill) {
    final meta = skillMetas.firstWhere(
      (m) => m.skill == skill,
      orElse: () => SkillVerificationMeta(
        jobSeekerId: jobSeeker.userId,
        skill: skill,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return meta.status;
  }
  
  /// Get verification count for a specific skill
  int getSkillVerificationCount(String skill) {
    final meta = skillMetas.firstWhere(
      (m) => m.skill == skill,
      orElse: () => SkillVerificationMeta(
        jobSeekerId: jobSeeker.userId,
        skill: skill,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return meta.verifiedCount;
  }
  
  /// Get list of verified skills
  List<String> get verifiedSkills => 
      skillMetas
          .where((m) => m.status == 'Verified')
          .map((m) => m.skill)
          .toList();
  
  /// Get list of pending skills
  List<String> get pendingSkills => 
      skillMetas
          .where((m) => m.status == 'Pending')
          .map((m) => m.skill)
          .toList();
  
  /// Get map of all skills with their statuses
  Map<String, String> get skillsWithStatus {
    final Map<String, String> result = {};
    for (var skill in jobSeeker.skills) {
      result[skill] = getSkillStatus(skill);
    }
    return result;
  }
  
  /// Get map of all skills with their verification counts
  Map<String, int> get skillsWithVerificationCounts {
    final Map<String, int> result = {};
    for (var skill in jobSeeker.skills) {
      result[skill] = getSkillVerificationCount(skill);
    }
    return result;
  }
}

// ============================================================================
// 2. ADD METHODS TO JOBSEEKER REPOSITORY
// ============================================================================


class JobSeekerRepository extends FirestoreRepository<JobSeekerModel> {
  JobSeekerRepository() : super('JobSeekers');
  
  final SkillMetaRepository _skillMetaRepo = SkillMetaRepository();

  @override
  JobSeekerModel fromMap(Map<String, dynamic> map, String id) =>
      JobSeekerModel.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(JobSeekerModel entity) => entity.toMap();

  /// Get a single job seeker by their userId
  Future<JobSeekerModel?> getByUid(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  /// Get all job seekers
  Future<List<JobSeekerModel>> getAll() async {
    final query = await collection.get();

    return query.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  /// ⚠️ Deprecated - Use getByUid instead
  @Deprecated('Use getByUid instead - userId is unique')
  Future<List<JobSeekerModel>> getAllBYId(String userId) async {
    final query = await collection
        .where('userId', isEqualTo: userId)
        .get();

    return query.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // ============================================================================
  // ✅ NEW METHODS WITH SKILL VERIFICATION DATA (JOIN)
  // ============================================================================

  /// Get job seeker WITH skill verification data
  Future<JobSeekerWithSkills?> getWithSkills(String userId) async {
    final jobSeeker = await getByUid(userId);
    if (jobSeeker == null) return null;

    final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(userId);

    return JobSeekerWithSkills(
      jobSeeker: jobSeeker,
      skillMetas: skillMetas,
    );
  }

  /// Get all job seekers WITH skill verification data
  Future<List<JobSeekerWithSkills>> getAllWithSkills() async {
    final jobSeekers = await getAll();
    
    final List<JobSeekerWithSkills> enrichedList = [];
    
    for (var jobSeeker in jobSeekers) {
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(
        jobSeeker.userId,
      );
      
      enrichedList.add(JobSeekerWithSkills(
        jobSeeker: jobSeeker,
        skillMetas: skillMetas,
      ));
    }
    
    return enrichedList;
  }

  /// Get job seekers sorted by total verified skills (descending)
  Future<List<JobSeekerWithSkills>> getTopVerifiedJobSeekers({
    int limit = 10,
  }) async {
    final allWithSkills = await getAllWithSkills();
    
    // Sort by total verified skills
    allWithSkills.sort((a, b) => 
      b.totalVerifiedSkills.compareTo(a.totalVerifiedSkills)
    );
    
    return allWithSkills.take(limit).toList();
  }

  /// Get job seekers with at least N verified skills
  Future<List<JobSeekerWithSkills>> getJobSeekersWithMinVerifiedSkills({
    required int minVerifiedSkills,
  }) async {
    final allWithSkills = await getAllWithSkills();
    
    return allWithSkills
        .where((js) => js.totalVerifiedSkills >= minVerifiedSkills)
        .toList();
  }

  /// Get job seekers by city WITH skill verification data
  Future<List<JobSeekerWithSkills>> getByCityWithSkills(String city) async {
    final query = await collection
        .where('city', isEqualTo: city)
        .get();

    final jobSeekers = query.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final List<JobSeekerWithSkills> enrichedList = [];
    
    for (var jobSeeker in jobSeekers) {
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(
        jobSeeker.userId,
      );
      
      enrichedList.add(JobSeekerWithSkills(
        jobSeeker: jobSeeker,
        skillMetas: skillMetas,
      ));
    }
    
    return enrichedList;
  }

  /// Get job seekers by position WITH skill verification data
  Future<List<JobSeekerWithSkills>> getByPositionWithSkills(
    String position,
  ) async {
    final query = await collection
        .where('desiredPosition', isEqualTo: position)
        .get();

    final jobSeekers = query.docs
        .map((doc) => fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final List<JobSeekerWithSkills> enrichedList = [];
    
    for (var jobSeeker in jobSeekers) {
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(
        jobSeeker.userId,
      );
      
      enrichedList.add(JobSeekerWithSkills(
        jobSeeker: jobSeeker,
        skillMetas: skillMetas,
      ));
    }
    
    return enrichedList;
  }

  /// Stream job seeker WITH real-time skill updates
  Stream<JobSeekerWithSkills?> streamWithSkills(String userId) async* {
    // Stream job seeker changes
    await for (var jsSnapshot in collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()) {
      
      if (jsSnapshot.docs.isEmpty) {
        yield null;
        continue;
      }

      final jobSeeker = fromMap(
        jsSnapshot.docs.first.data() as Map<String, dynamic>,
        jsSnapshot.docs.first.id,
      );

      // Get latest skill metas
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(userId);

      yield JobSeekerWithSkills(
        jobSeeker: jobSeeker,
        skillMetas: skillMetas,
      );
    }
  }
}

