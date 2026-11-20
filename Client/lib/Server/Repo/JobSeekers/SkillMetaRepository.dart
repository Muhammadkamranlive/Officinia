import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/FirestoreRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';

class SkillMetaRepository extends FirestoreRepository<SkillVerificationMeta> {
  SkillMetaRepository() : super('SkillVerificationMeta');

  @override
  SkillVerificationMeta fromMap(Map<String, dynamic> map, String id) =>
      SkillVerificationMeta.fromMap(map, id);

  @override
  Map<String, dynamic> toMap(SkillVerificationMeta entity) => entity.toMap();

  /// Get or create skill meta for a job seeker
  Future<SkillVerificationMeta> getOrCreateSkillMeta({
    required String jobSeekerId,
    required String skill,
  }) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .where('skill', isEqualTo: skill)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return fromMap(
        query.docs.first.data() as Map<String, dynamic>,
        query.docs.first.id,
      );
    }

    // Create new meta
    final newMeta = SkillVerificationMeta(
      jobSeekerId: jobSeekerId,
      skill: skill,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final docRef = await collection.add(newMeta.toMap());
    newMeta.docId = docRef.id;
    return newMeta;
  }

  /// Get all skills for a job seeker with their verification counts
  Future<List<SkillVerificationMeta>> getSkillsForJobSeeker(
    String jobSeekerId,
  ) async {
    final query = await collection
        .where('jobSeekerId', isEqualTo: jobSeekerId)
        .get();

    return query.docs
        .map((d) => fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  /// Get skills that a specific recruiter hasn't reviewed yet for a job seeker
  /// This is the KEY method that solves your issue!
  Future<List<SkillVerificationMeta>> getPendingSkillsForRecruiter({
    required String jobSeekerId,
    required String recruiterId,
  }) async {
    // First, get the job seeker to know what skills they have
    final jobSeekerRepo = JobSeekerRepository();
    final jobSeeker = await jobSeekerRepo.getByUid(jobSeekerId);

    if (jobSeeker == null || jobSeeker.skills.isEmpty) {
      return [];
    }

    // Get all existing skill metas for this job seeker
    final existingMetas = await getSkillsForJobSeeker(jobSeekerId);

    // Create a map for quick lookup
    final Map<String, SkillVerificationMeta> metaMap = {
      for (var meta in existingMetas) meta.skill: meta,
    };

    // Build list of skills that this recruiter hasn't reviewed
    final List<SkillVerificationMeta> pendingSkills = [];

    for (var skill in jobSeeker.skills) {
      SkillVerificationMeta meta;

      if (metaMap.containsKey(skill)) {
        // Skill meta exists
        meta = metaMap[skill]!;
      } else {
        // Skill meta doesn't exist yet, create it
        meta = await getOrCreateSkillMeta(
          jobSeekerId: jobSeekerId,
          skill: skill,
        );
      }

      // Only include if recruiter hasn't reviewed this skill yet
      if (!meta.hasRecruiterReviewed(recruiterId)) {
        pendingSkills.add(meta);
      }
    }

    return pendingSkills;
  }

  /// Recruiter verifies a skill
  Future<void> verifySkill({
    required String jobSeekerId,
    required String skill,
    required String recruiterId,
  }) async {
    final meta = await getOrCreateSkillMeta(
      jobSeekerId: jobSeekerId,
      skill: skill,
    );

    // Don't add if already verified by this recruiter
    if (meta.hasRecruiterVerified(recruiterId)) {
      return;
    }

    // Remove from rejected if was previously rejected
    final updatedRejected = List<String>.from(meta.rejectedBy)
      ..remove(recruiterId);

    final updatedVerified = List<String>.from(meta.verifiedBy)
      ..add(recruiterId);

    final updated = meta.copyWith(
      verifiedBy: updatedVerified,
      rejectedBy: updatedRejected,
      updatedAt: DateTime.now(),
    );

    await update(meta.docId!, updated);
  }

  /// Recruiter rejects a skill
  Future<void> rejectSkill({
    required String jobSeekerId,
    required String skill,
    required String recruiterId,
  }) async {
    final meta = await getOrCreateSkillMeta(
      jobSeekerId: jobSeekerId,
      skill: skill,
    );

    // Don't add if already rejected by this recruiter
    if (meta.hasRecruiterRejected(recruiterId)) return;

    // Remove from verified if was previously verified
    final updatedVerified = List<String>.from(meta.verifiedBy)
      ..remove(recruiterId);

    final updatedRejected = List<String>.from(meta.rejectedBy)
      ..add(recruiterId);

    final updated = meta.copyWith(
      verifiedBy: updatedVerified,
      rejectedBy: updatedRejected,
      updatedAt: DateTime.now(),
    );

    await update(meta.docId!, updated);
  }

  /// Get total verified skills count (for ranking)
  Future<int> getVerifiedSkillCount(String jobSeekerId) async {
    final skills = await getSkillsForJobSeeker(jobSeekerId);
    return skills.where((s) => s.status == 'Verified').length;
  }
}
