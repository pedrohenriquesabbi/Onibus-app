// lib/services/rota_local_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class RotaLocalStorage {
  static const _keyId = 'rota_id';
  static const _keyNome = 'rota_nome';
  static const _keyHorario = 'rota_horario';

  static Future<void> salvar({
    required String id,
    required String nome,
    required String horario,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyId, id);
    await prefs.setString(_keyNome, nome);
    await prefs.setString(_keyHorario, horario);
  }

  static Future<Map<String, String>?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyId);
    final nome = prefs.getString(_keyNome);
    final horario = prefs.getString(_keyHorario);

    if (id != null && nome != null && horario != null) {
      return {'id': id, 'nome': nome, 'horario': horario};
    }
    return null;
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyNome);
    await prefs.remove(_keyHorario);
  }
}
