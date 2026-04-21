import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/list_screen.dart';
import 'services/todo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final TodoService todoService = TodoService(prefs);

  runApp(MyApp(
    todoService: todoService, 
  ));

}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.todoService, 
  });

  final TodoService todoService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListScreen(
        todoService: todoService,
      ),
    );
  }
}