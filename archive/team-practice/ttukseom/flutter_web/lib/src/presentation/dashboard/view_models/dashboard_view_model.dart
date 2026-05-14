import 'package:get/get.dart';

import '../../../domain/models/dashboard_snapshot.dart';
import '../../../domain/models/parking_lot.dart';
import '../../../domain/repositories/dashboard_repository.dart';

enum DashboardSection {
  dashboard,
  notices,
  settings,
}

class DashboardViewModel extends GetxController {
  DashboardViewModel(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  final RxBool isLoading = true.obs;
  final Rxn<DashboardSnapshot> dashboardSnapshot = Rxn<DashboardSnapshot>();
  final RxInt selectedParkingLotIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxString noticeSearchQuery = ''.obs;
  final Rx<DashboardSection> currentSection = DashboardSection.dashboard.obs;

  DashboardSnapshot? get snapshot => dashboardSnapshot.value;

  List<ParkingLot> get filteredParkingLots {
    final lots = snapshot?.parkingLots ?? const <ParkingLot>[];
    final query = _normalizeSearchText(searchQuery.value);

    if (query.isEmpty) {
      return lots;
    }

    return lots.where((lot) {
      final name = _normalizeSearchText(lot.name);
      final compactName = name.replaceAll('\uC81C', '');
      return name.contains(query) || compactName.contains(query);
    }).toList(growable: false);
  }

  int get selectedIndex {
    final lots = filteredParkingLots;
    if (lots.isEmpty) {
      return 0;
    }

    final current = selectedParkingLotIndex.value;
    if (current < 0 || current >= lots.length) {
      return 0;
    }

    return current;
  }

  ParkingLot? get selectedParkingLot {
    final lots = filteredParkingLots;
    if (lots.isEmpty) {
      return null;
    }

    return lots[selectedIndex];
  }

  void selectParkingLot(int index) {
    final lots = filteredParkingLots;
    if (index < 0 || index >= lots.length) {
      return;
    }

    selectedParkingLotIndex.value = index;
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
    selectedParkingLotIndex.value = 0;
  }

  void updateNoticeSearchQuery(String value) {
    noticeSearchQuery.value = value;
  }

  void selectSection(DashboardSection section) {
    currentSection.value = section;
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    dashboardSnapshot.value = await _dashboardRepository.fetchDashboardSnapshot();
    searchQuery.value = '';
    noticeSearchQuery.value = '';
    selectedParkingLotIndex.value = 0;
    isLoading.value = false;
  }

  String _normalizeSearchText(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }
}
