import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/mock_data_service.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _avatarUrl = '';
  final List<Address> _addresses = [];
  final Set<String> _favorites = {};
  final List<String> _browseHistory = [];

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get avatarUrl => _avatarUrl;
  List<Address> get addresses => List.unmodifiable(_addresses);
  int get favoriteCount => _favorites.length;
  List<String> get browseHistory => List.unmodifiable(_browseHistory);

  List<Address> get sortedAddresses {
    final list = List<Address>.from(_addresses);
    list.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });
    return list;
  }

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  UserProvider() {
    _addresses.addAll(MockDataService.addresses);
  }

  void login(String name, String avatar) {
    _isLoggedIn = true;
    _userName = name;
    _avatarUrl = avatar;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _avatarUrl = '';
    notifyListeners();
  }

  void addAddress(Address addr) {
    if (addr.isDefault) {
      for (var i = 0; i < _addresses.length; i++) {
        if (_addresses[i].isDefault) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }
    }
    _addresses.add(addr);
    notifyListeners();
  }

  void updateAddress(Address addr) {
    final idx = _addresses.indexWhere((a) => a.id == addr.id);
    if (idx != -1) {
      if (addr.isDefault) {
        for (var i = 0; i < _addresses.length; i++) {
          if (_addresses[i].isDefault && _addresses[i].id != addr.id) {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
      }
      _addresses[idx] = addr;
      notifyListeners();
    }
  }

  void deleteAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  bool isFavorite(String productId) => _favorites.contains(productId);

  void toggleFavorite(String productId) {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    notifyListeners();
  }

  void addBrowseHistory(String productId) {
    _browseHistory.remove(productId);
    _browseHistory.insert(0, productId);
    if (_browseHistory.length > 50) _browseHistory.removeLast();
    notifyListeners();
  }
}
