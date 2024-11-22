import 'package:flutter/material.dart';
import '../BD.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _searchController = TextEditingController();
  double _total = 0.0;

  // Exemple de données de produits dans le panier
  List<Map<String, dynamic>> basket = [
    {'name': 'Produit 1', 'price': 10.0, 'quantity': 1},
    {'name': 'Produit 2', 'price': 15.0, 'quantity': 2},
    {'name': 'Produit 3', 'price': 5.0, 'quantity': 3},
  ];

  // Met à jour le total
  void _updateTotal() {
    setState(() {
      _total = basket.fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                // Logique de recherche à ajouter ici
              },
            ),
            SizedBox(height: 16),
            
            // Afficher le total des achats
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_total.toStringAsFixed(2)} \$',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Liste des produits dans le panier
            Expanded(
              child: ListView.builder(
                itemCount: basket.length,
                itemBuilder: (context, index) {
                  final product = basket[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(product['name']),
                      subtitle: Text('Prix: ${product['price'].toStringAsFixed(2)} \$'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton pour diminuer la quantité
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (product['quantity'] > 1) {
                                  product['quantity']--;
                                  _updateTotal();
                                }
                              });
                            },
                          ),
                          Text(
                            '${product['quantity']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          // Bouton pour augmenter la quantité
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                product['quantity']++;
                                _updateTotal();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
