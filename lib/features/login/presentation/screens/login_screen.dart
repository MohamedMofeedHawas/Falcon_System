import 'package:falcon_system/core/constants/app_colors.dart';
import 'package:falcon_system/core/constants/app_fonts.dart';
import 'package:falcon_system/core/constants/app_strings.dart';
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/widgets/custom_text_field.dart';
import 'package:falcon_system/features/admin/presentation/screens/admin_setup_screen.dart';
import 'package:falcon_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final password = _passwordCtrl.text;

      // ✅ Search by email → supports multiple admins
      final admin = HiveService.getAdminByEmail(email);

      if (admin == null) {
        _snack(
          'لا يوجد حساب مرتبط بهذا البريد الإلكتروني',
          AppColors.danger,
          icon: Icons.error_outline,
        );
        return;
      }

      if (password == (admin.password ?? '')) {
        HiveService.setCurrentAdminEmail(email); // track current admin
        _snack(
          AppStrings.loginSuccess,
          AppColors.success,
          icon: Icons.check_circle,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const DashboardScreen(),
            transitionsBuilder: (_, a, _, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        _snack(
          AppStrings.invalidCredentials,
          AppColors.danger,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      _snack('خطأ: $e', AppColors.danger);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, Color color, {IconData? icon}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                msg,
                style: AppFonts.labelLarge.copyWith(color: AppColors.textWhite),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppStrings.login),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_outlined,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      'مرحبًا بك',
                      textAlign: TextAlign.center,
                      style: AppFonts.headline5.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppFonts.bold,
                      ),
                    ),
                     const SizedBox(width: 8),
                    Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.amber, // 🔥 أصفر
                      size: 28,
                    ),
                  
                   
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'أدخل بياناتك للدخول إلى النظام',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 36),
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  prefixIcon: const Icon(Icons.alternate_email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'الرجاء إدخال البريد الإلكتروني'
                      : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordCtrl,
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'الرجاء إدخال كلمة المرور'
                      : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textWhite,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.signIn,
                                style: AppFonts.labelLarge.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: AppFonts.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) => const AdminSetupScreen(),
                          transitionsBuilder: (_, a, _, c) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(a),
                            child: c,
                          ),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        overlayColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.createAccount,
                        style: AppFonts.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppFonts.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
