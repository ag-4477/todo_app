import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/list_screen.dart';
import 'services/todo_service.dart';
// ほかの import は省略

void main() async {
  // Flutter のプラグイン初期化。非同期処理を行う場合は必須
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // ❗️ SharedPreferences のインスタンスを作成してみましょう
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // ❗️ 作成した prefs を引数として TodoService のインスタンスを作成してみましょう
  final TodoService todoService = TodoService(prefs);

  runApp(MyApp(
    todoService: todoService, // ❗️ 最後にMyAppへtodoServiceを引数として渡してみましょう
  ));

}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.todoService,  // 引数として TodoService を受け取るようにします（required は引数として必須であることを示すキーワードです）
  });

  // アプリ全体で共有する TodoService を引数として受け取るために変数として定義します
  final TodoService todoService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListScreen(
        // ❗️ ListScreen へ todoService を引数としてわたしてみましょう
        todoService: todoService,
      ),
    );
  }
}