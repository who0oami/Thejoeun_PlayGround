import 'package:flutter/material.dart';

@immutable
class DashboardPalette extends ThemeExtension<DashboardPalette> {
  const DashboardPalette({
    required this.pageBackground,
    required this.shellGradientStart,
    required this.shellGradientEnd,
    required this.sidebarBackground,
    required this.sidebarBorder,
    required this.cardBackground,
    required this.cardBorder,
    required this.panelBackground,
    required this.selectedItemBackground,
    required this.inputBackground,
    required this.iconBackground,
    required this.iconBorder,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.accentBlue,
    required this.accentCyan,
    required this.accentGreen,
    required this.accentRed,
    required this.progressTrack,
    required this.glowColor,
  });

  final Color pageBackground;
  final Color shellGradientStart;
  final Color shellGradientEnd;
  final Color sidebarBackground;
  final Color sidebarBorder;
  final Color cardBackground;
  final Color cardBorder;
  final Color panelBackground;
  final Color selectedItemBackground;
  final Color inputBackground;
  final Color iconBackground;
  final Color iconBorder;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final Color accentBlue;
  final Color accentCyan;
  final Color accentGreen;
  final Color accentRed;
  final Color progressTrack;
  final Color glowColor;

  factory DashboardPalette.light() {
    return const DashboardPalette(
      pageBackground: Color(0xFFF3F6FB),
      shellGradientStart: Color(0xFFF8FBFF),
      shellGradientEnd: Color(0xFFF1F5FB),
      sidebarBackground: Color(0xFFF7F9FC),
      sidebarBorder: Color(0xFFE5ECF5),
      cardBackground: Colors.white,
      cardBorder: Color(0xFFE8EEF7),
      panelBackground: Color(0xFFF7F9FC),
      selectedItemBackground: Colors.white,
      inputBackground: Colors.white,
      iconBackground: Colors.white,
      iconBorder: Color(0xFFE8EEF7),
      primaryText: Color(0xFF1B2430),
      secondaryText: Color(0xFF475569),
      mutedText: Color(0xFF94A3B8),
      accentBlue: Color(0xFF2F6BFF),
      accentCyan: Color(0xFF14CDE5),
      accentGreen: Color(0xFF16A34A),
      accentRed: Color(0xFFFF5A52),
      progressTrack: Color(0xFFE2E8F0),
      glowColor: Color(0x143B82F6),
    );
  }

  factory DashboardPalette.dark() {
    return const DashboardPalette(
      pageBackground: Color(0xFF08111F),
      shellGradientStart: Color(0xFF0B1528),
      shellGradientEnd: Color(0xFF09101D),
      sidebarBackground: Color(0xFF0A1424),
      sidebarBorder: Color(0xFF16243D),
      cardBackground: Color(0xFF0E1A2F),
      cardBorder: Color(0xFF162540),
      panelBackground: Color(0xFF101D33),
      selectedItemBackground: Color(0xFF12253D),
      inputBackground: Color(0xFF0D172A),
      iconBackground: Color(0xFF0E1A2F),
      iconBorder: Color(0xFF17304E),
      primaryText: Color(0xFFE8F2FF),
      secondaryText: Color(0xFFC1D2EA),
      mutedText: Color(0xFF8EA4C4),
      accentBlue: Color(0xFF37B7FF),
      accentCyan: Color(0xFF14E0FF),
      accentGreen: Color(0xFF5BFFB2),
      accentRed: Color(0xFFFF8A80),
      progressTrack: Color(0xFF1D314F),
      glowColor: Color(0x3314E0FF),
    );
  }

  @override
  DashboardPalette copyWith({
    Color? pageBackground,
    Color? shellGradientStart,
    Color? shellGradientEnd,
    Color? sidebarBackground,
    Color? sidebarBorder,
    Color? cardBackground,
    Color? cardBorder,
    Color? panelBackground,
    Color? selectedItemBackground,
    Color? inputBackground,
    Color? iconBackground,
    Color? iconBorder,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    Color? accentBlue,
    Color? accentCyan,
    Color? accentGreen,
    Color? accentRed,
    Color? progressTrack,
    Color? glowColor,
  }) {
    return DashboardPalette(
      pageBackground: pageBackground ?? this.pageBackground,
      shellGradientStart: shellGradientStart ?? this.shellGradientStart,
      shellGradientEnd: shellGradientEnd ?? this.shellGradientEnd,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      panelBackground: panelBackground ?? this.panelBackground,
      selectedItemBackground: selectedItemBackground ?? this.selectedItemBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      iconBackground: iconBackground ?? this.iconBackground,
      iconBorder: iconBorder ?? this.iconBorder,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      accentBlue: accentBlue ?? this.accentBlue,
      accentCyan: accentCyan ?? this.accentCyan,
      accentGreen: accentGreen ?? this.accentGreen,
      accentRed: accentRed ?? this.accentRed,
      progressTrack: progressTrack ?? this.progressTrack,
      glowColor: glowColor ?? this.glowColor,
    );
  }

  @override
  DashboardPalette lerp(ThemeExtension<DashboardPalette>? other, double t) {
    if (other is! DashboardPalette) {
      return this;
    }

    return DashboardPalette(
      pageBackground: Color.lerp(pageBackground, other.pageBackground, t)!,
      shellGradientStart: Color.lerp(shellGradientStart, other.shellGradientStart, t)!,
      shellGradientEnd: Color.lerp(shellGradientEnd, other.shellGradientEnd, t)!,
      sidebarBackground: Color.lerp(sidebarBackground, other.sidebarBackground, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      panelBackground: Color.lerp(panelBackground, other.panelBackground, t)!,
      selectedItemBackground:
          Color.lerp(selectedItemBackground, other.selectedItemBackground, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      iconBorder: Color.lerp(iconBorder, other.iconBorder, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      accentGreen: Color.lerp(accentGreen, other.accentGreen, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
    );
  }
}

extension DashboardPaletteContext on BuildContext {
  DashboardPalette get palette => Theme.of(this).extension<DashboardPalette>()!;
}
