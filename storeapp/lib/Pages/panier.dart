import 'package:flutter/material.dart';
import '../BD.dart'; // Assurez-vous d'avoir votre helper de base de données

class PanierPage extends StatefulWidget {
  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  List<Map<String, dynamic>> productsInCart = [];
  List<Map<String, dynamic>> filteredProducts = [];
  String searchQuery = '';
  

  // Récupérer les produits filtrés selon la recherche
  Future<void> _searchProducts(String query) async {
    final products = await DatabaseHelper.instance.searchProducts(query);
    setState(() {
      filteredProducts = products;
    });
  }


  // Ajouter un produit au panier ou mettre à jour la quantité
  void addToCart(Map<String, dynamic> product) {
    setState(() {
      bool productExists = false;
      for (var item in productsInCart) {
        if (item['id'] == product['id']) {
          productExists = true;
          item['quantity']++;
        }
      }
      if (!productExists) {
        productsInCart.add({
          'id': product['id'],
          'nom': product['nom'],
          'p_vente': product['p_vente'],
          'quantity': 1,
        });
      }
    });
  }

  // Supprimer un produit du panier
  void removeFromCart(int productId) {
    setState(() {
      productsInCart.removeWhere((item) => item['id'] == productId);
    });
  }

  // Mettre à jour la quantité d'un produit
  void updateQuantity(int productId, int quantity) {
    setState(() {
      if (quantity > 0) {
        for (var item in productsInCart) {
          if (item['id'] == productId) {
            item['quantity'] = quantity;
          }
        }
      }
    });
  }

  // Calculer le total du panier
  double get totalPrice {
    double total = 0;
    for (var product in productsInCart) {
      total += product['p_vente'] * product['quantity'];
    }
    return total;
  }
Future<void> confirmPurchase() async {
  final date = DateTime.now().toIso8601String().split('T')[0];

  // Insérer une transaction et récupérer son ID
  final transactionId = await DatabaseHelper.instance.insertTransaction(totalPrice);

  // Insérer chaque produit du panier dans la table des achats avec le même ID de transaction
  for (var product in productsInCart) {
    await DatabaseHelper.instance.insertPurchaseWithTransaction({
      'productId': product['id'],
      'quantity': product['quantity'],
      'date': date,
      'transactionId': transactionId, // Utiliser le même transactionId pour tous les achats
    }, totalPrice);
  }

  // Afficher un message de confirmation
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Achat confirmé avec succès !')));

  // Vider le panier
  setState(() {
    productsInCart.clear();
  });

  // Optionnel: récupérer et afficher les achats dans la base de données
  DatabaseHelper.instance.getAllPurchases();
}




  @override
  void initState() {
    super.initState();
    _searchProducts('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Panier")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un produit',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
                _searchProducts(searchQuery);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product['nom']),
                  subtitle: Text('Prix: \DA${product['p_vente'].toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: () => addToCart(product),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total: \DA${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: productsInCart.length,
              itemBuilder: (context, index) {
                final product = productsInCart[index];
                return ListTile(
                  title: Text(product['nom']),
                  subtitle: Row(
                    children: [
                      Text('Prix: \DA${product['p_vente'].toStringAsFixed(2)}'),
                      SizedBox(width: 10),
                      // Contrôle de la quantité
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (product['quantity'] > 1) {
                            updateQuantity(product['id'], product['quantity'] - 1);
                          }
                        },
                      ),
                      Text('${product['quantity']}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          updateQuantity(product['id'], product['quantity'] + 1);
                        },
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeFromCart(product['id']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: confirmPurchase,
              child: Text('Confirmer l\'achat'),
            ),
          ),
        ],
      ),
    );
  }
}
