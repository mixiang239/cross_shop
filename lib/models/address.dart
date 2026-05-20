class Address {
  final String id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;

  const Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
  });

  String get fullAddress => '$province$city$district$detail';

  Address copyWith({
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
