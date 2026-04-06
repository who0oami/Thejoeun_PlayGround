import 'package:dda/components/login_form_card.dart';
import 'package:dda/components/login_hero_panel.dart';
import 'package:dda/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  LoginController _getController() {
    if (Get.isRegistered<LoginController>()) {
      return Get.find<LoginController>();
    }
    return Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    _getController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9FE),
              Color(0xFFEFF3FB),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;
              final horizontalPadding = isWide ? 28.0 : 18.0;
              final verticalPadding = isWide ? 24.0 : 16.0;
              final viewportHeight =
                  constraints.maxHeight - (verticalPadding * 2);
              final desktopHeight =
                  viewportHeight < 860 ? 860.0 : viewportHeight;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 1520,
                      minHeight: isWide
                          ? desktopHeight
                          : (viewportHeight > 0 ? viewportHeight : 0),
                    ),
                    child: isWide
                        ? SizedBox(
                            height: desktopHeight,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                Expanded(
                                  flex: 11,
                                  child: LoginHeroPanel(),
                                ),
                                SizedBox(width: 28),
                                Expanded(
                                  flex: 9,
                                  child: _DesktopLoginPanel(),
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LoginHeroPanel(),
                              SizedBox(height: 22),
                              LoginFormCard(),
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

class _DesktopLoginPanel extends StatelessWidget {
  const _DesktopLoginPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FD),
        borderRadius: BorderRadius.circular(36),
      ),
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: const Center(
          child: LoginFormCard(),
        ),
      ),
    );
  }
}
