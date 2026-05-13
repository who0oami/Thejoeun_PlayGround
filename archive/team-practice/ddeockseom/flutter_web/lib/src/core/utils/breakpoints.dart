class Breakpoint {
  const Breakpoint({required this.start, required this.end, required this.name});

  final double start;
  final double end;
  final String name;

  bool contains(double width) => width >= start && width <= end;
}

const List<Breakpoint> authBreakpoints = [
  Breakpoint(start: 0, end: 450, name: 'MOBILE'),
  Breakpoint(start: 451, end: 800, name: 'TABLET'),
  Breakpoint(start: 801, end: 1920, name: 'DESKTOP'),
  Breakpoint(start: 1921, end: double.infinity, name: '4K'),
];

Breakpoint breakpointForWidth(double width) {
  return authBreakpoints.firstWhere(
    (breakpoint) => breakpoint.contains(width),
    orElse: () => authBreakpoints.last,
  );
}
