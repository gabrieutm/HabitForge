import 'package:hive/hive.dart';
import '../models/habit.dart';

/// Camada bem fininha em cima da box do Hive. Nao ficou "bonito" ou
/// desacoplado (sem interface/abstracao), mas pra um projeto solo desse
/// tamanho seria over-engineering colocar um repository pattern completo
/// com interfaces agora. Se um dia precisar trocar Hive por outra coisa,
/// refatora aqui.
class HabitRepository {
  static const String boxName = 'habits';

  Box<Habit> get _box => Hive.box<Habit>(boxName);

  List<Habit> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> save(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Habit? getById(String id) {
    return _box.get(id);
  }
}
