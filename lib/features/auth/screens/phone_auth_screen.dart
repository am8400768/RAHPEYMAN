import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahpeyman/core/services/auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^(09\d{9}|\+989\d{9})$').hasMatch(phone)) {
      _showMessage('شماره موبایل معتبر وارد کنید.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.requestOtp(phone);
      if (!mounted) return;
      setState(() => _otpSent = true);
      _showMessage('کد تأیید ارسال شد.');
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showMessage('کد تأیید شش‌رقمی را وارد کنید.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.verifyOtp(
        phone: _phoneController.text.trim(),
        otp: otp,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ورود با شماره موبایل')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.phone_android_rounded,
              size: 72,
              color: Color(0xFF0D47A1),
            ),
            const SizedBox(height: 18),
            const Text(
              'برای مشاهده دوره‌ها و پرداخت اشتراک، شماره موبایل خود را تأیید کنید.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              enabled: !_otpSent && !_loading,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
              ],
              decoration: const InputDecoration(
                labelText: 'شماره موبایل',
                hintText: '09121234567',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _otpController,
                enabled: !_loading,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'کد تأیید',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_user_rounded),
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading
                  ? null
                  : (_otpSent ? _verifyOtp : _requestOtp),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_otpSent ? 'تأیید و ورود' : 'دریافت کد تأیید'),
            ),
            if (_otpSent)
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                          _otpSent = false;
                          _otpController.clear();
                        }),
                child: const Text('تغییر شماره موبایل'),
              ),
          ],
        ),
      ),
    );
  }
}
