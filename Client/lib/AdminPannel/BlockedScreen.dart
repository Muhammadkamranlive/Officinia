import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import '../l10n/app_localizations.dart';

class BlockedScreen extends StatefulWidget {
  final AppUser user;

  const BlockedScreen({super.key, required this.user});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  late AppUser user;
  final _appealController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  bool get hasAppealed => user.appealStatus != AppealStatus.none;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blocked_account_title,
            style: const TextStyle(color: AppColors.green, fontSize: 18)),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.block, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              Text(
                l10n.blocked_acc_msg,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _reasonCard(l10n),
              const SizedBox(height: 24),
              hasAppealed ? _appealStatusView(l10n) : _appealForm(l10n),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reasonCard(AppLocalizations l10n) {
    return Text(user.blockReason ?? l10n.no_reason_provided);
  }

  Widget _appealForm(AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _appealController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: l10n.explain_unblock_hint,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitAppeal,
          child: isSubmitting
              ? const CircularProgressIndicator()
              : Text(l10n.submit_appeal_btn),
        ),
      ],
    );
  }

  Widget _appealStatusView(AppLocalizations l10n) {
    return Text(
      user.appealStatus == AppealStatus.pending
          ? l10n.appeal_under_review_msg
          : user.appealStatus == AppealStatus.approved
              ? l10n.appeal_approved_msg
              : l10n.appeal_rejected_msg,
    );
  }

  Future<void> _submitAppeal() async {
    final message = _appealController.text.trim();
    if (message.isEmpty) return;

    setState(() => isSubmitting = true);

    final repo = UserRepository();

    final updatedUser = user.copyWith(
      appealMessage: message,
      appealStatus: AppealStatus.pending,
      appealAt: DateTime.now(),
    );

    await repo.updateByUserId(user.userId, updatedUser);

    setState(() {
      user = updatedUser;
      isSubmitting = false;
    });
  }
}
