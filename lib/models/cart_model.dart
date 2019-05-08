import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_online/datas/cart_product.dart';
import 'package:loja_online/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;

  List<CartProduct> products = [];

  String codigoCupom;
  int porcentagemDesconto = 0;

  bool estaCarregando = false;

  CartModel(this.user) {
    if (user.isLoggedIn())
      _loadCartItems();
  }

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);

    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").add(cartProduct.toMap()).then((doc) {
          cartProduct.cid = doc.documentID;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(cartProduct.cid).delete();

    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity --;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
    .document(cartProduct.cid).updateData(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity ++;

    Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .document(cartProduct.cid).updateData(cartProduct.toMap());
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercentage) {
    this.codigoCupom = couponCode;
    this.porcentagemDesconto = discountPercentage;
  }

  void updatePrices() {
    notifyListeners();
  }

  double getProductsPrice() {
    double price = 0.0;

    for (CartProduct card in products) {
      if (card.productData != null)
        price += card.quantity * card.productData.price;
    }
    return price;
  }

  double getDiscount() {
    return getProductsPrice() * (porcentagemDesconto / 100);
  }

  double getShipPrice() {
    return 9.99;
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;

    estaCarregando = true;
    notifyListeners();

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    DocumentReference refOrder = await Firestore.instance.collection("orders").add(
      {
        "clienId": user.firebaseUser.uid,
        "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
        "shipPrice": shipPrice,
        "discount": discount,
        "productsPrice": productsPrice,
        "totalPrice": shipPrice - discount + productsPrice,
        "status": 1
      }
    );

    // armazena no id do usuario a referencia do pedido
    await Firestore.instance.collection("users").document(user.firebaseUser.uid)
    .collection("orders").document(refOrder.documentID).setData(
      {
        "orderId": refOrder.documentID
      }
    );

    // Deleta todos os produtos do carrinho apos o pedido ser finalizado
    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid)
    .collection("cart").getDocuments();

    for (DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }

    products.clear();
    codigoCupom = null;
    porcentagemDesconto = 0;
    estaCarregando = false;
    notifyListeners();

    return refOrder.documentID;
  }

  void _loadCartItems() async{
    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart")
        .getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }
}