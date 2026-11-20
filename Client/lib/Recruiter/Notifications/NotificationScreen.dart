

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'NotificationDetailScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading      = true;
  bool _markingAllRead = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    // ── No auto-mark — user controls this manually ───────────────
  }

  // ── Fetch (sorted by date in repo) ───────────────────────────
  Future<void> _fetchNotifications() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final data = await _repo.getByUserId(user.userId);
    if (!mounted) return;
    setState(() {
      _notifications = data;
      _isLoading     = false;
    });
  }

  // ── Mark all read — manual button only ───────────────────────
  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    setState(() => _markingAllRead = true);

    // Optimistic UI — flip all instantly
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    final user = context.read<AuthProvider>().user;
    if (user != null) await _repo.markAllAsRead(user.userId);

    if (!mounted) return;
    setState(() => _markingAllRead = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.all_notifications_marked_as_read),
        backgroundColor: AppColors.darkGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Mark single as read on tap ────────────────────────────────
  Future<void> _markAsRead(int index) async {
    final n = _notifications[index];
    if (n.isRead || n.docId == null) return;
    setState(() => _notifications[index] = n.copyWith(isRead: true));
    await _repo.update(n.docId!, n.copyWith(isRead: true));
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  IconData _getIcon(String type) {
    switch (type) {
      case 'login':          return Icons.login_rounded;
      case 'logout':         return Icons.logout_rounded;
      case 'payment':        return Icons.payments_outlined;
      case 'job_post':       return Icons.campaign_outlined;
      case 'job_apply':      return Icons.person_add_alt_rounded;
      case 'skill_verified': return Icons.verified_outlined;
      case 'chat':           return Icons.chat_bubble_outline_rounded;
      default:               return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'login':          return Colors.green;
      case 'logout':         return Colors.red;
      case 'payment':        return Colors.purple;
      case 'job_post':       return Colors.teal;
      case 'job_apply':      return Colors.blue;
      case 'skill_verified': return AppColors.darkGreen;
      case 'chat':           return Colors.teal;
      default:               return AppColors.darkGreen;
    }
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final l10n = AppLocalizations.of(context)!;
    if (diff.inMinutes < 1) return l10n.just_now;
    if (diff.inMinutes < 60) return l10n.min_ago(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hours_ago(diff.inHours);
    if (diff.inDays < 7) return l10n.days_ago(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _localizedTitle(BuildContext context, NotificationModel n) {
    final l10n = AppLocalizations.of(context)!;
    switch (n.type) {
      case 'job_post':
        return l10n.notif_job_posted_title;
      case 'job_apply':
      case 'Job_Application':
        return l10n.notif_job_apply_title;
      case 'skill_verified':
      case 'skill_verification':
        return l10n.notif_skill_verified_title;
      case 'payment':
        return l10n.notif_payment_success_title;
      case 'login':
        return l10n.notif_login_title;
      case 'logout':
        return l10n.notif_logout_title;
      default:
        return n.title; // Fallback to DB title
    }
  }

  String _localizedDescription(BuildContext context, NotificationModel n) {
    final l10n = AppLocalizations.of(context)!;
    final p = n.payload ?? {};
    switch (n.type) {
      case 'job_post':
        return l10n.notif_job_posted_desc(p['jobTitle'] ?? 'Job');
      case 'job_apply':
      case 'Job_Application':
        return l10n.notif_job_apply_desc(p['jobTitle'] ?? 'Job');
      case 'skill_verified':
      case 'skill_verification':
        return l10n.notif_skill_verified_desc(p['skillName'] ?? 'Skill');
      case 'payment':
        return l10n.notif_payment_success_desc(p['planName'] ?? 'Plan');
      case 'login':
        final timeStr = "${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}";
        return l10n.notif_login_desc(timeStr);
      case 'logout':
        return l10n.notif_logout_desc;
      default:
        return n.description; // Fallback to DB description
    }
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.darkGreen, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.notifications,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                if (!_isLoading && _unreadCount > 0)
                  Text(
                    AppLocalizations.of(context)!.notifications_unread(_unreadCount),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGreen.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              if (!_isLoading && _unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _markingAllRead
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkGreen),
                        )
                      : TextButton.icon(
                          onPressed: _markAllAsRead,
                          icon: const Icon(Icons.done_all_rounded,
                              size: 17, color: AppColors.darkGreen),
                          label: Text(
                            AppLocalizations.of(context)!.mark_all_read,
                            style: const TextStyle(
                              color: AppColors.darkGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor:
                                AppColors.darkGreen.withOpacity(0.08),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                ),
            ],
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _fetchNotifications,
                    color: AppColors.darkGreen,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, index) => _NotificationTile(
                        notification: _notifications[index],
                        getIcon:    _getIcon,
                        getColor:   _getColor,
                        formatTime: (dt) => _formatTime(context, dt),
                        localizedTitle: (n) => _localizedTitle(context, n),
                        localizedDescription: (n) => _localizedDescription(context, n),
                        onTap: () async {
                          await _markAsRead(index);
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationDetailScreen(
                                notification: _notifications[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkGreen.withOpacity(0.08),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 36,
              color: AppColors.darkGreen.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_notifications_title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.no_notifications_subtitle,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  NOTIFICATION TILE
// ─────────────────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final NotificationModel           notification;
  final IconData Function(String)   getIcon;
  final Color    Function(String)   getColor;
  final String   Function(DateTime) formatTime;
  final String   Function(NotificationModel) localizedTitle;
  final String   Function(NotificationModel) localizedDescription;
  final VoidCallback                onTap;

  const _NotificationTile({
    required this.notification,
    required this.getIcon,
    required this.getColor,
    required this.formatTime,
    required this.localizedTitle,
    required this.localizedDescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color    = getColor(notification.type);
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread
                ? color.withOpacity(0.25)
                : Colors.grey.shade100,
            width: isUnread ? 1.2 : 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(isUnread ? 0.05 : 0.03),
              blurRadius: isUnread ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon bubble with unread dot ──────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(getIcon(notification.type),
                      color: color, size: 22),
                ),
                if (isUnread)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          localizedTitle(notification),
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatTime(notification.createdAt),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedDescription(notification),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  // ── Type badge ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _typeLabel(context, notification.type),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'login':          return l10n.type_login;
      case 'logout':         return l10n.type_logout;
      case 'payment':        return l10n.type_payment;
      case 'job_post':       return l10n.type_job_post;
      case 'job_apply':      return l10n.type_application;
      case 'skill_verified': return l10n.type_skill_verified;
      case 'chat':           return l10n.type_message;
      default:               return l10n.type_general;
    }
  }
}