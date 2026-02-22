class SettingModel {
  final int CGST;
  final int SGST;

  SettingModel({required this.CGST, required this.SGST});

  factory SettingModel.fromJson(Map<String, dynamic> json) {
    return SettingModel(CGST: json['CGST'] as int, SGST: json['SGST'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'CGST': CGST, 'SGST': SGST};
  }

  SettingModel copyWith({int? CGST, int? SGST}) {
    return SettingModel(CGST: CGST ?? this.CGST, SGST: SGST ?? this.SGST);
  }
}
