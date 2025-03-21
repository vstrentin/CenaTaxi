import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDriverDetailScreen extends StatefulWidget {
  final DocumentSnapshot? driver; // null para novo motorista

  const AdminDriverDetailScreen({super.key, this.driver});

  @override
  _AdminDriverDetailScreenState createState() => _AdminDriverDetailScreenState();
}

class _AdminDriverDetailScreenState extends State<AdminDriverDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _cnhController = TextEditingController();
  DateTime? _cnhExpirationDate;
  final TextEditingController _criminalRecordController = TextEditingController();
  final TextEditingController _otherAttachmentsController = TextEditingController();
  List<String> _selectedVehicles = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      _nameController.text = widget.driver!['nome'] ?? '';
      _cpfController.text = widget.driver!['cpf'] ?? '';
      _cnhController.text = widget.driver!['cnh'] ?? '';
      _cnhExpirationDate = widget.driver!['cnhExpirationDate'] != null
          ? (widget.driver!['cnhExpirationDate'] as Timestamp).toDate()
          : null;
      _criminalRecordController.text = widget.driver!['criminalRecord'] ?? '';
      _otherAttachmentsController.text = widget.driver!['otherAttachments'] ?? '';
      _selectedVehicles = List<String>.from(widget.driver!['vehicles'] ?? []);
      _usernameController.text = widget.driver!['login'] ?? '';
      _passwordController.text = widget.driver!['senha'] ?? '';
    }
  }

  Future<void> _selectCnhExpirationDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _cnhExpirationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _cnhExpirationDate = pickedDate;
      });
    }
  }

  Future<void> _saveDriver() async {
    if (_nameController.text.trim().isEmpty ||
        _cpfController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    try {
      Map<String, dynamic> driverData = {
        'nome': _nameController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'cnh': _cnhController.text.trim(),
        'cnhExpirationDate': _cnhExpirationDate != null
            ? Timestamp.fromDate(_cnhExpirationDate!)
            : null,
        'criminalRecord': _criminalRecordController.text.trim(),
        'otherAttachments': _otherAttachmentsController.text.trim(),
        'vehicles': _selectedVehicles,
        'login': _usernameController.text.trim(),
        'senha': _passwordController.text.trim(),
        'role': 'driver',
      };

      if (widget.driver == null) {
        // Novo motorista
        await FirebaseFirestore.instance.collection('users').add(driverData);
      } else {
        // Atualizar motorista existente
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.driver!.id)
            .update(driverData);
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar motorista: $e')),
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
        title: Text(widget.driver == null ? 'Cadastrar Motorista' : 'Detalhes do Motorista'),
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
            onPressed: _saveDriver,
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
            const Text('Nome*', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do motorista',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CPF*', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _cpfController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Digite o CPF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('CNH (Anexo)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _cnhController,
              decoration: InputDecoration(
                hintText: 'URL ou caminho do anexo da CNH (a ser implementado)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Data de Validade da CNH', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectCnhExpirationDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _cnhExpirationDate == null
                    ? 'Selecionar Data'
                    : DateFormat('d MMM, yyyy', 'pt_BR').format(_cnhExpirationDate!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Histórico Criminal (Anexo)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _criminalRecordController,
              decoration: InputDecoration(
                hintText: 'URL ou caminho do anexo do histórico criminal (a ser implementado)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Outros Anexos', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _otherAttachmentsController,
              decoration: InputDecoration(
                hintText: 'URL ou caminho de outros anexos (a ser implementado)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Veículos Disponíveis', style: TextStyle(fontSize: 16)),
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

                return Column(
                  children: vehicles.map((vehicle) {
                    return CheckboxListTile(
                      title: Text(vehicle),
                      value: _selectedVehicles.contains(vehicle),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedVehicles.add(vehicle);
                          } else {
                            _selectedVehicles.remove(vehicle);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Usuário de Acesso*', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Digite o usuário de acesso',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Senha de Acesso*', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Digite a senha de acesso',
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