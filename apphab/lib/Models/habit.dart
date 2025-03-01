class Habit {
  final String id;
  final String title;
  final bool isActive; // Para saber si el hábito está activado o no
  final String description;
  final List<bool>
      days; // Lista de 7 valores (true/false) para los días de la semana
  final String reminderTime; // Hora del recordatorio en formato HH:mm
  final double completionRate; // Porcentaje de cumplimiento

  Habit({
    required this.id,
    required this.title,
    required this.isActive,
    required this.description,
    required this.days,
    required this.reminderTime,
    required this.completionRate,
  });

  // Convertir un objeto Habit a un mapa (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isActive': isActive,
      'description': description,
      'days': days,
      'reminderTime': reminderTime,
      'completionRate': completionRate,
    };
  }

  // Crear un objeto Habit desde un mapa (para Firestore)
  factory Habit.fromMap(Map<String, dynamic> map, String documentId) {
    return Habit(
      id: documentId,
      title: map['title'] ?? '',
      isActive: map['isActive'] ?? true,
      description: map['description'] ?? '',
      days: List<bool>.from(
          map['days'] ?? [false, false, false, false, false, false, false]),
      reminderTime: map['reminderTime'] ?? '00:00',
      completionRate: map['completionRate'] ?? 0.0,
    );
  }
}
