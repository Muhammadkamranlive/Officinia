import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;

  // ── Simulated profile data (replace with your actual repo calls) ──────────
  String _name        = "Henry Kanwil";
  String _role        = "Programmer";
  String _bio         = "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu";
  String _resumeName  = "david_resume.pdf";

  List<Map<String, dynamic>> _skills = [
    {"title": "PHP",    "percent": 86, "color": Colors.orange},
    {"title": "Java",   "percent": 48, "color": Colors.green},
    {"title": "MySQL",  "percent": 56, "color": Colors.blue},
    {"title": "React",  "percent": 34, "color": Colors.pink},
    {"title": "CSS",    "percent": 86, "color": Colors.deepPurple},
  ];

  /// Replace this body with your real API/repo calls
  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    // TODO: final profile = await _profileRepo.getByUid(user.userId);
    // setState(() { _name = profile.name; ... });
    await Future.delayed(const Duration(milliseconds: 800)); // simulate network
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    // ── Responsive breakpoint ─────────────────────────────────────────────
    final screenW   = MediaQuery.of(context).size.width;
    final isSmall   = screenW < 380;          // iPhone SE threshold
    final skillSize = isSmall ? 90.0 : 110.0; // skill card width
    final avatarR   = isSmall ? 42.0 : 50.0;  // avatar radius

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.deepPurple,
          child: SingleChildScrollView(
            // ✅ physics required so RefreshIndicator fires even when content fits
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _headerSection(avatarR),
                const SizedBox(height: 20),
                _contactButtons(isSmall),
                const SizedBox(height: 25),
                _resumeCard(),
                const SizedBox(height: 30),
                _skillSection(skillSize, isSmall),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _headerSection(double avatarR) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background banner
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/avatar.png"),
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay so text is readable
          child: Container(color: Colors.black.withOpacity(0.35)),
        ),

        // "Account" label
        const Positioned(
          top: 50,
          child: Text(
            "Account",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Avatar — overlaps bottom of banner
        Positioned(
          bottom: -(avatarR + 6),
          child: CircleAvatar(
            radius: avatarR + 4,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: avatarR,
              backgroundImage: const AssetImage("assets/avatar.png"),
            ),
          ),
        ),
      ],
    );
  }

  // ── CONTACT / BIO ──────────────────────────────────────────────────────────
  Widget _contactButtons(bool isSmall) {
    return Column(
      children: [
        // Space for overlapping avatar
        SizedBox(height: isSmall ? 48 : 58),

        // Name
        Text(
          _name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 17 : 20,
          ),
        ),

        const SizedBox(height: 4),

        // Role
        Text(
          _role,
          style: TextStyle(
            color: Colors.grey,
            fontSize: isSmall ? 13 : 15,
          ),
        ),

        // Bio
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 30,
            vertical: 10,
          ),
          child: Text(
            _bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isSmall ? 12 : 14,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Icon buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconButton(Icons.phone),
            SizedBox(width: isSmall ? 12 : 20),
            _iconButton(Icons.email),
            SizedBox(width: isSmall ? 12 : 20),
            _iconButton(Icons.location_on),
          ],
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.deepPurple, size: 20),
    );
  }

  // ── RESUME CARD ────────────────────────────────────────────────────────────
  Widget _resumeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff5a19d6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "My Resume\n$_resumeName",
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }

  // ── SKILL SECTION ──────────────────────────────────────────────────────────
  Widget _skillSection(double cardSize, bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Skills",
            style: TextStyle(
              fontSize: isSmall ? 17 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // ✅ Wrap handles small screens — items reflow to next line automatically
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: isSmall ? 10 : 15,
            runSpacing: isSmall ? 10 : 15,
            alignment: WrapAlignment.center,
            children: _skills
                .map((s) => _skillCard(
                      s["title"] as String,
                      s["percent"] as int,
                      s["color"] as Color,
                      cardSize,
                      isSmall,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _skillCard(
    String title,
    int percent,
    Color color,
    double cardSize,
    bool isSmall,
  ) {
    final circleSize = isSmall ? 72.0 : 90.0;

    return Container(
      width: cardSize,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: circleSize,
            width: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 6,
                  color: color,
                  backgroundColor: color.withOpacity(.2),
                ),
                // ✅ FittedBox prevents percent text overflow inside circle
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$percent%",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── StatTile (kept for external use) ─────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}