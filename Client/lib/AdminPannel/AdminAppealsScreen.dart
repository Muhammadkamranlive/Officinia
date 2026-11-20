import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/UserRepository.dart';
import 'admin_appeal_detail_screen.dart';

class AdminAppealsScreen extends StatelessWidget {
  const AdminAppealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = UserRepository();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.admin_appeals_title)),
      body: FutureBuilder<List<AppUser>>(
        future: repo.getPendingAppeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.no_pending_appeals_msg));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final user = users[i];

              return ListTile(
                leading: const Icon(Icons.report),
                title: Text(user.email),
                subtitle: Text(
                  user.appealMessage ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminAppealDetailScreen(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
