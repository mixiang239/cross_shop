import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../providers/user_provider.dart';

class AddressEditScreen extends StatefulWidget {
  final String? addressId;
  const AddressEditScreen({super.key, this.addressId});

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _detailCtrl;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    Address? existing;
    if (widget.addressId != null) {
      existing = user.addresses.where((a) => a.id == widget.addressId).firstOrNull;
    }
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _provinceCtrl = TextEditingController(text: existing?.province ?? '');
    _cityCtrl = TextEditingController(text: existing?.city ?? '');
    _districtCtrl = TextEditingController(text: existing?.district ?? '');
    _detailCtrl = TextEditingController(text: existing?.detail ?? '');
    _isDefault = existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _provinceCtrl.dispose();
    _cityCtrl.dispose(); _districtCtrl.dispose(); _detailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final user = context.read<UserProvider>();
    final id = widget.addressId ?? 'a${DateTime.now().millisecondsSinceEpoch}';
    final addr = Address(
      id: id, name: _nameCtrl.text, phone: _phoneCtrl.text,
      province: _provinceCtrl.text, city: _cityCtrl.text,
      district: _districtCtrl.text, detail: _detailCtrl.text,
      isDefault: _isDefault,
    );
    if (widget.addressId != null) {
      user.updateAddress(addr);
    } else {
      user.addAddress(addr);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.addressId != null;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(isEdit ? '编辑地址' : '新建地址')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _Field(label: '收货人', controller: _nameCtrl),
        _Field(label: '手机号', controller: _phoneCtrl, keyboardType: TextInputType.phone),
        _Field(label: '省份', controller: _provinceCtrl),
        _Field(label: '城市', controller: _cityCtrl),
        _Field(label: '区/县', controller: _districtCtrl),
        _Field(label: '详细地址', controller: _detailCtrl, maxLines: 2),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('设为默认地址', style: TextStyle(fontSize: 14)),
          value: _isDefault, onChanged: (v) => setState(() => _isDefault = v),
          activeColor: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _save, child: const Text('保存')),
      ]),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  const _Field({required this.label, required this.controller, this.keyboardType, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller, keyboardType: keyboardType, maxLines: maxLines ?? 1,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
