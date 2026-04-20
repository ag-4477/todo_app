import 'package:flutter/material.dart';

import '../models/todo.dart'; // 作成したTodoクラス
import '../services/todo_service.dart'; // データ保存サービス
import '../widgets/todo_card.dart'; // 作成したTodoCardウィジェット
import '../screens/add_todo_screen.dart'; // 追加画面のインポート

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.todoService, // ❗️ 引数としてtodoServiceを受け取るようにしましょう（必須であることを示す required を忘れずに！）
  });

  final TodoService todoService;

  @override
  State<TodoList> createState() => TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todos = [];
  // ❗️ 読み込み中であることを示すフラグ _isLoading を変数として定義しましょう
  // 画面表示時は読み込み中であることを示すために true を代入しましょう
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ❗️ Todoリストのデータを読み込むため、TodoListState で定義した _loadTodos() を呼び出しましょう
    _loadTodos();
  }

  // データ読み込み処理関数を追加
  Future<void> _loadTodos() async {
    final todos = await widget.todoService.getTodos();
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  // 追加画面から呼ばれる追加関数を追加
  void addTodo(Todo newTodo) async {
    setState(() => _todos.add(newTodo));
    await widget.todoService.saveTodos(_todos);
  }

  // チェックボタンから呼ばれる削除関数を追加
  Future<void> _deleteTodo(Todo todo) async {
    setState(() => _todos.removeWhere((t) => t.id == todo.id));
    await widget.todoService.saveTodos(_todos);
  }

  Future<void> _updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index == -1) return;

    setState(() {
      _todos[index] = updatedTodo;
    });
    await widget.todoService.saveTodos(_todos);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) { // 読込中はローディングインジケーターを表示
      return const Center(child:
      // ❗️ CircularProgressIndicator を表示してみましょう
      CircularProgressIndicator()
      );
    }
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index]; // ←追加
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TodoCard(
            todo: todo,
            onToggle: () => _deleteTodo(todo), // チェックで削除する処理を追加
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTodoScreen(
                    todoService: widget.todoService,
                    todo: todo,
                  ),
                ),
              );

              if (updated != null) {
                _loadTodos(); // 更新されたTodoがあればリストを再読み込みして反映させる
              }
            },
          ),
        );
      },
    );
  }
}