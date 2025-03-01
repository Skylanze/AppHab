import 'package:apphab/Blocs/habit_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apphab/screens/mainScreen.dart';
import 'package:apphab/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HabitBloc()..add(LoadHabits()), // Cargar hábitos al iniciar
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AppHab',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainScreen(), // Redirigir a la pantalla principal
      ),
    );
  }
}
