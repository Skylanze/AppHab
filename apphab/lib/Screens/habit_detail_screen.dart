import 'package:apphab/Blocs/habit_bloc.dart';
import 'package:apphab/Models/habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  late List<bool> _days;
  late TimeOfDay _selectedTime;
  late double _completionRate;

  @override
  void initState() {
    super.initState();
    // Inicializamos los campos con los valores del hábito
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController =
        TextEditingController(text: widget.habit.description);
    _isActive = widget.habit.isActive;
    _days = List<bool>.from(widget.habit.days); // Copia de la lista
    _completionRate = widget.habit.completionRate;

    // Convertir el string "HH:mm" a TimeOfDay
    final timeParts = widget.habit.reminderTime.split(':');
    int hour = 0;
    int minute = 0;
    if (timeParts.length == 2) {
      hour = int.tryParse(timeParts[0]) ?? 0;
      minute = int.tryParse(timeParts[1]) ?? 0;
    }
    _selectedTime = TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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

  /// Convierte [TimeOfDay] en un String HH:mm (por ejemplo: "09:05").
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Llama a UpdateHabit en el Bloc con la nueva información.
  void _onUpdate() {
    if (_formKey.currentState!.validate()) {
      final updatedHabit = Habit(
        id: widget.habit.id, // Se mantiene el mismo ID
        title: _titleController.text.trim(),
        isActive: _isActive,
        description: _descriptionController.text.trim(),
        days: _days,
        reminderTime: _formatTime(_selectedTime),
        completionRate: _completionRate,
      );

      context.read<HabitBloc>().add(UpdateHabit(updatedHabit));
      Navigator.pop(context); // Vuelve a la pantalla anterior
    }
  }

  /// Llama a DeleteHabit en el Bloc.
  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar hábito"),
        content:
            const Text("¿Estás seguro de que deseas eliminar este hábito?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabit(widget.habit.id));
              Navigator.pop(ctx); // Cerrar el diálogo
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Hábito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _onDelete,
          ),
        ],
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
              /*Text(
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

              // Botón Actualizar
              ElevatedButton(
                onPressed: _onUpdate,
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
