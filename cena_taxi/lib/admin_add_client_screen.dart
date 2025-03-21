import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAddClientScreen extends StatefulWidget {
  const AdminAddClientScreen({super.key});

  @override
  _AdminAddClientScreenState createState() => _AdminAddClientScreenState();
}

class _AdminAddClientScreenState extends State<AdminAddClientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _requiresAdditionalInfo = false;
  bool _requiresSignature = false;

  Future<void> _saveClient() async {
    if (_nameController.text.trim().isEmpty || _documentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('clientes').add({
        'name': _nameController.text.trim(),
        'document': _documentController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'requiresAdditionalInfo': _requiresAdditionalInfo,
        'requiresSignature': _requiresSignature,
        // Não incluímos driverName, pois o administrador gerencia todos os clientes
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar cliente: $e')),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Cliente'),
        content: const Text('Tem certeza que deseja descartar este cliente?'),
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
        title: const Text('Cadastrar Cliente'),
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
            onPressed: _saveClient,
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
                hintText: 'Digite o nome do cliente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Documento* (CPF/RG/Passaporte)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _documentController,
              decoration: InputDecoration(
                hintText: 'Digite o documento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Digite o email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Telefone', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Digite o telefone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _requiresAdditionalInfo,
                  onChanged: (value) {
                    setState(() {
                      _requiresAdditionalInfo = value ?? false;
                    });
                  },
                ),
                const Text('Informações Adicionais'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _requiresSignature,
                  onChanged: (value) {
                    setState(() {
                      _requiresSignature = value ?? false;
                    });
                  },
                ),
                const Text('Requer Assinatura'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}