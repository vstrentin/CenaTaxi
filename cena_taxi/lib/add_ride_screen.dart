import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';

class AddRideScreen extends StatefulWidget {
  final String driverName;

  const AddRideScreen({super.key, required this.driverName});

  @override
  _AddRideScreenState createState() => _AddRideScreenState();
}

class _AddRideScreenState extends State<AddRideScreen> {
  DateTime? _selectedDateTime;
  String? _vehicle;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  List<String> _clientOptions = [];
  bool _requiresSignature = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicle();
    _fetchClients();
    _valueController.addListener(_formatCurrency);
    _clientController.addListener(_checkClientSignatureRequirement);
  }

  Future<void> _fetchVehicle() async {
    try {
      QuerySnapshot shiftSnapshot = await FirebaseFirestore.instance
          .collection('expedientes')
          .where('driverName', isEqualTo: widget.driverName)
          .where('endTime', isNull: true)
          .orderBy('startTime', descending: true)
          .limit(1)
          .get();

      if (shiftSnapshot.docs.isNotEmpty) {
        setState(() {
          _vehicle = shiftSnapshot.docs.first['vehicle'];
        });
      } else {
        setState(() {
          _vehicle = 'Nenhum expediente ativo';
        });
      }
    } catch (e) {
      setState(() {
        _vehicle = 'Erro ao carregar veículo';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar veículo: $e')),
      );
    }
  }

  Future<void> _fetchClients() async {
    try {
      QuerySnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .where('driverName', isEqualTo: widget.driverName)
          .get();
      setState(() {
        _clientOptions = clientSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar clientes: $e')),
      );
    }
  }

  Future<void> _checkClientSignatureRequirement() async {
    String clientName = _clientController.text.trim();
    if (clientName.isEmpty) {
      setState(() {
        _requiresSignature = false;
      });
      return;
    }

    try {
      QuerySnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .where('name', isEqualTo: clientName)
          .where('driverName', isEqualTo: widget.driverName)
          .get();

      if (clientSnapshot.docs.isNotEmpty) {
        setState(() {
          _requiresSignature = clientSnapshot.docs.first['requiresSignature'] ?? false;
        });
      } else {
        setState(() {
          _requiresSignature = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar cliente: $e')),
      );
    }
  }

  void _formatCurrency() {
    String text = _valueController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) {
      _valueController.text = 'R\$ 0,00';
      return;
    }

    double value = double.parse(text) / 100;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String formatted = formatter.format(value);
    _valueController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _saveRide() async {
    bool hasSignature = _signatureController.value.isNotEmpty;

    // Validação: exige assinatura apenas se _requiresSignature for true
    if (_selectedDateTime == null ||
        _vehicle == null ||
        _vehicle == 'Nenhum expediente ativo' ||
        _vehicle == 'Erro ao carregar veículo' ||
        _valueController.text.isEmpty ||
        _clientController.text.trim().isEmpty ||
        (_requiresSignature && !hasSignature)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e forneça a assinatura, se necessário!')),
      );
      return;
    }

    try {
      String clientName = _clientController.text.trim();
      // Verificar se o cliente já existe
      QuerySnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .where('name', isEqualTo: clientName)
          .where('driverName', isEqualTo: widget.driverName)
          .get();

      if (clientSnapshot.docs.isEmpty) {
        // Cadastrar novo cliente
        await FirebaseFirestore.instance.collection('clientes').add({
          'name': clientName,
          'driverName': widget.driverName,
          'requiresSignature': false,
        });
      }

      // Salvar a corrida
      String rawValue = _valueController.text.replaceAll(RegExp(r'[^0-9]'), '');
      double value = double.parse(rawValue) / 100;

      await FirebaseFirestore.instance.collection('corridas').add({
        'dateTime': Timestamp.fromDate(_selectedDateTime!),
        'driverName': widget.driverName,
        'vehicle': _vehicle,
        'value': value,
        'clientName': clientName,
        // A assinatura será implementada em um passo futuro com Firebase Storage
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar corrida: $e')),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Corrida'),
        content: const Text('Tem certeza que deseja descartar esta corrida?'),
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
        title: const Text('Cadastro de Vendas'),
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
            onPressed: _saveRide,
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
              onPressed: _selectDateTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _selectedDateTime == null
                    ? 'Selecionar Data e Hora'
                    : DateFormat('d MMM, yyyy HH:mm', 'pt_BR').format(_selectedDateTime!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Motorista', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: widget.driverName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Veículo', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: _vehicle ?? 'Carregando...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Valor da Corrida', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'R\$ 0,00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cliente', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _clientOptions.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _clientController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                _clientController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (value) => onFieldSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome do cliente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
            ),
            if (_requiresSignature) ...[
              const SizedBox(height: 20),
              const Text('Assinatura', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Signature(
                  controller: _signatureController,
                  height: 150,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _signatureController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Limpar Assinatura'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}