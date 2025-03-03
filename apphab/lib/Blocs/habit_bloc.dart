import 'package:apphab/Models/habit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definimos los eventos
abstract class HabitEvent {}

class LoadHabits extends HabitEvent {}

class AddHabit extends HabitEvent {
  final Habit habit;
  AddHabit(this.habit);
}

class UpdateHabit extends HabitEvent {
  final Habit habit;
  UpdateHabit(this.habit);
}

class DeleteHabit extends HabitEvent {
  final String habitId;
  DeleteHabit(this.habitId);
}

// Definimos los estados
abstract class HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<Habit> habits;
  HabitLoaded(this.habits);
}

class HabitError extends HabitState {
  final String message;
  HabitError(this.message);
}

// Implementamos el Bloc
class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Getter que obtiene el UID del usuario logueado
  // Lanza una excepción si currentUser es null
  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No hay usuario logueado. UID es null.");
    }
    return user.uid;
  }

  // Constructor sin necesidad de pasar el uid
  HabitBloc() : super(HabitLoading()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
  }

  /// Carga los hábitos desde Usuarios/{uid}/habits
  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final snapshot = await firestore
          .collection('Usuarios')
          .doc(_uid)
          .collection('habits')
          .get();

      final habits = snapshot.docs
          .map((doc) => Habit.fromMap(doc.data(), doc.id))
          .toList();

      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Error al cargar hábitos: $e'));
    }
  }

  /// Agrega un hábito a la ruta Usuarios/{uid}/habits
  Future<void> _onAddHabit(AddHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore
          .collection('Usuarios')
          .doc(_uid)
          .collection('habits')
          .doc(event.habit.id)
          .set(event.habit.toMap());

      add(LoadHabits());
    } catch (e) {
      emit(HabitError('Error al agregar hábito: $e'));
    }
  }

  /// Actualiza un hábito en Usuarios/{uid}/habits
  Future<void> _onUpdateHabit(
      UpdateHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore
          .collection('Usuarios')
          .doc(_uid)
          .collection('habits')
          .doc(event.habit.id)
          .update(event.habit.toMap());

      add(LoadHabits());
    } catch (e) {
      emit(HabitError('Error al actualizar hábito: $e'));
    }
  }

  /// Elimina un hábito de Usuarios/{uid}/habits
  Future<void> _onDeleteHabit(
      DeleteHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore
          .collection('Usuarios')
          .doc(_uid)
          .collection('habits')
          .doc(event.habitId)
          .delete();

      add(LoadHabits());
    } catch (e) {
      emit(HabitError('Error al eliminar hábito: $e'));
    }
  }
}
