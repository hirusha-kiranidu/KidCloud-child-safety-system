class ChildModel {
  final int id;
  final String name;
  final int age;
  final String avatar;
  final int colorHex;
  final int battery;
  final int steps;
  final String status;
  final String last;
  final String school;
  final String device;
  final bool online;
  final String teacherName;
  final String teacherPhone;
  final String parentPhone;
  final String gender;

  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.avatar,
    required this.colorHex,
    required this.battery,
    required this.steps,
    required this.status,
    required this.last,
    required this.school,
    required this.device,
    required this.online,
    this.teacherName = '',
    this.teacherPhone = '',
    this.parentPhone = '',
    this.gender = '',
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? 'Unknown',
      age: (json['age'] as num?)?.toInt() ?? 0,
      avatar: json['avatar'] as String? ?? '🧒',
      colorHex: json['color_hex'] != null
          ? int.tryParse(json['color_hex'].toString()) ?? 0xFF00E5C8
          : 0xFF00E5C8,
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Unknown',
      last: json['last_seen'] as String? ?? '—',
      school: json['school'] as String? ?? '—',
      device: json['device_id'] as String? ?? '—',
      online: json['online'] as bool? ?? false,
      teacherName: json['teacher_name'] as String? ?? '',
      teacherPhone: json['teacher_phone'] as String? ?? '',
      parentPhone: json['parent_phone'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'avatar': avatar,
        'color_hex': colorHex.toString(),
        'school': school,
        'device_id': device,
        'teacher_name': teacherName,
        'teacher_phone': teacherPhone,
        'parent_phone': parentPhone,
        'gender': gender,
      };

  ChildModel copyWith({
    String? name,
    int? age,
    String? avatar,
    int? colorHex,
    int? battery,
    int? steps,
    String? status,
    String? last,
    String? school,
    String? device,
    bool? online,
    String? teacherName,
    String? teacherPhone,
    String? parentPhone,
    String? gender,
  }) {
    return ChildModel(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      colorHex: colorHex ?? this.colorHex,
      battery: battery ?? this.battery,
      steps: steps ?? this.steps,
      status: status ?? this.status,
      last: last ?? this.last,
      school: school ?? this.school,
      device: device ?? this.device,
      online: online ?? this.online,
      teacherName: teacherName ?? this.teacherName,
      teacherPhone: teacherPhone ?? this.teacherPhone,
      parentPhone: parentPhone ?? this.parentPhone,
      gender: gender ?? this.gender,
    );
  }
}

final kidsData = [
  ChildModel(
    id: 1,
    name: 'Emma',
    age: 9,
    avatar: '👧',
    colorHex: 0xFF00E5C8,
    battery: 78,
    steps: 4320,
    status: 'At School',
    last: '2 min ago',
    school: 'SK Damansara',
    device: 'KC-A2F3',
    online: true,
    teacherName: 'Mrs. Priya Nair',
    teacherPhone: '+60 11-111 2222',
    parentPhone: '+60 12-345 6789',
    gender: 'Girl',
  ),
  ChildModel(
    id: 2,
    name: 'Liam',
    age: 7,
    avatar: '👦',
    colorHex: 0xFF2B7EFF,
    battery: 45,
    steps: 2100,
    status: 'At Home',
    last: 'Just now',
    school: 'SK Damansara',
    device: 'KC-B8C1',
    online: true,
    teacherName: 'Mr. Ravi Kumar',
    teacherPhone: '+60 11-333 4444',
    parentPhone: '+60 12-999 8888',
    gender: 'Boy',
  ),
];

class ZoneModel {
  final int id;
  final int childId;
  final String name;
  final String icon;
  final String start;
  final String end;
  final int radius;
  final int colorHex;
  final double? lat;
  final double? lng;
  bool active;
  bool inZone;

  ZoneModel({
    required this.id,
    required this.childId,
    required this.name,
    required this.icon,
    required this.start,
    required this.end,
    required this.radius,
    required this.colorHex,
    this.lat,
    this.lng,
    this.active = true,
    this.inZone = true,
  });
}
