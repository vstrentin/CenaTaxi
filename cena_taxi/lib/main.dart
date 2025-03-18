import 'package:cena_taxi/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Fundo branco
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//               // Logo
//               Image.asset(
//                 'assets/images/taxi_do_alemao_logo.png', // Substitua pelo caminho do seu logo
//                 //height: 150, // Ajuste conforme o tamanho do logo
//               ),
//               SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//               // Campo de Username
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Username',
//                   labelStyle: const TextStyle(color: Colors.black54),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.black),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.black),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.yellow, width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Campo de Senha
//               TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Senha',
//                   labelStyle: const TextStyle(color: Colors.black54),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.black),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.black),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: const BorderSide(color: Colors.yellow, width: 2),
//                   ),
//                 ),
//               ),
//               SizedBox(height: MediaQuery.of(context).size.height * 0.05),
//               // Botão de Entrar
//               ElevatedButton(
//                 onPressed: () {
//                   // Integração com Firebase será adicionada aqui
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFFFC107), // Amarelo
//                   foregroundColor: Colors.black, // Texto preto
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25.0),
//                   ),
//                 ),
//                 child: const Text(
//                   'Entrar',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }