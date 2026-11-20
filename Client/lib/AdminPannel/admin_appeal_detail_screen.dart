import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'package:client/Server/Services/NotificationService.dart';

class AdminAppealDetailScreen extends StatelessWidget {
  final AppUser user;

  const AdminAppealDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final TextEditingController reasonCtrl = TextEditingController();
    final repo = UserRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Appeal Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card('User Email', user.email),
            _card('Block Reason', user.blockReason ?? ''),
            _card('Appeal Message', user.appealMessage ?? ''),

            const SizedBox(height: 16),

            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Admin Message (required)',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenCeladon,
                    ),
                    child: const Text('APPROVE', style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      await repo.updateByUserId(
                        user.userId,
                        user.copyWith(
                          isBlocked: false,
                          appealStatus: AppealStatus.approved,
                          unblockReason: reasonCtrl.text,
                          unblockedAt: DateTime.now(),
                        ),
                      );

                      await NotificationService.sendToUser(
                        targetUserId: user.userId,
                        type: 'appeal_approved',
                        title: 'Appeal Approved',
                        description: reasonCtrl.text,
                        route: '/home',
                      );

                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                    ),
                    child: const Text('REJECT', style: TextStyle(color: Colors.white),),
                    onPressed: () async {
                      await repo.updateByUserId(
                        user.userId,
                        user.copyWith(
                          appealStatus: AppealStatus.rejected,
                          unblockReason: reasonCtrl.text,
                        ),
                      );

                      await NotificationService.sendToUser(
                        targetUserId: user.userId,
                        type: 'appeal_rejected',
                        title: 'Appeal Rejected',
                        description: reasonCtrl.text,
                        route: '/blocked',
                      );

                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    );
  }
}
