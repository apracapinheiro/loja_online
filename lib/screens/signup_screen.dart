import 'package:flutter/material.dart';
import 'package:loja_online/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';



class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _enderecoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();  // para ter acesso ao scaffold da tela

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Criar conta"),
        centerTitle: true,
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if (model.estaCarregando)
            return Center(child: CircularProgressIndicator(),);
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      hintText: "Nome completo"
                  ),
                  validator: (text) {
                    if (text.isEmpty) return "Digite um nome!";
                  },
                ),
                SizedBox(height: 16.0,),
                TextFormField(
                  controller: _enderecoController,
                  decoration: InputDecoration(
                      hintText: "Endereço"
                  ),
                  validator: (text) {
                    if (text.isEmpty) return "Digite um endereço!";
                  },
                ),
                SizedBox(height: 16.0,),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "E-mail"
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text.isEmpty || !text.contains("@")) return "E-mail inváido!";
                  },
                ),
                SizedBox(height: 16.0,),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      hintText: "Senha"
                  ),
                  obscureText: true,
                  validator: (text) {
                    if (text.isEmpty || text.length < 6) return "Senha inváida!";
                  },
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    child: Text("Criar conta",
                      style: TextStyle(
                          fontSize: 18.0
                      ),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {

                        Map<String, dynamic> userData = {
                          "name": _nameController.text,
                          "email": _emailController.text,
                          "endereco": _enderecoController.text
                        };

                        model.signUp(userData: userData,
                            password: _passwordController.text,
                            onSuccess: _onSucess,
                            onFail: _onFail
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSucess() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso!"),
          backgroundColor: Theme.of(context).primaryColor,
          duration: Duration(seconds: 2),
        )
    );
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pop();
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Erro ao criar usuário!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
    );
  }
}
