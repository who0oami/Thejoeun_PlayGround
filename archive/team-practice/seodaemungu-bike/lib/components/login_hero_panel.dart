import 'package:flutter/material.dart';

class LoginHeroPanel extends StatelessWidget {
  const LoginHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final titleSize = isWide ? 74.0 : 46.0;

        return Container(
          constraints: BoxConstraints(
            minHeight: isWide ? 880 : 500,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF032F1C),
            borderRadius: BorderRadius.circular(34),
          ),
          padding: EdgeInsets.fromLTRB(
            isWide ? 42 : 28,
            isWide ? 36 : 28,
            isWide ? 42 : 28,
            isWide ? 40 : 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _BrandHeader(),
              SizedBox(height: isWide ? 280 : 120),
              Text(
                '서울의 새로운\n흐름을 만나다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2.2,
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Text(
                  '따릉이 네오는 일상의 이동을 데이터 기반 인사이트와 연결해 더 스마트한 서울 모빌리티 경험을 제공합니다.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: isWide ? 18 : 15,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 38),
              const Wrap(
                spacing: 34,
                runSpacing: 18,
                children: [
                  _MetricTile(
                    value: '40,000+',
                    label: '운영 자전거',
                  ),
                  _MetricTile(
                    value: '12.4M',
                    label: '누적 친환경 이동거리',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '서울 모빌리티',
          style: TextStyle(
            color: Color(0xFFF5E4E8),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '도시의 흐름을 읽는 데이터',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 13,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;

  const _MetricTile({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xAAFFFFFF),
            fontSize: 13,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
