import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClientDetailScreen extends StatelessWidget {
  final DocumentSnapshot client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    String name = client['name'];
    String document = client['document'];
    String email = client['email'] ?? '';
    String phone = client['phone'] ?? '';
    bool requiresAdditionalInfo = client['requiresAdditionalInfo'] ?? false;
    bool requiresSignature = client['requiresSignature'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/taxi_do_alemao_logo.png', height: 30),
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
              enabled: false,
              decoration: InputDecoration(
                hintText: name,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Documento* (CPF/RG/Passaporte)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: document,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: email.isEmpty ? 'Não informado' : email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Telefone', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: phone.isEmpty ? 'Não informado' : phone,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: requiresAdditionalInfo,
                  onChanged: null, // Desabilitado, apenas visualização
                ),
                const Text('Informações Adicionais'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: requiresSignature,
                  onChanged: null, // Desabilitado, apenas visualização
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