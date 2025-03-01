import 'package:apphab/Models/habit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  HabitBloc() : super(HabitLoading()) {
    on<LoadHabits>(_onLoadHabits);
    on<AddHabit>(_onAddHabit);
    on<UpdateHabit>(_onUpdateHabit);
    on<DeleteHabit>(_onDeleteHabit);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    emit(HabitLoading());
    try {
      final snapshot = await firestore.collection('habits').get();
      final habits = snapshot.docs
          .map((doc) => Habit.fromMap(doc.data(), doc.id))
          .toList();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError('Error al cargar hábitos: $e'));
    }
  }

  Future<void> _onAddHabit(AddHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore.collection('habits').add(event.habit.toMap());
      add(LoadHabits()); // Recargar hábitos
    } catch (e) {
      emit(HabitError('Error al agregar hábito: $e'));
    }
  }

  Future<void> _onUpdateHabit(
      UpdateHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore
          .collection('habits')
          .doc(event.habit.id)
          .update(event.habit.toMap());
      add(LoadHabits()); // Recargar hábitos
    } catch (e) {
      emit(HabitError('Error al actualizar hábito: $e'));
    }
  }

  Future<void> _onDeleteHabit(
      DeleteHabit event, Emitter<HabitState> emit) async {
    try {
      await firestore.collection('habits').doc(event.habitId).delete();
      add(LoadHabits()); // Recargar hábitos
    } catch (e) {
      emit(HabitError('Error al eliminar hábito: $e'));
    }
  }
}
