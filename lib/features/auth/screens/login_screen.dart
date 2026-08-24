import 'package:flutter/material.dart';

// TODO: مسیر Home واقعی پروژه‌تان را بگذارید
import '../../../modules/home/home_placeholder_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF00BFA5);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAsUser() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // فعلاً mock — بعداً به API/Session واقعی وصل می‌شود
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePlaceholderScreen()),
    );
  }

  Future<void> _loginAsGuest() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'ورود مهمان',
              style: TextStyle(
                fontFamily: 'IRANSansWeb',
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            content: const Text(
              'دسترسی مهمان محدود است.\n'
              'برخی امکانات فقط برای کاربران ثبت‌شده فعال می‌شود.\n\n'
              'آیا ادامه می‌دهید؟',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                height: 1.6,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'انصراف',
                  style: TextStyle(fontFamily: 'Vazirmatn'),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'ورود مهمان',
                  style: TextStyle(fontFamily: 'IRANSansWeb'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePlaceholderScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0D47A1),
                Color(0xFF1565C0),
                Color(0xFFF5F7FA),
              ],
              stops: [0.0, 0.35, 0.35],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minHeight: size.height * 0.75,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 20),
                      _buildLoginCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo/10.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.apartment_rounded,
                size: 42,
                color: primaryColor,
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'رهپیمان',
          style: TextStyle(
            fontFamily: 'Dima.Sogand.New',
            fontSize: 30,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'RAHPEYMAN',
          style: TextStyle(
            fontFamily: 'ETHNOCEN',
            fontSize: 13,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'همراه مهندسین از آموزش تا اجرا',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ورود به حساب',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IRANSansWeb',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'نام کاربری و رمز عبور را وارد کنید',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 22),

            // نام کاربری
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontFamily: 'Vazirmatn'),
              decoration: _inputDecoration(
                label: 'نام کاربری',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'نام کاربری را وارد کنید';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // رمز عبور
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _loginAsUser(),
              style: const TextStyle(fontFamily: 'Vazirmatn'),
              decoration: _inputDecoration(
                label: 'رمز عبور',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: primaryColor.withValues(alpha: 0.75),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'رمز عبور را وارد کنید';
                }
                if (value.length < 4) {
                  return 'رمز عبور حداقل ۴ کاراکتر باشد';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _isLoading ? null : _goToForgotPassword,
                child: const Text(
                  'فراموشی رمز عبور؟',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 13,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ورود کاربر
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loginAsUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'ورود کاربر',
                        style: TextStyle(
                          fontFamily: 'IRANSansWeb',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ورود مهمان
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _loginAsGuest,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accentColor,
                  side: const BorderSide(color: accentColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'ورود مهمان',
                  style: TextStyle(
                    fontFamily: 'IRANSansWeb',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        color: Colors.grey.shade700,
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
