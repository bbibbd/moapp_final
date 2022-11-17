import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cart_model.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {

  @override
  Scaffold build(BuildContext context) {
    Product info = ModalRoute.of(context)!.settings.arguments as Product;
    final CollectionReference products =
        FirebaseFirestore.instance.collection('products');
    final DocumentReference product = products.doc(info.documentId);

    final NumberFormat numberFormat =
        NumberFormat.simpleCurrency(locale: "ko_KR");

    Future<bool> _isValid() async {
      DocumentSnapshot data = await products.doc(info.documentId).get();
      if (info.user.uid == data['uid']) {
        return true;
      } else {
        return false;
      }
    }

    SizedBox _image(Map<String, dynamic> data) {
      return SizedBox(
        width: double.infinity,
        height: 300,
        child: Image.network(
          data['imageUrl'],
          fit: BoxFit.fitHeight,
        ),
      );
    }

    Row _title(Map<String, dynamic> data) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  data['productName'] as String,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  numberFormat.format(data['price']),
                  style: const TextStyle(
                      fontSize: 15, color: Colors.deepPurpleAccent),
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () async {
                CollectionReference likedUser =
                    product.collection("liked_user");

                QuerySnapshot querySnapshot = await likedUser.get();
                int i;
                for (i = 0; i < querySnapshot.docs.length; i++) {
                  var doc = querySnapshot.docs[i];
                  if (doc.id == info.user.uid) {
                    break;
                  }
                }
                if (i == querySnapshot.docs.length) {
                  product.collection('liked_user').doc(info.user.uid).set({
                    'uid': info.user.uid,
                  });
                  data['like'] = data['like'] + 1;
                  product.update({
                    'like': data['like'],
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      "I LIKE IT!",
                      style: TextStyle(fontSize: 15),
                    ),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text("You can only do it once!!",
                        style: TextStyle(
                          fontSize: 15,
                        )),
                  ));
                }
              },
              icon: const Icon(Icons.thumb_up)),
          const SizedBox(
            width: 10,
          ),
          Text("${data['like']}"),
        ],
      );
    }

    SizedBox _divider() {
      return const SizedBox(
        height: 50,
        width: double.infinity,
        child: Divider(color: Colors.blueGrey, thickness: 1.0),
      );
    }

    Text _description(Map<String, dynamic> data) {
      return Text(
        data['description'],
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 15,
        ),
      );
    }

    Widget _reference(Map<String, dynamic> data) {

      if((data['modifiedTime'] != null)) {

        DateTime _createdTime = DateTime.parse(data["createdTime"].toDate().toString());
        DateTime _modifiedTime =  DateTime.parse(data['modifiedTime'].toDate().toString());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              "Creator: ${data['uid']}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            Text(
              '${DateFormat('yy').format(_createdTime)}.${_createdTime
                  .month}.${_createdTime.day} ${_createdTime
                  .hour}:${_createdTime.minute}:${_createdTime
                  .second} created',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            data["modified"]
                ? Text(
              '${DateFormat('yy').format(_modifiedTime)}.${_modifiedTime
                  .month}.${_modifiedTime.day} ${_modifiedTime
                  .hour}:${_modifiedTime.minute}:${_modifiedTime
                  .second} Modified',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            )
                : const Text(""),
          ],
        );
      }
      else{
        return const Text("");
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Detail"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          actions: [
            FutureBuilder<bool>(
                future: _isValid(),
                builder:
                    (BuildContext context, AsyncSnapshot<bool> asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: Center(child: CircularProgressIndicator()));
                  } else {
                    if (asyncSnapshot.data == true) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/edit',
                                      arguments: info)
                                  .then((value) {
                                if (value != null) {
                                  info = value as Product;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.create,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Text("");
                    }
                  }
                }),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: products.doc(info.documentId).snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text('Loading...'),
                );
              } else {
                  Map<String, dynamic> data =
                      asyncSnapshot.data!.data() as Map<String, dynamic>;
                  return ListView(
                    children: [
                      _image(data),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _title(data),
                            _divider(),
                            _description(data),
                            _reference(data),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
            ),
        floatingActionButton: _ShoppingCartButton(
          item: info,
        ));
  }
}

class _ShoppingCartButton extends StatelessWidget {
  final Product item;
  _ShoppingCartButton({required this.item});

  final cart = CartModel();

  @override
  Widget build(BuildContext context) {
    var isInCart = context.select<CartModel, bool>(
      (cart) => cart.items
          .where((element) => element.documentId == item.documentId)
          .isNotEmpty,
    );

    return IconButton(
      onPressed: isInCart
          ? null
          : () {
              var cart = context.read<CartModel>();
              cart.add(item);
            },
      icon: isInCart
          ? const Icon(
              Icons.check,
              color: Colors.blue,
            )
          : const Icon(
              Icons.shopping_cart,
              color: Colors.blue,
            ),
    );
  }
}

class Product {
  final User user;
  final String documentId;
  final String productName;
  final String description;
  final String imageUrl;
  final int price;

  Product(
      {required this.user,
      required this.documentId,
      required this.productName,
      required this.description,
      required this.imageUrl,
      required this.price});
}
