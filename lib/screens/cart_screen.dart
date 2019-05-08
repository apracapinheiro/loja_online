import 'package:flutter/material.dart';
import 'package:loja_online/models/cart_model.dart';
import 'package:loja_online/models/user_model.dart';
import 'package:loja_online/screens/login_screen.dart';
import 'package:loja_online/screens/order_screen.dart';
import 'package:loja_online/tiles/cart_tile.dart';
import 'package:loja_online/widgets/cart_price.dart';
import 'package:loja_online/widgets/discount_cart.dart';
import 'package:loja_online/widgets/ship_card.dart';
import 'package:scoped_model/scoped_model.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu carrinho"),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 8.0),
            alignment: Alignment.center,
            child: ScopedModelDescendant<CartModel>(
              builder: (context, child, model){

                int qtde = model.products.length;

                return Text(
                  // se qtde for nulo, retorna zero, se não retorna o valor de qtde
                  "${qtde ?? 0} ${qtde == 1 ? "ITEM": "ITENS"}",
                  style: TextStyle(fontSize: 17.0),
                );
              },
            ),
          ),
        ],
      ),
      body:ScopedModelDescendant<CartModel>(
          builder: (context, child, model){
            if (model.estaCarregando && UserModel.of(context).isLoggedIn()) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (!UserModel.of(context).isLoggedIn()) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.remove_shopping_cart,
                      size: 80.0,
                      color: Theme.of(context).primaryColor,),
                    SizedBox(height: 16.0,),
                    Text("Faça o login para adicionar itens ao carrinho",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.0,),
                    RaisedButton(
                      child: Text("Entrar", style: TextStyle(fontSize: 18.0),),
                      textColor: Colors.white,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>  LoginScreen()));
                      },
                    )
                  ],
                ),
              );
            } else if (model.products == null || model.products.length == 0) {
              return Center(
                child: Text("Nenhum produto no carrinho!",
                  style: TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,),
                );
            } else {
              return ListView(
                children: <Widget>[
                  Column(
                    children: model.products.map(
                        (product) {
                          return CartTile(product);
                        }
                    ).toList(),
                  ),
                  DiscountCart(),
                  ShipCard(),
                  CartPrice(() async{
                    String orderId = await model.finishOrder();
                    if (orderId != null)
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => OrderScreen(orderId))
                      );
                  })
                ],
              );
            }
          }
        ),
    );
  }
}
