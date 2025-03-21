import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminRideDetailScreen extends StatefulWidget {
  final DocumentSnapshot ride;

  const AdminRideDetailScreen({super.key, required this.ride});

  @override
  _AdminRideDetailScreenState createState() => _AdminRideDetailScreenState();
}

class _AdminRideDetailScreenState extends State<AdminRideDetailScreen> {
  late DateTime _selectedDateTime;
  String? _selectedDriver; // Pode ser nulo até a lista ser carregada
  late String _selectedVehicle;
  late TextEditingController _valueController;
  late TextEditingController _clientNameController;
  late TextEditingController _additionalInfoController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = (widget.ride['dateTime'] as Timestamp).toDate();
    _selectedDriver = widget.ride['driverName']; // Inicializar, mas validar depois
    _selectedVehicle = widget.ride['vehicle'];
    _valueController = TextEditingController(text: widget.ride['value'].toString());
    _clientNameController = TextEditingController(text: widget.ride['clientName']);
    _additionalInfoController = TextEditingController(text: widget.ride['additionalInfo'] ?? '');
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _updateRide() async {
    if (_selectedDateTime == null ||
        _selectedDriver == null ||
        _selectedVehicle == null ||
        _valueController.text.trim().isEmpty ||
        _clientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    try {
      double value = double.parse(_valueController.text.trim());
      await FirebaseFirestore.instance
          .collection('corridas')
          .doc(widget.ride.id)
          .update({
        'dateTime': Timestamp.fromDate(_selectedDateTime),
        'driverName': _selectedDriver,
        'vehicle': _selectedVehicle,
        'value': value,
        'clientName': _clientNameController.text.trim(),
        'additionalInfo': _additionalInfoController.text.trim(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar corrida: $e')),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Alterações'),
        content: const Text('Tem certeza que deseja descartar as alterações?'),
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
        title: const Text('Detalhes da Venda/Corrida'),
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
            onPressed: _updateRide,
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
            const Text('Selecionar Data e Hora', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                DateFormat('d MMM, yyyy HH:mm', 'pt_BR').format(_selectedDateTime),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Motorista', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'driver')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Erro ao carregar motoristas');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                List<String> drivers = snapshot.data!.docs
                    .map((doc) => doc['nome'] as String)
                    .toList();

                // Verificar se o _selectedDriver está na lista de motoristas
                if (!drivers.contains(_selectedDriver) && _selectedDriver != null) {
                  // Se o motorista não estiver na lista, podemos lidar com isso
                  // Por exemplo, adicioná-lo temporariamente à lista ou definir _selectedDriver como null
                  drivers.add(_selectedDriver!);
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Selecione o motorista',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedDriver != null && drivers.contains(_selectedDriver)
                      ? _selectedDriver
                      : null, // Garantir que o value seja válido
                  items: drivers.map((String driver) {
                    return DropdownMenuItem<String>(
                      value: driver,
                      child: Text(driver),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDriver = newValue;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Veículo', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('veiculos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Erro ao carregar veículos');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                List<String> vehicles = snapshot.data!.docs
                    .map((doc) => '${doc['marca']} ${doc['modelo']} - Placa ${doc['placa']}')
                    .toList();

                // Verificar se o _selectedVehicle está na lista de veículos
                if (!vehicles.contains(_selectedVehicle) && _selectedVehicle != null) {
                  vehicles.add(_selectedVehicle!);
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    hintText: 'Selecione o veículo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  value: _selectedVehicle != null && vehicles.contains(_selectedVehicle)
                      ? _selectedVehicle
                      : null, // Garantir que o value seja válido
                  items: vehicles.map((String vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle,
                      child: Text(vehicle),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedVehicle = newValue!;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Valor da Corrida', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Digite o valor (ex.: 14.87)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cliente', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _clientNameController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do cliente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Informações Adicionais', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite informações adicionais (opcional)',
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