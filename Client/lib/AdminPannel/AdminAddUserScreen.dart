import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Services/AuthService.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/widgets/SocialLoginButton.dart';
import 'package:client/widgets/custom_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:client/l10n/app_localizations.dart';


class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({super.key});

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _authService  = AuthService();

  bool     _isLoading  = false;
  UserRole _selectedRole = UserRole.admin; // sensible default

  // Roles the admin is allowed to assign
  static const List<_RoleOption> _roleOptions = [
    _RoleOption(
      role:        UserRole.admin,
      label:       'Admin',
      description: 'Full platform access',
      icon:        Icons.admin_panel_settings_rounded,
      color:       Color(0xFFE53935),
    ),
   
  ];

  // ── Validation ─────────────────────────────────────────────────────────────

  bool _isValidEmail(String e) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(e);

  bool _isValidPassword(String p) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(p);

  // ── Guard: only admins may use this screen ─────────────────────────────────
  bool get _callerIsAdmin {
    final role  = context.read<AuthProvider>().user?.role;
    return role == UserRole.admin;
  }

  // ── Create user ────────────────────────────────────────────────────────────
  Future<void> _createUser() async {
    // Role guard — extra safety net in case someone navigates here directly
    final l10n = AppLocalizations.of(context)!;
    if (!_callerIsAdmin) {
      showCustomToast(l10n.only_admin_create_user_toast, context);
      return;
    }

    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirm  = _confirmCtrl.text.trim();

    // ── Validate ─────────────────────────────────────────────────────────────
    if (email.isEmpty) {
      showCustomToast(l10n.email_required_error, context); return;
    }
    if (!_isValidEmail(email)) {
      showCustomToast(l10n.invalid_email_error, context); return;
    }
    if (password.isEmpty) {
      showCustomToast(l10n.password_required_error, context); return;
    }
    if (!_isValidPassword(password)) {
      showCustomToast(
        l10n.invalid_password_format_error,
        context,
      );
      return;
    }
    if (confirm.isEmpty) {
      showCustomToast(l10n.confirm_password_required_error, context); return;
    }
    if (password != confirm) {
      showCustomToast(l10n.passwords_do_not_match_error, context); return;
    }

    setState(() => _isLoading = true);

    try {
      // Use AuthService.signUp — it creates the Firebase Auth user,
      // sends a verification email, and saves the AppUser to Firestore.
      final newUser = await _authService.signUp(
        name:     l10n.admin_created_user_name,
        email:    email.toLowerCase(),
        phone:    '',
        password: password,
        role:     _selectedRole,
        context:  context,
      );

      if (newUser != null) {
        showCustomToast(
          l10n.user_created_success_msg(_selectedRole.name),
          context,
        );
        // Clear fields so admin can add another user
        _emailCtrl.clear();
        _passwordCtrl.clear();
        _confirmCtrl.clear();
        setState(() => _selectedRole = UserRole.admin); // reset to default
      }
    } catch (e) {
      if (mounted) showCustomToast(e.toString(), context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Block non-admins immediately
    if (!_callerIsAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.access_denied_admin,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.darkGreen),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.add_new_user_title,
          style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decorative background circle — same as EmailAuth
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: size.width / 1.1,
              height: size.height / 1.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withOpacity(0.09),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.02),

                  // ── Header ────────────────────────────────────────────────
                  Text(
                    AppLocalizations.of(context)!.create_user_account_header,
                    style: TextStyle(
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.create_user_account_desc,
                    style: TextStyle(
                      fontSize: size.width * 0.036,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── Email ─────────────────────────────────────────────────
                  customTextField(
                    AppLocalizations.of(context)!.email_label,
                    _emailCtrl,
                    TextInputType.emailAddress,
                  ),
                  SizedBox(height: size.height * 0.02),

                  // ── Password ──────────────────────────────────────────────
                  customTextField(
                    AppLocalizations.of(context)!.password_label,
                    _passwordCtrl,
                    TextInputType.text,
                    isPassword: true,
                  ),
                  SizedBox(height: size.height * 0.02),

                  // ── Confirm Password ──────────────────────────────────────
                  customTextField(
                    AppLocalizations.of(context)!.confirm_password_label,
                    _confirmCtrl,
                    TextInputType.visiblePassword,
                    isPassword: true,
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── Role Selector ─────────────────────────────────────────
                  Text(
                    AppLocalizations.of(context)!.assign_role_label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role cards
                  ...(_roleOptions.map((opt) => _RoleCard(
                        option:     opt,
                        isSelected: _selectedRole == opt.role,
                        onTap: () =>
                            setState(() => _selectedRole = opt.role),
                      ))),

                  SizedBox(height: size.height * 0.04),

                  // ── Selected role summary pill ────────────────────────────
                  _SelectedRolePill(
                    option: _roleOptions.firstWhere(
                      (o) => o.role == _selectedRole,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // ── Create User Button ────────────────────────────────────
                  customButton(
                    text:      AppLocalizations.of(context)!.create_user_btn,
                    onPressed: _isLoading ? null : _createUser,
                    size:      size,
                    isLoading: _isLoading,
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROLE OPTION MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _RoleOption {
  final UserRole role;
  final String   label;
  final String   description;
  final IconData icon;
  final Color    color;

  const _RoleOption({
    required this.role,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROLE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final _RoleOption option;
  final bool        isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withOpacity(.07)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? option.color
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withOpacity(.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? option.color : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Label + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.role == UserRole.admin
                        ? AppLocalizations.of(context)!.admin_role_label
                        : option.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? option.color
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.role == UserRole.admin
                        ? AppLocalizations.of(context)!.admin_role_desc
                        : option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Container(
                      key: const ValueKey('checked'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    )
                  : Container(
                      key: const ValueKey('unchecked'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1.5),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SELECTED ROLE SUMMARY PILL
// ─────────────────────────────────────────────────────────────────────────────
class _SelectedRolePill extends StatelessWidget {
  final _RoleOption option;
  const _SelectedRolePill({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: option.color.withOpacity(.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: option.color.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_ind_rounded,
              size: 16, color: option.color),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.registered_as_label('').replaceFirst(':', '').trim() + ': ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            option.role == UserRole.admin
                ? AppLocalizations.of(context)!.admin_role_label
                : option.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: option.color,
            ),
          ),
        ],
      ),
    );
  }
}