import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'cart_model.dart';
import 'product_detail.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> list = <String>['ASC', 'DESC'];
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  CollectionReference users = FirebaseFirestore.instance.collection('user');
  String dropdownValue = "ASC";
  bool descending = false;


  List<Card> _buildHotelGridCards(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, User user) {

    final NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: "ko_KR");

    return snapshot.data!.docs.map((DocumentSnapshot document) {
      var isInCart = context.select<CartModel, bool>(
            (cart) => cart.items
            .where((element) => element.documentId == document.id)
            .isNotEmpty,
      );
      return Card(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 11,
              child: isInCart
                  ? Stack(
                children: [
                  Image.network(
                    document['imageUrl'],
                    fit: BoxFit.fitHeight,
                  ),
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      ),)
                ],
              )
              : Image.network(
                document['imageUrl'],
                fit: BoxFit.fitHeight,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 7,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            document['productName'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                          Expanded(
                            child: Text(
                              numberFormat.format(document['price']),
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 30,
                                  child: TextButton(
                                    onPressed: () async {
                                      Product info = Product(
                                          user: user,
                                          documentId: document.id,
                                          productName: document['productName'],
                                          description: document['description'],
                                          imageUrl: document['imageUrl'],
                                          price: document['price'],
                                      );
                                      Navigator.pushNamed(context, '/product_detail', arguments: info).then((value){
                                        if(value == true){
                                          Future.delayed(const Duration(milliseconds: 500), (){
                                            products.doc(document.id).delete();
                                            FirebaseStorage.instance
                                                .refFromURL(document['imageUrl'])
                                                .delete();
                                          });
                                        }
                                      });
                                    },
                                    child: const Text(
                                      "more",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final User user = ModalRoute.of(context)!.settings.arguments as User;

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text("Main"),
        leading: IconButton(
          onPressed: () async{
            Navigator.pushNamed(context,'/profile', arguments: user);
          },
          icon: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/wishlist');
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, '/add_product', arguments: user);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ]
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Container(
            alignment: Alignment.center,
            child: DropdownButton <String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value){
                setState(() {
                  if(dropdownValue != value) {
                    descending = !(descending);
                    dropdownValue = value!;
                  }
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: products.orderBy('price', descending: descending).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: Center(child: CircularProgressIndicator()));
                  }
                  else{
                    return OrientationBuilder(
                      builder: (context, orientation) {
                        return GridView.count(
                          crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 3,
                          padding: const EdgeInsets.all(16.0),
                          childAspectRatio: 8.0 / 9.0,
                          children: _buildHotelGridCards(context, snapshot, user),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      )
    );
  }
}

class Info {
  final User user;
  final String documentId;

  Info({required this.user, required this.documentId});


}

