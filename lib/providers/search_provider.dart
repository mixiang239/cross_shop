import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class SearchProvider extends ChangeNotifier {
  final List<String> _history = [];
  bool _showSuggestions = false;
  String _query = '';

  List<String> get history => List.unmodifiable(_history);
  List<String> get hotSearches => MockDataService.hotSearches;
  bool get showSuggestions => _showSuggestions;
  String get query => _query;
  List<String> get suggestions => _query.isEmpty
      ? []
      : MockDataService.getSearchSuggestions(_query);

  void addToHistory(String term) {
    _history.remove(term);
    _history.insert(0, term);
    if (_history.length > 20) _history.removeLast();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void removeFromHistory(String term) {
    _history.remove(term);
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    _showSuggestions = q.isNotEmpty;
    notifyListeners();
  }

  void showSuggestionsPanel() {
    _showSuggestions = true;
    notifyListeners();
  }

  void hideSuggestions() {
    _showSuggestions = false;
    notifyListeners();
  }
}
