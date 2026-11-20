import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AuthService _authService = AuthService();
  bool _loading = false;

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(l10n.del_account_dialog_title),
        content: Text(l10n.del_account_dialog_msg),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      // 🔒 prevent auth-guard auto navigation
      authProvider.isDeletingAccount = true;

      final user = authProvider.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.del_account_not_auth)),
        );
        return;
      }

      await _authService.deleteCurrentAccount(user.userId);

      await context.read<AuthProvider>().logout();
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.del_account_error)),
        );
      }
    } finally {
      if (mounted) {
        context.read<AuthProvider>().isDeletingAccount = false;
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                l10n.del_account_title,
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.del_account_warning,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(l10n.del_account_body),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _loading ? null : _confirmDelete,
                    child: Text(
                      l10n.del_account_btn,
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
