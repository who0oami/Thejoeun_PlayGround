import 'package:get/get.dart';

import '../../../data/repositories/http_dashboard_repository.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardRepository>(
      HttpDashboardRepository.new,
      fenix: true,
    );
    Get.lazyPut<DashboardViewModel>(
      () => DashboardViewModel(Get.find<DashboardRepository>()),
      fenix: true,
    );
  }
}
