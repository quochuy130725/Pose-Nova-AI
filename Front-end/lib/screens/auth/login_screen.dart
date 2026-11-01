import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lookbook_provider.dart';
import '../../providers/styling_request_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/language_switch_pill.dart';
import '../../widgets/technical_grid_background.dart';
import '../client_main_shell.dart';
import '../stylist_main_shell.dart';

/// Screen: Production Authentication (Login & Sign Up) with 1-Tap Quick Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController(text: 'alex.do@gmail.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController(text: '175');
  final TextEditingController _weightController = TextEditingController(text: '65');
  String _selectedRole = 'CLIENT'; // 'CLIENT' or 'STYLIST'

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _navigateToRoleShell(String role) {
    if (!mounted) return;
    if (role.toUpperCase() == 'STYLIST') {
      StylingRequestProvider.instance.fetchRequestsAndSelectActive();
      WalletProvider.instance.fetchMyWallet();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StylistMainShell()),
      );
    } else {
      LookbookProvider.instance.fetchLookbooks();
      StylingRequestProvider.instance.fetchRequestsAndSelectActive();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientMainShell()),
      );
    }
  }

  Future<void> _handlePrimarySubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.vermilion,
          content: Text('Vui lòng nhập địa chỉ email hợp lệ!'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.vermilion,
          content: Text('Mật khẩu phải có ít nhất 6 ký tự!'),
        ),
      );
      return;
    }

    if (_isSignUp) {
      final fullName = _fullNameController.text.trim();
      if (fullName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.vermilion,
            content: Text('Vui lòng nhập họ và tên của bạn!'),
          ),
        );
        return;
      }

      final success = await AuthProvider.instance.registerAccount(
        fullName: fullName,
        email: email,
        password: password,
        role: _selectedRole,
        heightCm: int.tryParse(_heightController.text),
        weightKg: int.tryParse(_weightController.text),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.ink,
            content: Text(
              'Tạo tài khoản $fullName (${_selectedRole == 'STYLIST' ? 'Stylist' : 'Khách hàng'}) thành công!',
              style: const TextStyle(color: AppColors.cyber, fontWeight: FontWeight.bold),
            ),
          ),
        );
        _navigateToRoleShell(_selectedRole);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.vermilion,
            content: Text(
              AuthProvider.instance.lastError ?? 'Đăng ký thất bại. Email có thể đã tồn tại!',
            ),
          ),
        );
      }
    } else {
      final success = await AuthProvider.instance.loginWithCredentials(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.ink,
            content: Text(
              '✓ Đăng nhập thành công với vai trò ${AuthProvider.instance.activeRole}!',
              style: const TextStyle(color: AppColors.cyber, fontWeight: FontWeight.bold),
            ),
          ),
        );
        _navigateToRoleShell(AuthProvider.instance.activeRole);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.vermilion,
            content: Text(
              AuthProvider.instance.lastError ?? 'Sai email hoặc mật khẩu. Vui lòng kiểm tra lại!',
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleQuickLogin(Map<String, String> account) async {
    final role = account['role'] ?? 'CLIENT';
    final name = account['name'] ?? 'Alex Đỗ';

    await AuthProvider.instance.demoLogin(role);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        duration: const Duration(seconds: 2),
        content: Text(
          'Đăng nhập nhanh tài khoản $name ($role) thành công!',
          style: const TextStyle(color: AppColors.cyber, fontWeight: FontWeight.bold),
        ),
      ),
    );
    _navigateToRoleShell(role);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AppLanguageController.instance,
        AuthProvider.instance,
      ]),
      builder: (context, _) {
        final t = AppLanguageController.instance.t;
        final auth = AuthProvider.instance;

        return Scaffold(
          backgroundColor: AppColors.canvas,
          body: TechnicalGridBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- 1. Top Bar: Stadium Pill + Language Switcher ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.hairlineBorder, width: 1.0),
                              boxShadow: AppColors.chipShadow,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.coralOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "PoseNova • Fashion Atelier '26",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.ink,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const LanguageSwitchPill(compact: true),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- Brand Title & Subtitle ---
                      Text(
                        'PoseNova AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Virtual Try-On & Managed Escrow Styling Atelier',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 2. AUTH CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.hairlineBorder,
                            width: 1.0,
                          ),
                          boxShadow: AppColors.modalShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sign In / Sign Up Mode Switcher Tabs
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isSignUp = false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                        decoration: BoxDecoration(
                                          color: !_isSignUp ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: !_isSignUp ? AppColors.chipShadow : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Đăng Nhập',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: !_isSignUp ? AppColors.ink : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isSignUp = true;
                                          if (_fullNameController.text.isEmpty) {
                                            _fullNameController.text = 'Người dùng mới';
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9),
                                        decoration: BoxDecoration(
                                          color: _isSignUp ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(999),
                                          boxShadow: _isSignUp ? AppColors.chipShadow : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Tạo Tài Khoản',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: _isSignUp ? AppColors.ink : AppColors.textMuted,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // If Sign Up: Full Name & Role Switcher
                            if (_isSignUp) ...[
                              Text(
                                'Họ và Tên:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _fullNameController,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Nhập họ tên của bạn...',
                                  filled: true,
                                  fillColor: const Color(0xFFFFF8F9),
                                  prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppColors.ink),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Role Selection (Client vs Stylist)
                              Text(
                                'Vai Trò Tài Khoản:',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedRole = 'CLIENT'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'CLIENT'
                                              ? AppColors.rosePinkSoft
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedRole == 'CLIENT'
                                                ? AppColors.coralOrange
                                                : AppColors.hairlineBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '👤 Khách Hàng (Client)',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: _selectedRole == 'CLIENT'
                                                ? AppColors.coralOrange
                                                : AppColors.ink,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedRole = 'STYLIST'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'STYLIST'
                                              ? const Color(0xFFFEF3C7)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedRole == 'STYLIST'
                                                ? const Color(0xFFD97706)
                                                : AppColors.hairlineBorder,
                                            width: 1.5,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Stylist Studio',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: _selectedRole == 'STYLIST'
                                                ? const Color(0xFFD97706)
                                                : AppColors.ink,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Email Input Field
                            Text(
                              t.authLabelUsername,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: 'nhap.email@posenova.ai',
                                filled: true,
                                fillColor: const Color(0xFFFFF8F9),
                                prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.ink),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Password Input Field
                            Text(
                              t.authLabelPassword,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Mật khẩu ít nhất 6 ký tự...',
                                filled: true,
                                fillColor: const Color(0xFFFFF8F9),
                                prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.ink),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.hairlineBorder),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Submit Button
                            GestureDetector(
                              onTap: auth.isLoading ? null : _handlePrimarySubmit,
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: AppColors.buttonShadow,
                                ),
                                alignment: Alignment.center,
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isSignUp ? Icons.how_to_reg : Icons.login,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isSignUp ? 'Tạo Tài Khoản Mới →' : 'Đăng Nhập Vào Hệ Thống →',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13.5,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Divider: "HOẶC ĐĂNG NHẬP NHANH 1-CHẠM"
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(color: AppColors.hairlineBorder, thickness: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'HOẶC ĐĂNG NHẬP NHANH',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(color: AppColors.hairlineBorder, thickness: 1),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // 1-Tap Quick Login Account Tiles
                            ...auth.knownAccounts.map((account) {
                              final isStylist = account['role'] == 'STYLIST';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () => _handleQuickLogin(account),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isStylist ? const Color(0xFFFFFBEB) : const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isStylist ? const Color(0xFFFDE68A) : AppColors.hairlineBorder,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(
                                            account['avatarUrl'] ??
                                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                account['name'] ?? '',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                              Text(
                                                '${account['email']} • ${account['subtitle']}',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10.5,
                                                  color: AppColors.textMuted,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isStylist ? AppColors.ink : AppColors.coralOrange,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            isStylist ? 'Stylist →' : 'Client →',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- 3. FOOTER SECURITY NOTICE ---
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.coralOrange),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                t.authFooterSecurity,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
