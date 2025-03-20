import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'driver_home_screen.dart';

class EndShiftScreen extends StatefulWidget {
  final String driverName;
  final String shiftId;

  const EndShiftScreen({
    super.key,
    required this.driverName,
    required this.shiftId,
  });

  @override
  _EndShiftScreenState createState() => _EndShiftScreenState();
}

class _EndShiftScreenState extends State<EndShiftScreen> {
  final TextEditingController _endKmController = TextEditingController();

  Future<void> _endShift() async {
    if (_endKmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe a quilometragem final!')),
      );
      return;
    }

    try {
      int endKm = int.parse(_endKmController.text.trim());
      await FirebaseFirestore.instance
          .collection('expedientes')
          .doc(widget.shiftId)
          .update({
        'endTime': Timestamp.now(),
        'endKm': endKm,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DriverHomeScreen(driverName: widget.driverName),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao encerrar expediente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('APP TÁXI'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Indique a km do veículo', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _endKmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Quilometragem final',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _endShift,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Encerrar Expediente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}