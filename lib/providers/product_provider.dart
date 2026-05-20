import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/mock_data_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  final List<Category> _categories = MockDataService.categories;
  final List<String> _banners = MockDataService.banners;
  String _selectedCategory = '全部';

  List<Product> get products => _query.isEmpty ? _products : _filteredProducts;
  List<Category> get categories => _categories;
  List<String> get banners => _banners;
  String get selectedCategory => _selectedCategory;
  String _query = '';
  List<Product> get _filteredProducts =>
      MockDataService.searchProducts(_query);

  ProductProvider() {
    _loadAll();
  }

  void _loadAll() {
    _products = MockDataService.products;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _products = MockDataService.getProductsByCategory(category);
    notifyListeners();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _selectedCategory = '全部';
    _loadAll();
    notifyListeners();
  }

  Product? getProductById(String id) => MockDataService.getProductById(id);
}
