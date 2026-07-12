// GENERATED CODE - manually mirrored from build_runner output.
// Nao editar style-guide daqui, mas se mudar campos em habit.dart,
// regerar com: flutter pub run build_runner build --delete-conflicting-outputs

part of 'habit.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      weekdays: (fields[2] as List).cast<int>().toSet(),
      reminderHour: fields[3] as int,
      reminderMinute: fields[4] as int,
      completedDates: (fields[5] as List).cast<String>(),
      createdAt: fields[6] as DateTime,
      currentStreak: fields[7] as int,
      bestStreak: fields[8] as int,
      colorValue: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.weekdays.toList())
      ..writeByte(3)
      ..write(obj.reminderHour)
      ..writeByte(4)
      ..write(obj.reminderMinute)
      ..writeByte(5)
      ..write(obj.completedDates)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.currentStreak)
      ..writeByte(8)
      ..write(obj.bestStreak)
      ..writeByte(9)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
