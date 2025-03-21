import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ride_detail_screen.dart'; // Nova tela de detalhes
import 'add_ride_screen.dart';

class SalesRidesScreen extends StatelessWidget {
  final String driverName;

  const SalesRidesScreen({super.key, required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vendas/Corridas'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/taxi_do_alemao_logo.png', height: 30),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para a tela de adicionar corrida (já implementada anteriormente)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRideScreen(driverName: driverName),
            ),
          );
        },
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('corridas')
            .where('driverName', isEqualTo: driverName)
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar corridas'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma corrida encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ride = snapshot.data!.docs[index];
              Timestamp dateTime = ride['dateTime'];
              String clientName = ride['clientName'];
              double value = ride['value'];
              String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime.toDate());
              String formattedValue = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text('Cliente: $clientName'),
                  subtitle: Text('$formattedDate - $formattedValue'),
                  onTap: () {
                    // Navegar para a tela de detalhes da corrida
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideDetailScreen(ride: ride),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}