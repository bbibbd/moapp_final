
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shrine/product_detail.dart';
class UpdateProduct extends StatefulWidget {
  const UpdateProduct({Key? key}) : super(key: key);

  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {

  PickedFile? _image;
  CollectionReference products = FirebaseFirestore.instance.collection('products');
  late String imageUrl;


  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    final _productNameController = TextEditingController();
    final _productPriceController = TextEditingController();
    final _productDescriptionController = TextEditingController();

    _productNameController.text = product.productName;
    _productPriceController.text = product.price.toString();
    _productDescriptionController.text = product.description;

    imageUrl = product.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
                "Cancel",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12
            ),)),
        actions: [
          TextButton(
              onPressed: () async {

                if(_image != null){
                  Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("product").child("${_productNameController.text}.png");
                  UploadTask uploadTask = firebaseStorageRef.putFile(File(_image!.path), SettableMetadata(contentType: 'image/png'));
                  await uploadTask.whenComplete(() => null);
                  imageUrl = await firebaseStorageRef.getDownloadURL();
                }
                 await products.doc(product.documentId).update({
                  'productName': _productNameController.text,
                  'price': int.parse(_productPriceController.text),
                  'description': _productDescriptionController.text,
                  'imageUrl': imageUrl,
                  'uid': product.user.uid,
                  'modifiedTime': FieldValue.serverTimestamp(),
                  'modified': true,
                });
                Product info = Product(
                    user: product.user,
                    documentId: product.documentId,
                    productName: _productNameController.text,
                    description: _productDescriptionController.text,
                    imageUrl: imageUrl,
                    price: int.parse(_productPriceController.text),
                );
                Navigator.pop(context, info);
              },
              child: const Text(
                  "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),),
          ),],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child:
              _image == null
                  ? Image.network(
                imageUrl,
                fit: BoxFit.fitHeight,
              )
                  : Image.file(
                  File(_image!.path),
                  fit: BoxFit.fitHeight,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    // Pick an image
                    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                    setState(() {
                      _image = image!;
                    });
                  },
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                        filled: false,
                        labelText: 'Product Name'
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: _productPriceController,
                    decoration: const InputDecoration(
                        filled: false,
                        labelText: 'Price'
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: _productDescriptionController,
                    decoration: const InputDecoration(
                        filled: false,
                        labelText: 'Description'
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
