import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'driver_dashboard_screen.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String driverName;

  const VehicleSelectionScreen({super.key, required this.driverName});

  @override
  _VehicleSelectionScreenState createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  final TextEditingController _kmController = TextEditingController();
  String? _selectedVehicle;
  List<String> _vehicleOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
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
          return '$marca $modelo';
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar veículos: $e')),
      );
    }
  }

  Future<void> _startShift() async {
    try {
      // Criar o documento na coleção expedientes
      DocumentReference docRef = await FirebaseFirestore.instance.collection('expedientes').add({
        'driverName': widget.driverName,
        'vehicle': _selectedVehicle,
        'km': int.parse(_kmController.text),
        'startTime': Timestamp.now(),
        'endTime': null,
      });

      // Redirecionar para a nova tela, passando o ID do documento
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverDashboardScreen(
            driverName: widget.driverName,
            shiftId: docRef.id, // Passar o ID do expediente
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar expediente: $e')),
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
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  _startShift();
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