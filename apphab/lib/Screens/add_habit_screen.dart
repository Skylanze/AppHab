import 'package:apphab/Blocs/habit_bloc.dart';
import 'package:apphab/Models/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({Key? key}) : super(key: key);

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isActive = true;
  final List<bool> _days = [false, false, false, false, false, false, false];
  TimeOfDay _selectedTime = TimeOfDay.now();
  double _completionRate = 0.0;

  /// Abre el selector de hora y actualiza [_selectedTime].
  Future<void> _pickTime() async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (newTime != null) {
      setState(() {
        _selectedTime = newTime;
      });
    }
  }

  /// Crea el objeto Habit y lanza el evento AddHabit.
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Generar una cadena de fecha/hora para garantizar unicidad (yyyyMMddHHmmss)
      final dateString = DateFormat('yyyyMMddHHmmss').format(DateTime.now());

      // Combinar el título con la fecha para formar el ID
      final customId = '${_titleController.text.trim()}___$dateString';

      final reminderTime = _formatTime(_selectedTime);

      final newHabit = Habit(
        id: customId, // Usar el ID personalizado
        title: _titleController.text.trim(),
        isActive: _isActive,
        description: _descriptionController.text.trim(),
        days: _days,
        reminderTime: reminderTime,
        completionRate: _completionRate,
      );

      // Disparar el evento en el Bloc
      context.read<HabitBloc>().add(AddHabit(newHabit));
      Navigator.pop(context);
    }
  }

  /// Convierte [TimeOfDay] en un String HH:mm (por ejemplo: "09:05").
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Hábito'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Campo Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del hábito',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Switch para Activar/Desactivar
              SwitchListTile(
                title: const Text('¿Está activo?'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Campo Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Propósito',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Días de la semana (7 checkboxes)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Días de la semana:',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Wrap(
                spacing: 20.0,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(dayLabels[index]),
                    selected: _days[index],
                    onSelected: (bool selected) {
                      setState(() {
                        _days[index] = selected;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Hora de recordatorio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Hora de Recordatorio: ${_selectedTime.format(context)}'),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tasa de cumplimiento
              /* Text(
                  'Tasa de Cumplimiento: ${(_completionRate * 100).toStringAsFixed(0)}%'),
              Slider(
                value: _completionRate,
                onChanged: (value) {
                  setState(() {
                    _completionRate = value;
                  });
                },
              ),
              const SizedBox(height: 16),*/

              // Botón Guardar
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
