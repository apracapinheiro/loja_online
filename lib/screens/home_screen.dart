import 'package:flutter/material.dart';
import 'package:loja_online/tabs/home_tab.dart';
import 'package:loja_online/tabs/product_tab.dart';
import 'package:loja_online/widgets/cart_button.dart';
import 'package:loja_online/widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _pageController = PageController();

    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        Scaffold(
          body: HomeTab(),
          drawer: CustomDrawer(_pageController),
          floatingActionButton: CartButton(),
        ),
        Scaffold(
          appBar: AppBar(
            title: Text("Produtos"),
            centerTitle: true,
          ),
          drawer: CustomDrawer(_pageController),
          body: ProductsTab(),
          floatingActionButton: CartButton(),
        ),
        Container(color: Colors.purpleAccent),
        Container(color: Colors.lightGreenAccent),
      ],
    );
  }
}
