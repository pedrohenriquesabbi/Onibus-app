import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class NotificationService {
  static Future<void> agendarNotificacao({
    required String rotaId,
    required String nome,
    required String horarioSaida,
  }) async {
    try {
      final partes = horarioSaida.split(':');
      final hora = int.parse(partes[0]);
      final minuto = int.parse(partes[1]);

      final agora = tz.TZDateTime.now(tz.local);
      final saida = tz.TZDateTime(
        tz.local,
        agora.year,
        agora.month,
        agora.day,
        hora,
        minuto,
      );

      final notificarEm = saida.subtract(const Duration(minutes: 5));

      if (notificarEm.isBefore(agora)) {
        print('⏰ Horário já passou. Notificação não agendada.');
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        rotaId.hashCode,
        'Ônibus saindo em 5 minutos!',
        'Rota: $nome',
        notificarEm,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'canal_onibus',
            'Notificações do Ônibus',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Erro ao agendar notificação: $e');
    }
  }
}
