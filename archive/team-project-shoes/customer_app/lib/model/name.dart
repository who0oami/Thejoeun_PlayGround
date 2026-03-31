//  name Model
/*
  Create: 31/12/2025 12:56, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
  Desc: name Model

  DateTime MUST converted using value.toIso8601String()
  DateTime MUST converted using value: (json['value'] as num).toDouble()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Name {
  final int pid;
  final String name;

  Name({
    required this.pid,
    required this.name,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      pid: json['pid'] is int
          ? json['pid']
          : int.parse(json['pid'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }
}
