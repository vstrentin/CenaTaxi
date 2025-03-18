import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para TextInputFormatter

class VehicleSelectionScreen extends StatefulWidget {
  final String driverName;

  const VehicleSelectionScreen({super.key, required this.driverName});

  @override
  _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  final TextEditingController _kmController = TextEditingController();
  String? _selectedVehicle;
  List<String> _vehicleOptions = []; // Lista de opções combinadas (marca + modelo)

  @override
  void initState() {
    super.initState();
    _fetchVehicles(); // Carregar veículos ao iniciar a tela
  }

  Future<void> _fetchVehicles() async {
    try {
      QuerySnapshot vehicleSnapshot = await FirebaseFirestore.instance
          .collection('veiculos')
          .get();
      setState(() {
        _vehicleOptions = vehicleSnapshot.docs.map((doc) {
          String marca = doc.get('marca') ?? '';
          String modelo = doc.get('modelo') ?? '';
          return '$marca $modelo'; // Concatenar marca e modelo
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar veículos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('APP TAXI'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/taxi_do_alemao_logo.png', height: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo, Motorista ${widget.driverName}',
              style: const TextStyle(fontSize: 24, color: Colors.green),
            ),
            const SizedBox(height: 40),
            DropdownButtonFormField<String>(
              value: _selectedVehicle,
              hint: const Text('Selecione seu veículo'),
              items: _vehicleOptions.map((vehicle) {
                return DropdownMenuItem<String>(
                  value: vehicle,
                  child: Text(vehicle),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicle = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.directions_car),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _kmController,
              keyboardType: TextInputType.number, // Aceita apenas números
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Só permite dígitos
              decoration: InputDecoration(
                labelText: 'Verifique a km do veículo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: const Icon(Icons.speed),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_selectedVehicle != null && _kmController.text.isNotEmpty) {
                  // Lógica para avançar (a ser implementada)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expediente iniciado!')),
                  );
                  Navigator.pop(context); // Volta para a tela anterior
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecione um veículo e insira o km!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: const Text(
                'Avançar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}