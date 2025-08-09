import 'package:shared_preferences/shared_preferences.dart';

class SalvarRotaLocalService {
  static Future<void> salvarRotaLocalmente(String rotaId, String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rota_id', rotaId);
    await prefs.setString('rota_nome', nome);
  }

  static Future<Map<String, String>?> carregarRotaLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('rota_id');
    final nome = prefs.getString('rota_nome');

    if (id != null && nome != null) {
      return {'id': id, 'nome': nome};
    }
    return null;
  }
}
