/// Utilitarios de data usados no calculo de streak.
///
/// Tudo aqui trabalha com datas "normalizadas" (sem hora, so
/// ano/mes/dia) porque comparar DateTime com hora embutida da problema
/// bobo de igualdade (e foi exatamente isso que me mordeu quando testei
/// virada de mes pela primeira vez -- ver README).
class DateUtils2 {
  DateUtils2._();

  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String toKey(DateTime date) {
    final d = normalize(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static DateTime fromKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
