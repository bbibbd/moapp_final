import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AddProduct extends StatefulWidget {

  const AddProduct({Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct>{

  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productDescriptionController = TextEditingController();

  PickedFile? _image;
  CollectionReference products = FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;

    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add',
          style: TextStyle(
              color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        leading: TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text(
              "Cancel",
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              //TODO: implement the action for save button
              final String imageUrl;

              if(_image != null){
                Reference firebaseStorageRef = FirebaseStorage.instance.ref().child("product").child("${_productNameController.text}.png");
                UploadTask uploadTask = firebaseStorageRef.putFile(File(_image!.path), SettableMetadata(contentType: 'image/png'));
                await uploadTask.whenComplete(() => null);
                imageUrl = await firebaseStorageRef.getDownloadURL();
              } else {
                imageUrl = "http://handong.edu/site/handong/res/img/logo.png";
              }
              await products.add({
                'productName': _productNameController.text,
                'price': int.parse(_productPriceController.text),
                'description': _productDescriptionController.text,
                'imageUrl': imageUrl,
                'uid': user!.uid,
                'createdTime': FieldValue.serverTimestamp(),
                'modifiedTime': FieldValue.serverTimestamp(),
                'modified': false,
                'like': 0
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          )
        ],
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
                    "http://handong.edu/site/handong/res/img/logo.png",
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(_image!.path),
                  fit: BoxFit.cover
                ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () async {
                      // Pick an image
                      final ImagePicker imagePicker = ImagePicker();
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