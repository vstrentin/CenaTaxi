import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_ride_detail_screen.dart'; // Tela de detalhes (a ser criada)
import 'admin_add_ride_screen.dart'; // Tela de adição (a ser criada)

class AdminSalesRidesScreen extends StatefulWidget {
  const AdminSalesRidesScreen({super.key});

  @override
  _AdminSalesRidesScreenState createState() => _AdminSalesRidesScreenState();
}

class _AdminSalesRidesScreenState extends State<AdminSalesRidesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gerar relatório (a ser implementado)')),
              );
            },
            backgroundColor: const Color(0xFFFFC107),
            child: const Icon(Icons.description, color: Colors.black),
            tooltip: 'Gerar Relatório',
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAddRideScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFFFFC107),
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar vendas/corridas',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('corridas')
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

                var rides = snapshot.data!.docs.where((doc) {
                  String clientName = doc['clientName'].toString().toLowerCase();
                  String driverName = doc['driverName'].toString().toLowerCase();
                  return clientName.contains(_searchQuery) || driverName.contains(_searchQuery);
                }).toList();

                if (rides.isEmpty) {
                  return const Center(child: Text('Nenhuma corrida corresponde à pesquisa'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    var ride = rides[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminRideDetailScreen(ride: ride),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}