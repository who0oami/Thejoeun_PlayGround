import 'package:dda/components/login_hero_panel.dart';
import 'package:dda/components/login_text_field.dart';
import 'package:dda/controller/login_controller.dart';
import 'package:dda/controller/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  SignupController _getController() {
    if (Get.isRegistered<SignupController>()) {
      return Get.find<SignupController>();
    }
    return Get.put(SignupController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = _getController();
    final asciiOnly = FilteringTextInputFormatter.allow(RegExp(r'[ -~]'));
    final emailOnly =
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._%+-]'));
    final codeOnly = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FE), Color(0xFFEFF3FB)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1520),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(flex: 11, child: LoginHeroPanel()),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 9,
                                child: _SignupFormCard(
                                  controller: controller,
                                  asciiOnly: asciiOnly,
                                  emailOnly: emailOnly,
                                  codeOnly: codeOnly,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const LoginHeroPanel(),
                              const SizedBox(height: 22),
                              _SignupFormCard(
                                controller: controller,
                                asciiOnly: asciiOnly,
                                emailOnly: emailOnly,
                                codeOnly: codeOnly,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SignupFormCard extends StatelessWidget {
  const _SignupFormCard({
    required this.controller,
    required this.asciiOnly,
    required this.emailOnly,
    required this.codeOnly,
  });

  final SignupController controller;
  final TextInputFormatter asciiOnly;
  final TextInputFormatter emailOnly;
  final TextInputFormatter codeOnly;

  static const _title = '\uD68C\uC6D0\uAC00\uC785';
  static const _subtitle = '\uD544\uC694\uD55C \uC815\uBCF4\uB97C \uC785\uB825\uD574\uC8FC\uC138\uC694.';
  static const _user = '\uC0AC\uC6A9\uC790';
  static const _admin = '\uAD00\uB9AC\uC790';
  static const _name = '\uC774\uB984';
  static const _gender = '\uC131\uBCC4';
  static const _male = '\uB0A8';
  static const _female = '\uC5EC';
  static const _email = '\uC774\uBA54\uC77C';
  static const _sendCode = '\uC778\uC99D\uBC88\uD638 \uC804\uC1A1';
  static const _code = '\uC778\uC99D\uBC88\uD638';
  static const _password = '\uBE44\uBC00\uBC88\uD638';
  static const _passwordHelp =
      '\uC601\uBB38 \uB300\uC18C\uBB38\uC790, \uC22B\uC790, \uD2B9\uC218\uBB38\uC790\uB97C \uD3EC\uD568\uD55C 10~16\uC790\uB9AC';
  static const _confirmPassword = '\uBE44\uBC00\uBC88\uD638 \uD655\uC778';
  static const _submit = '\uAC00\uC785\uD558\uAE30';
  static const _backToLogin =
      '\uC774\uBBF8 \uACC4\uC815\uC774 \uC788\uB098\uC694? \uB85C\uADF8\uC778\uC73C\uB85C \uB3CC\uC544\uAC00\uAE30';
  static const _emailHint = 'name@example.com';
  static const _nameHint = '\uD64D\uAE38\uB3D9';
  static const _codeHint = '6\uC790\uB9AC \uC22B\uC790';

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxWidth: 620),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFF),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F2342),
              blurRadius: 50,
              offset: Offset(0, 24),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: Text(
                _title,
                style: TextStyle(
                  color: Color(0xFF131A28),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              _title,
              style: TextStyle(
                color: Color(0xFF11233F),
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              _subtitle,
              style: TextStyle(
                color: Color(0xFF57657B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _RoleChip(
                    label: _user,
                    selected: controller.signupRole.value == LoginMode.user,
                    onTap: () => controller.changeRole(LoginMode.user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleChip(
                    label: _admin,
                    selected: controller.signupRole.value == LoginMode.admin,
                    onTap: () => controller.changeRole(LoginMode.admin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(_name, style: _labelStyle),
            const SizedBox(height: 12),
            LoginTextField(
              controller: controller.nameController,
              hintText: _nameHint,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            const Text(_gender, style: _labelStyle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RoleChip(
                    label: _male,
                    selected: controller.selectedGender.value == 'male',
                    onTap: () => controller.changeGender('male'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleChip(
                    label: _female,
                    selected: controller.selectedGender.value == 'female',
                    onTap: () => controller.changeGender('female'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(_email, style: _labelStyle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LoginTextField(
                    controller: controller.emailController,
                    hintText: _emailHint,
                    prefixIcon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [emailOnly],
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 72,
                  child: ElevatedButton(
                    onPressed: controller.isSendingCode.value
                        ? null
                        : controller.sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: controller.isSendingCode.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            _sendCode,
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _VerificationInfo(controller: controller),
            const SizedBox(height: 20),
            const Text(_code, style: _labelStyle),
            const SizedBox(height: 12),
            LoginTextField(
              controller: controller.codeController,
              hintText: _codeHint,
              prefixIcon: Icons.mark_email_read_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [codeOnly, LengthLimitingTextInputFormatter(6)],
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 20),
            const Text(_password, style: _labelStyle),
            const SizedBox(height: 8),
            const Text(
              _passwordHelp,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            LoginTextField(
              controller: controller.passwordController,
              hintText: 'Abcdef!123',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              inputFormatters: [asciiOnly, LengthLimitingTextInputFormatter(16)],
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 20),
            const Text(_confirmPassword, style: _labelStyle),
            const SizedBox(height: 12),
            LoginTextField(
              controller: controller.confirmPasswordController,
              hintText: 'Abcdef!123',
              prefixIcon: Icons.verified_user_outlined,
              obscureText: true,
              inputFormatters: [asciiOnly, LengthLimitingTextInputFormatter(16)],
              enableSuggestions: false,
              autocorrect: false,
            ),
            if (controller.errorMessage.value.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: Color(0xFFC24141),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF118847),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        _submit,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  _backToLogin,
                  style: TextStyle(
                    color: Color(0xFF118847),
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
}

class _VerificationInfo extends StatelessWidget {
  const _VerificationInfo({required this.controller});

  final SignupController controller;

  static const _beforeSend =
      '\uC774\uBA54\uC77C \uC8FC\uC18C\uB97C \uC785\uB825\uD55C \uB4A4 \uC778\uC99D\uBC88\uD638\uB97C \uBC1B\uC544\uC8FC\uC138\uC694.';
  static const _expiredTitle =
      '\uC778\uC99D\uBC88\uD638\uAC00 \uB9CC\uB8CC\uB418\uC5C8\uC2B5\uB2C8\uB2E4.';
  static const _sentTitle =
      '\uC778\uC99D\uBC88\uD638\uAC00 \uC804\uC1A1\uB418\uC5C8\uC2B5\uB2C8\uB2E4.';
  static const _expiredBody =
      '\uB2E4\uC2DC \uC694\uCCAD\uD55C \uD6C4 \uCD5C\uC2E0 \uC778\uC99D\uBC88\uD638\uB97C \uC785\uB825\uD574\uC8FC\uC138\uC694.';
  static const _sentBody =
      '\uC774\uBA54\uC77C\uB85C \uBC1B\uC740 6\uC790\uB9AC \uC778\uC99D\uBC88\uD638\uB97C \uC785\uB825\uD574\uC8FC\uC138\uC694.';
  static const _expired = '\uB9CC\uB8CC';

  @override
  Widget build(BuildContext context) {
    if (!controller.codeSent.value) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF51627B)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                _beforeSend,
                style: TextStyle(color: Color(0xFF51627B)),
              ),
            ),
          ],
        ),
      );
    }

    final expired = controller.isCodeExpired.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: expired ? const Color(0xFFFFF1F1) : const Color(0xFFE8F8EE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: expired ? const Color(0xFFF5B5B5) : const Color(0xFF97DDB3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: expired ? const Color(0xFFFDE2E2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              expired ? Icons.timer_off_rounded : Icons.mark_email_read_rounded,
              color: expired ? const Color(0xFFC24141) : const Color(0xFF118847),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? _expiredTitle : _sentTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: expired
                        ? const Color(0xFFC24141)
                        : const Color(0xFF0F5132),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expired ? _expiredBody : _sentBody,
                  style: const TextStyle(
                    color: Color(0xFF51627B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: expired ? const Color(0xFFFDE2E2) : Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              expired ? _expired : controller.countdownLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: expired
                    ? const Color(0xFFC24141)
                    : const Color(0xFF118847),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF118847) : const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF0D1B2A),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: Color(0xFF223125),
  fontSize: 15,
  fontWeight: FontWeight.w600,
);
