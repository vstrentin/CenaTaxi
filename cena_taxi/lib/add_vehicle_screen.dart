import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _renavamController = TextEditingController();

  Future<void> _saveVehicle() async {
    if (_marcaController.text.trim().isEmpty ||
        _modeloController.text.trim().isEmpty ||
        _placaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('veiculos').add({
        'marca': _marcaController.text.trim(),
        'modelo': _modeloController.text.trim(),
        'placa': _placaController.text.trim(),
        'renavam': _renavamController.text.trim(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar veículo: $e')),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Veículo'),
        content: const Text('Tem certeza que deseja descartar este veículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cadastrar Veículo'),
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
            onPressed: () async {
              bool discard = await _confirmDiscard();
              if (discard) {
                Navigator.pop(context);
              }
            },
            backgroundColor: const Color(0xFFFFC107),
            child: const Icon(Icons.delete, color: Colors.black),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _saveVehicle,
            backgroundColor: const Color(0xFFFFC107),
            child: const Icon(Icons.save, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Veículo', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _marcaController,
              decoration: InputDecoration(
                hintText: 'Marca (ex.: Volkswagen)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(
                hintText: 'Modelo (ex.: Virtus)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Placa', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _placaController,
              decoration: InputDecoration(
                hintText: 'Placa (ex.: ABC6A65)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Renavam', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _renavamController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Renavam (ex.: 123454654123)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}