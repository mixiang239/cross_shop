class Coupon {
  final String id;
  final String title;
  final String description;
  final double discount;
  final double minSpend;
  final DateTime validUntil;
  final bool claimed;

  const Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    this.minSpend = 0,
    required this.validUntil,
    this.claimed = false,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);
  int get remainDays => validUntil.difference(DateTime.now()).inDays;
}
