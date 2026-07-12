import '../models/habit.dart';
import '../utils/date_utils.dart';

/// Motor de calculo de streak.
///
/// Regra de negocio (documentada aqui porque nao ta escrita em nenhum
/// outro lugar e eu mesmo já me perdi revendo isso depois de um tempo):
///
/// - O habito tem dias da semana agendados (ex: seg/qua/sex).
/// - Cada ocorrencia agendada e um "evento". Se o evento foi concluido
///   (na data certa, ou depois, dentro do grace period), ele conta pra streak.
/// - Grace period: se perder um evento (ex: nao marcou quarta), ainda da
///   pra marcar essa data retroativamente ATE o proximo evento agendado
///   comecar (ex: ate sexta 00:00). Se a sexta chegar e a quarta seguir
///   sem marcar, a streak quebra ali -- ou seja, o evento da quarta "expira".
/// - A streak conta quantos eventos agendados consecutivos, terminando
///   hoje (ou no ultimo evento ja expirado), foram cumpridos sem furo.
///
/// Importante: isso NAO conta dias corridos, conta EVENTOS agendados.
/// Um habito de "so segunda" que foi cumprido 10 segundas seguidas tem
/// streak = 10, mesmo passando 10 semanas.
class StreakService {
  StreakService._();

  /// Gera a lista de datas agendadas (eventos) do habito, do createdAt
  /// ate [until] (inclusive), normalizadas.
  static List<DateTime> _scheduledOccurrences(Habit habit, DateTime until) {
    final occurrences = <DateTime>[];
    var cursor = DateUtils2.normalize(habit.createdAt);
    final end = DateUtils2.normalize(until);

    // Guarda de seguranca: nao deixa rodar infinito se algo vier zoado.
    var safety = 0;
    while (!cursor.isAfter(end) && safety < 20000) {
      if (habit.weekdays.contains(cursor.weekday)) {
        occurrences.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
      safety++;
    }
    return occurrences;
  }

  /// Retorna a proxima data agendada estritamente depois de [date].
  /// Usado pra saber ate quando vale o grace period de um evento perdido.
  static DateTime? nextOccurrenceAfter(Habit habit, DateTime date) {
    var cursor = DateUtils2.normalize(date).add(const Duration(days: 1));
    var safety = 0;
    while (safety < 400) {
      if (habit.weekdays.contains(cursor.weekday)) {
        return cursor;
      }
      cursor = cursor.add(const Duration(days: 1));
      safety++;
    }
    return null; // nao deveria acontecer com weekdays nao vazio
  }

  /// Um evento em [date] ainda pode ser marcado (esta "em aberto" ou
  /// dentro do grace period) se hoje for antes do inicio do PROXIMO evento.
  static bool isWithinGracePeriod(Habit habit, DateTime eventDate, DateTime now) {
    final next = nextOccurrenceAfter(habit, eventDate);
    if (next == null) return true;
    return DateUtils2.normalize(now).isBefore(next);
  }

  /// Recalcula currentStreak e bestStreak com base em completedDates.
  /// Retorna um record com os dois valores (nao mexe no objeto habit
  /// diretamente pra deixar a funcao facil de testar isoladamente).
  static ({int current, int best}) calculate(Habit habit, {DateTime? now}) {
    final today = DateUtils2.normalize(now ?? DateTime.now());
    final completedKeys = habit.completedDates.toSet();

    final occurrences = _scheduledOccurrences(habit, today);
    if (occurrences.isEmpty) {
      return (current: 0, best: 0);
    }

    int current = 0;
    int best = 0;
    int running = 0;

    for (final occurrence in occurrences) {
      final isDone = completedKeys.contains(DateUtils2.toKey(occurrence));
      final graceOk = isWithinGracePeriod(habit, occurrence, today);

      if (isDone) {
        running += 1;
        if (running > best) best = running;
      } else if (graceOk) {
        // Evento ainda em aberto (dentro do grace period): nao quebra a
        // streak ainda, mas tambem nao conta -- fica "pendente".
        // Nao reseta `running` porque o usuario ainda pode salvar essa streak.
      } else {
        // Evento expirado sem ter sido cumprido: quebra a streak.
        running = 0;
      }
    }

    current = running;
    return (current: current, best: best > current ? best : current);
  }
}
