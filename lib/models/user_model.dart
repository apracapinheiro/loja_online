import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserModel extends Model {
  // Usuario que esta logado no momento

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  Map<String, dynamic> userData = Map();

  bool estaCarregando = false;

  static UserModel of(BuildContext context) =>
      ScopedModel.of<UserModel>(context);


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signUp({@required Map<String, dynamic> userData,
    @required String password, @required VoidCallback onSuccess,
    @required VoidCallback onFail}) {

    estaCarregando = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
        email: userData["email"],
        password: password
    ).then((user) async {
      firebaseUser = user;

      await _saveUserData(userData);

      onSuccess();
      estaCarregando = false;
      notifyListeners();
    }).catchError((e){
      onFail();
      estaCarregando = false;
      notifyListeners();
    });

  }

  void signIn({@required String email, @required String password,
    @required VoidCallback onSuccess, @required VoidCallback onFail}) async {
    estaCarregando = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: password).then(
        (user) async {
          firebaseUser = user;
          await _loadCurrentUser();
          onSuccess();
          estaCarregando = false;
          notifyListeners();

        }).catchError((e){
          onFail();
          estaCarregando = false;
          notifyListeners();
        });
  }

  void signOut() async {
    await _auth.signOut();
    userData = Map();
    firebaseUser = null;
    notifyListeners();
  }

  void recoverPass(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
  }

  Future<Null> _loadCurrentUser() async {
    if (firebaseUser == null)
      firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser =
        await Firestore.instance.collection("users")
            .document(firebaseUser.uid)
            .get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }


}