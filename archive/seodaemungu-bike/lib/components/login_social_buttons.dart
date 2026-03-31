import 'package:flutter/material.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 18,
      alignment: WrapAlignment.center,
      children: const [
        _SocialButton(icon: Icons.account_circle_outlined),
        _SocialButton(icon: Icons.qr_code_2_rounded),
        _SocialButton(icon: Icons.inventory_2_outlined),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE2ECFB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD3DEEF)),
      ),
      child: Icon(
        icon,
        size: 32,
        color: const Color(0xFF15283D),
      ),
    );
  }
}
