import 'package:flutter/material.dart';
import 'package:shrine/product_detail.dart';
import 'package:shrine/profile.dart';
import 'package:shrine/update_product.dart';
import 'package:shrine/wishlist.dart';
import 'add_product.dart';
import 'home.dart';
import 'login.dart';

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/',
      routes: {
        '/' : (BuildContext context) => const LoginPage(),
        '/profile': (BuildContext context) => const Profile(),
        '/add_product': (BuildContext context) => const AddProduct(),
        '/product_detail': (BuildContext context) => const ProductDetail(),
        '/home': (BuildContext context) => const HomePage(),
        '/edit': (BuildContext context) => const UpdateProduct(),
        '/wishlist': (BuildContext context) => const Wishlist(),
      },
    );
  }
}