import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/habit.dart';

/// Servico de notificacoes locais recorrentes.
///
/// LIMITACOES CONHECIDAS (documentado de proposito, nao e coisa que
/// "esqueci"):
/// - A notificacao dispara no horario agendado independente do habito ja
///   ter sido marcado como concluido naquele dia. Cancelar dinamicamente
///   so a ocorrencia do dia exigiria reagendar toda vez que o usuario
///   marca/desmarca, e cada "dia da semana" já é um agendamento recorrente
///   separado (nao da pra simplesmente "pular hoje" com a API do plugin).
///   Fica como melhoria futura.
/// - Em alguns fabricantes de Android com otimizacao de bateria agressiva
///   (Xiaomi, Samsung com "sleeping apps", etc) o alarme pode nao disparar
///   mesmo com tudo configurado certo. Isso e uma limitacao do Android, nao
///   do app -- nao tem muito o que fazer alem de orientar o usuario a
///   desativar a otimizacao de bateria pro app nas configuracoes do sistema.
/// - Android 12+ exige permissao de "alarme exato" (SCHEDULE_EXACT_ALARM)
///   pra notificacao disparar no minuto certo. Sem ela o SO pode atrasar
///   o disparo por conta de agrupamento de bateria.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Usando o fuso horario local do dispositivo. Nao tentamos "seguir" o
    // usuario se ele viajar de fuso -- decisao consciente de escopo, ver README.
    tz.setLocalLocation(tz.getLocation(await _resolveLocalTimezoneName()));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings);
    _initialized = true;
  }

  // Placeholder simples: numa implementacao completa usariamos o pacote
  // flutter_timezone pra pegar o nome real (ex: "America/Sao_Paulo").
  // Por hora fixamos UTC como fallback documentado -- funciona pro
  // agendamento relativo, mas o ideal seria detectar o fuso do aparelho.
  // TODO: trocar por flutter_timezone quando sobrar tempo.
  Future<String> _resolveLocalTimezoneName() async {
    return 'America/Sao_Paulo';
  }

  Future<bool> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = true;
    if (androidImpl != null) {
      final notifGranted = await androidImpl.requestNotificationsPermission();
      final exactAlarmGranted = await androidImpl.requestExactAlarmsPermission();
      granted = (notifGranted ?? true) && (exactAlarmGranted ?? true);
    }
    if (iosImpl != null) {
      granted = await iosImpl.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    }
    return granted;
  }

  /// Cada dia da semana agendado vira uma notificacao recorrente separada.
  /// O id da notificacao e derivado do id do habito + weekday pra
  /// conseguirmos cancelar/reagendar individualmente depois.
  int _notificationId(String habitId, int weekday) {
    return (habitId.hashCode & 0xFFFFF) * 10 + weekday;
  }

  Future<void> scheduleForHabit(Habit habit) async {
    await cancelForHabit(habit);

    for (final weekday in habit.weekdays) {
      final scheduledDate = _nextInstanceOfWeekdayAndTime(
        weekday,
        habit.reminderHour,
        habit.reminderMinute,
      );

      await _plugin.zonedSchedule(
        _notificationId(habit.id, weekday),
        'Hora de: ${habit.name}',
        'Nao deixe sua streak quebrar 🔥',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Lembretes de habitos',
            channelDescription: 'Notificacoes recorrentes dos habitos cadastrados',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelForHabit(Habit habit) async {
    // Cancela pra todos os 7 dias possiveis (nao so os atuais) porque o
    // habito pode ter sido editado e ter perdido algum dia -- assim garante
    // que nao fica notificacao orfa de um dia que foi removido na edicao.
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(_notificationId(habit.id, weekday));
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
