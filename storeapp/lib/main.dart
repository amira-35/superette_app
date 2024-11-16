import 'package:flutter/material.dart';
import 'package:storeapp/Pages/gain.dart';
import 'package:storeapp/Pages/panier.dart';
import 'Pages/gestion_produit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pages = [
    CartPage(), // Page 1 : Calcul des produits dans le panier
    ProductManagementPage(), // Page 2 : Gestion des produits
    Gain(), // Page 3 : Gain total entre deux dates
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Gains'),
        ],
      ),
    );
  }
}
