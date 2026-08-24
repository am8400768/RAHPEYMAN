import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userOrEmailController = TextEditingController();
  bool _isSending = false;

  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF00BFA5);

  @override
  void dispose() {
    _userOrEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);

    // mock
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSending = false);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'ارسال لینک بازیابی',
              style: TextStyle(
                fontFamily: 'IRANSansWeb',
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            content: const Text(
              'لینک بازیابی رمز عبور ارسال شد.\n'
              '(در این مرحله به‌صورت آزمایشی/mock است)',
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                height: 1.6,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'باشه',
                  style: TextStyle(fontFamily: 'IRANSansWeb'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'فراموشی رمز عبور',
            style: TextStyle(fontFamily: 'IRANSansWeb'),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'بازیابی رمز عبور',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IRANSansWeb',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نام کاربری یا ایمیل خود را وارد کنید',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _userOrEmailController,
                        style: const TextStyle(fontFamily: 'Vazirmatn'),
                        decoration: InputDecoration(
                          labelText: 'نام کاربری / ایمیل',
                          labelStyle: const TextStyle(fontFamily: 'Vazirmatn'),
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1.6,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'این فیلد الزامی است';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'ارسال لینک بازیابی',
                                  style: TextStyle(
                                    fontFamily: 'IRANSansWeb',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
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
}
