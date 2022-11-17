import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_model.dart';

class Wishlist extends StatelessWidget{
  const Wishlist({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wish List",
        style: TextStyle(
          color: Colors.white,
        ),),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: _CartList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartList extends StatelessWidget {


  CollectionReference products =  FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.titleLarge;
    // This gets the current state of CartModel and also tells Flutter
    // to rebuild this widget when CartModel notifies listeners (in other words,
    // when it changes).
    var cart = context.watch<CartModel>();

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) => ListTile(
        leading:
        SizedBox(
          width: 60,
          height: 60,
          child: Image.network(
            cart.items[index].imageUrl,
            fit: BoxFit.fitWidth
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            cart.remove(cart.items[index]);
          },
        ),
        title: Text(
          cart.items[index].productName,
          style: itemNameStyle,
        ),
      ),
    );
  }
}

