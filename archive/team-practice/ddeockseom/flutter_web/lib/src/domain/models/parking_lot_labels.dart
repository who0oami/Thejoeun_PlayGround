class ParkingLotLabels {
  static const List<String> names = [
    '\uB69D\uC12C \uC81C1 \uC8FC\uCC28\uC7A5',
    '\uB69D\uC12C \uC81C2 \uC8FC\uCC28\uC7A5',
    '\uB69D\uC12C \uC81C3 \uC8FC\uCC28\uC7A5',
    '\uB69D\uC12C \uC81C4 \uC8FC\uCC28\uC7A5',
  ];

  static String forIndex(int index) {
    if (index < 0 || index >= names.length) {
      return '\uB69D\uC12C';
    }
    return names[index];
  }
}
