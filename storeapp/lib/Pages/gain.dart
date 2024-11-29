import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates
import 'package:storeapp/BD.dart'; // Import de la classe DatabaseHelper

class Gain extends StatefulWidget {
  @override
  _GainState createState() => _GainState();
}

class _GainState extends State<Gain> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalSales = 0.0; // Gain total (prix de vente total)
  double _realGain = 0.0; // Gain réel (prix vente - prix achat)
  List<Map<String, dynamic>> _purchaseHistory = []; // Liste des achats
// Méthode pour sélectionner une date
Future<void> _selectDate(BuildContext context, bool isStartDate) async {
  final DateTime initialDate = isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();
  final DateTime firstDate = DateTime(2000); // Date la plus ancienne possible
  final DateTime lastDate = DateTime.now(); // Date la plus récente possible

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (picked != null && picked != initialDate) {
    setState(() {
      if (isStartDate) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });

    // Après la sélection, vous pouvez recalculer les gains en fonction des nouvelles dates, si nécessaire
    _calculateGains();
  }
}

  // Méthode pour calculer les gains et récupérer l'historique des achats
void _calculateGains() async {
  if (_startDate != null && _endDate != null) {
    double totalSales = 0.0;
    double realGain = 0.0;

    // Récupérer les achats avec les informations des prix depuis la base de données
    List<Map<String, dynamic>> purchases = await DatabaseHelper.instance.getAllPurchases();
    print(purchases);
    // Calcul des gains et préparation de l'historique des achats
    setState(() {
      _purchaseHistory = purchases;
    });

    // Calcul des gains
    for (var purchase in purchases) {
      double purchasePrice = (purchase['prix_achat'] != null) ? purchase['prix_achat'].toDouble() : 0.0;
      double salePrice = (purchase['p_vente'] != null) ? purchase['p_vente'].toDouble() : 0.0;
      int quantity = (purchase['quantity'] != null) ? purchase['quantity'] : 0;

      totalSales += salePrice * quantity;
      realGain += (salePrice - purchasePrice) * quantity;
    }

    setState(() {
      _totalSales = totalSales;
      _realGain = realGain;
    });
  }
}


  @override
  void initState() {
    super.initState();
    _calculateGains(); // Récupère immédiatement les achats dès le démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gains'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection de la date de début (optionnel si vous ne voulez pas filtrer par dates)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _startDate != null
                            ? 'Date début: ${DateFormat('dd/MM/yyyy').format(_startDate!)}'
                            : 'Sélectionner la date début',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Sélection de la date de fin (optionnel si vous ne voulez pas filtrer par dates)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _endDate != null
                            ? 'Date fin: ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                            : 'Sélectionner la date fin',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Affichage des gains
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gains totaux:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gain total (ventes): ${_totalSales.toStringAsFixed(2)} \DA',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gain réel (profit): ${_realGain.toStringAsFixed(2)} \DA',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Affichage de l'historique des achats
            Text(
              'Historique des achats:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Liste des achats
            Expanded(
  child: ListView.builder(
    itemCount: _purchaseHistory.length,
    itemBuilder: (context, index) {
      var purchase = _purchaseHistory[index];
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          title: Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(purchase['date']))}'),
          subtitle: Text(
            'Prix achat: ${purchase['prix_achat']} \DA | Prix vente: ${purchase['p_vente']} \DA | Quantité: ${purchase['quantity']}',
            style: TextStyle(fontSize: 14),
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
