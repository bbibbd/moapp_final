import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'home.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //late StreamSubscription<QuerySnapshot>? querySnapShot;

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user;

    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn(clientId: DefaultFirebaseOptions.currentPlatform.iosClientId).signIn();
    if(googleSignInAccount != null){
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential = await firebaseAuth.signInWithCredential(authCredential);
      user = userCredential.user;
    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            ElevatedButton(
              onPressed: () async{
                User? user = await signInWithGoogle(context: context);
                if(user != null){
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(user.uid)
                      .set({
                    'email': user.email.toString(),
                    'name': user.displayName.toString(),
                    'status_message': 'I promise to take the test honestly before GOD',
                    'uid': user.uid,
                  });
                  //addUserInfo(user);
                  Navigator.pushNamed(context, '/home', arguments: user);
                }
              },
              child: const Text('Google'),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async{

                final userCredential = await FirebaseAuth.instance.signInAnonymously();

                User? user = userCredential.user;

                if(user != null){
                  user.updateDisplayName("anonymous user");
                  //user.updateEmail("anonymous");
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(user.uid)
                      .set({
                    'status_message': 'I promise to take the test honestly before GOD',
                    'uid': user.uid,
                  });
                  Navigator.pushNamed(context, '/home', arguments: user);
                }
              },
              child: const Text('Anonymous Login'),
            ),

          ],
        ),
      ),
    );
  }
}

