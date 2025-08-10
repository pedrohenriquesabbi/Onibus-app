import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/config_page.dart';
import '../screens/account_info_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF424242),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF303030)),
            child: Text(
              'Menu Principal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white70),
            title: const Text(
              'Meu Perfil',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountInfoPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white70),
            title: const Text(
              'Configurações',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConfigPage()),
              );
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              // Apenas fecha o drawer antes de fazer o logout
              Navigator.of(context).pop();
              // 2. CHAMA A FUNÇÃO DE LOGOUT DO FIREBASE
              FirebaseAuth.instance.signOut();
              // Não precisa de navegação, o "Guardião" cuidará disso.
            },
          ),
        ],
      ),
    );
  }
}
