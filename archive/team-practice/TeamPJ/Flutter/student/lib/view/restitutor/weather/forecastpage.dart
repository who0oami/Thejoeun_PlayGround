import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/vm/restitutor/color_provider.dart';
import 'package:student/vm/restitutor/forecast.dart';

//  Weather widget
/*
  Created in: 20/01/2026 10:24
  Author: Chansol, Park
  Description: Weather widget
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          18/01/2026 15:35, 'Point 1, Forecast added', Creator: Chansol, Park
          19/01/2026 15:27, 'Point 2, Widget's width default set to MediaQuery.of(context).size.width', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

class Forecastpage extends ConsumerStatefulWidget {
  const Forecastpage({super.key});

  @override
  ConsumerState<Forecastpage> createState() => _ForecastpageState();
}

class _ForecastpageState extends ConsumerState<Forecastpage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animY;

  @override
  void initState() {
    super.initState();
    //  Animation for color breathing
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    //  Animation for floating images
    animY = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecolor = ref.watch(
      forecastColorProvider,
    ); //  when forecast Changed
    final notifier = ref.watch(forecastProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('예보')),
      body: notifier.when(
        data: (data) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final safeCount = data.length < forecolor.length ? data.length : forecolor.length;
              return Container(
                color: Colors.transparent,
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: safeCount,
                  itemBuilder: (context, index) {
                    final foreColorsets =
                        Color.lerp(
                          //  Set color lerps for gradient
                          forecolor[index][0],
                          forecolor[index][1],
                          Curves.easeInOut.transform(
                            _animationController.value,
                          ),
                        ) ??
                        forecolor[index][0];
                    return Material(
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        tileColor: foreColorsets,
                        leading: Transform.translate(
                          offset: Offset(0, (animY.value)),
                          child: image(data[index]),
                        ),
                        title: Text('${index + 1}시간 후: ${data[index]}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  } //  build

  //  Widget
  Widget image(String resultdata, {double? w = 50, double? h = 50}) {
    String assetPath;
    switch (resultdata) {
      case '맑음':
        assetPath = 'images/sunny.png';
        break;
      case '흐림':
        assetPath = 'images/cloud.png';
        break;
      case '비':
        assetPath = 'images/rain.png';
        break;
      case '눈':
        assetPath = 'images/snow.png';
        break;
      default:
        assetPath = 'images/error.png';
    }
    return Image.asset(assetPath, width: w, height: h, fit: BoxFit.contain);
  }
} //  class
