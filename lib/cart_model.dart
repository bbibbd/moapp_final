

import 'package:flutter/material.dart';
import 'product_detail.dart';

class CartModel extends ChangeNotifier{

  final List<Product> _products = [];

  List<Product> get items => _products;

  void add(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void remove(Product product){
    _products.remove(product);
    notifyListeners();
  }

  void removeAll() {
    _products.clear();
    notifyListeners();
  }



}