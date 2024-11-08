
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lista_compras/view/shopping_list_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras Simples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShoppingListView(),
    );
  }
}
