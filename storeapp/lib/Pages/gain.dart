import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour la gestion des dates

class Gain extends StatefulWidget {
  @override
  _GainState createState() => _GainState();
}

class _GainState extends State<Gain> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalSales = 0.0; // Gain total (prix de vente total)
  double _realGain = 0.0; // Gain réel (prix vente - prix achat)

  // Exemple de données de vente
  List<Map<String, dynamic>> sales = [
    {'date': DateTime(2024, 11, 10), 'salePrice': 100.0, 'purchasePrice': 70.0},
    {'date': DateTime(2024, 11, 12), 'salePrice': 200.0, 'purchasePrice': 150.0},
    {'date': DateTime(2024, 11, 14), 'salePrice': 150.0, 'purchasePrice': 100.0},
  ];

  // Méthode pour ouvrir le sélecteur de date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _calculateGains();
      });
    }
  }

  // Méthode pour calculer les gains
  void _calculateGains() {
    if (_startDate != null && _endDate != null) {
      double totalSales = 0.0;
      double realGain = 0.0;

      for (var sale in sales) {
        if (sale['date'].isAfter(_startDate!) && sale['date'].isBefore(_endDate!)) {
          totalSales += sale['salePrice'];
          realGain += sale['salePrice'] - sale['purchasePrice'];
        }
      }

      setState(() {
        _totalSales = totalSales;
        _realGain = realGain;
      });
    }
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
            // Sélection de la date de début
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
                // Sélection de la date de fin
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
                    'Gain total (ventes): ${_totalSales.toStringAsFixed(2)} \$',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gain réel (profit): ${_realGain.toStringAsFixed(2)} \$',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

