import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_model.dart';


class ProfileMessage{
  ProfileMessage({required this.email, required this.name, required this.statusMessage, required this.uid});

  final String email;
  final String name;
  final String statusMessage;
  final String uid;
}


class Profile extends StatefulWidget{

  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileState();

}

class _ProfileState extends State<Profile>
{
  CollectionReference users = FirebaseFirestore.instance.collection('user');

  SizedBox _getProfilePhoto(User? user){
    String photoUrl;
    if(user?.photoURL == null){
      photoUrl = "https://handong.edu/site/handong/res/img/logo.png";
    } else{
      photoUrl = user?.photoURL as String;
    }
    return SizedBox(
        height: 200,
        width: 200,
        child: Image.network(
          photoUrl,
          fit: BoxFit.fitHeight,
        ));
  }

  Text _getEmail(User? user){
    String email;
    if(user?.email == null){
      email = "anonymous";
    }else{
      email = user?.email as String;
    }

    return Text(
      email,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }
  @override
  Widget build(BuildContext context) {

    final User user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              var cart = context.read<CartModel>();
              cart.removeAll();

              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pop(context);
          }, icon: const Icon(
            Icons.exit_to_app,
            color: Colors.white,
          ),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 70.0),
        child: Column(
          children: [
            _getProfilePhoto(user),
            const SizedBox(height: 20,),
            Text(
                user?.uid as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: Divider(
                      color: Colors.white,
                      thickness: 1.5),
                ),
                const SizedBox(height: 10,),
                _getEmail(user),
                const SizedBox(height: 50,),
                const Text(
                  "Kim Gibeom",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "I promise to take the test honestly before GOD.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            )
          ],
        ),
        color: Colors.black,
      )

    );
  }
}