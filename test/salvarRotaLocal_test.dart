import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:engenharia_de_software/services/salvarRotaLocal_service.dart';

void main() {
  group('SalvarRotaLocalService', () {
    const rotaId = 'rota123';
    const rotaNome = 'Rota Teste';

    setUp(() {
      // Limpa o mock antes de cada teste
      SharedPreferences.setMockInitialValues({});
    });

    test('deve salvar o ID e nome da rota localmente', () async {
      await SalvarRotaLocalService.salvarRotaLocalmente(rotaId, rotaNome);
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getString('rota_id'), equals(rotaId));
      expect(prefs.getString('rota_nome'), equals(rotaNome));
    });

    test('deve carregar o ID e nome da rota corretamente', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('rota_id', rotaId);
      await prefs.setString('rota_nome', rotaNome);

      final rota = await SalvarRotaLocalService.carregarRotaLocal();
      expect(rota?['id'], equals(rotaId));
      expect(rota?['nome'], equals(rotaNome));
    });

    test('deve retornar null se nenhuma rota estiver salva', () async {
      final rota = await SalvarRotaLocalService.carregarRotaLocal();
      expect(rota, isNull);
    });
  });
}
