import 'package:flutter/material.dart';
import '../../models/coupon.dart';
import '../../services/mock_data_service.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  late List<Coupon> _coupons;

  @override
  void initState() {
    super.initState();
    _coupons = List<Coupon>.from(MockDataService.coupons);
  }

  void _claim(Coupon coupon) {
    final idx = _coupons.indexWhere((c) => c.id == coupon.id);
    if (idx != -1) {
      _coupons[idx] = Coupon(id: coupon.id, title: coupon.title, description: coupon.description,
        discount: coupon.discount, minSpend: coupon.minSpend, validUntil: coupon.validUntil, claimed: true);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('已领取「${coupon.title}」'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green.shade600, duration: const Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = _coupons.where((c) => !c.claimed && !c.isExpired).toList();
    final claimed = _coupons.where((c) => c.claimed).toList();
    final expired = _coupons.where((c) => c.isExpired && !c.claimed).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('优惠券中心')),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        if (available.isNotEmpty) ...[
          const Text('可领取', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...available.map((c) => _CouponCard(coupon: c, onClaim: () => _claim(c))),
          const SizedBox(height: 20),
        ],
        if (claimed.isNotEmpty) ...[
          const Text('已领取', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...claimed.map((c) => _CouponCard(coupon: c)),
          const SizedBox(height: 20),
        ],
        if (expired.isNotEmpty) ...[
          const Text('已过期', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 10),
          ...expired.map((c) => Opacity(opacity: 0.5, child: _CouponCard(coupon: c))),
        ],
      ]),
    );
  }
}

class _CouponCard extends StatefulWidget {
  final Coupon coupon;
  final VoidCallback? onClaim;
  const _CouponCard({required this.coupon, this.onClaim});

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<_CouponCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _claimed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleClaim() {
    if (_claimed) return;
    _ctrl.forward().then((_) {
      setState(() => _claimed = true);
      widget.onClaim?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.coupon;
    final isClaimed = _claimed || c.claimed;
    final isExpired = c.isExpired && !isClaimed;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 - (_ctrl.value * 0.05),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: isClaimed
              ? const LinearGradient(colors: [Color(0xFFFF8F00), Color(0xFFFFB300)])
              : isExpired ? const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFFE0E0E0)])
              : const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8F00)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isExpired ? null : [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('¥', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${c.discount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              ]),
              if (c.minSpend > 0)
                Text('满${c.minSpend.toStringAsFixed(0)}元可用', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
            ]),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 4),
              Text(c.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              const SizedBox(height: 4),
              Text('有效期至 ${c.validUntil.year}.${c.validUntil.month.toString().padLeft(2,'0')}.${c.validUntil.day.toString().padLeft(2,'0')}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
            ])),
            if (!isClaimed && !isExpired)
              GestureDetector(
                onTap: _handleClaim,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('立即领取', style: TextStyle(color: Color(0xFFFF6B35), fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            if (isClaimed) ...[
              const SizedBox(width: 16),
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
            ],
          ]),
        ),
      ),
    );
  }
}
