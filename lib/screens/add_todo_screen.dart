import 'package:flutter/material.dart';
import '../services/todo_service.dart'; // 作成したTodoServiceクラス
import '../models/todo.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({
    super.key, 
    required this.todoService,
    this.todo,
  });

  final Todo? todo; // 編集するTodo（新規作成の場合はnull）
  final TodoService todoService;

  @override
  AddTodoScreenState createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  // 入力内容を管理するコントローラー
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _dateController =
      TextEditingController(); // 期日表示用
  final TextEditingController _colorController =
      TextEditingController(); // カラー表示用

  DateTime? _selectedDate; // 選択された期日
  Color _selectedColor = Colors.blue; // 選択された背景色

  // フォームの入力検証用
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFormValid = false; // フォーム入力が完了しているか

  @override
  void initState() {
    super.initState();
    // テキストと期日の入力が変わるたびにチェック

    if (widget.todo != null) {
      // 編集モードの場合、既存のTodoの内容をコントローラーにセット
      _titleController.text = widget.todo!.title;
      _detailController.text = widget.todo!.detail;
      _selectedDate = widget.todo!.dueDate;
      _dateController.text =
          '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}';
      _selectedColor = Color(widget.todo!.colorBackground);
    }

    _titleController.addListener(_updateFormValid);
    _detailController.addListener(_updateFormValid);
    _dateController.addListener(_updateFormValid);
  }

  /// 全入力欄が埋まっているかを判定し、
  /// ボタンの活性状態（押せる/押せない）を更新するメソッド
  void _updateFormValid() {
    setState(() {
      _isFormValid = _titleController.text.isNotEmpty &&
          _detailController.text.isNotEmpty &&
          _selectedDate != null; // 期日が選択されているか
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいタスクを追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // 入力フォームの枠組み
          key: _formKey,
          child: Column(
            children: [
              // タイトル入力フィールド
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タスクのタイトル',
                  hintText: '20文字以内で入力してください',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // 入力チェック
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  } else if (value.length > 20) {
                    return '20文字以内で入力してください';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16), // 余白
              // ❗️ タイトル入力フィールドを参考に、TextFormFieldを使用して詳細入力フィールドを実装してみましょう(ただ、以下のコメントの部分で仕様が異なります)
              /**
               *  1. ラベルとヒントテキストの文言
               *  2. 三行を超えると入力できなくなる
               *  3. 文字数制限はなし
               */
              TextFormField(
                controller: _detailController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "タスクの詳細",
                  hintText: "タスクの内容を入力してください",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '詳細を入力してください';
                  } else if (value.split("\n").length > 3) {
                    return '三行以内で入力してください';
                  }
                  return null;
                },
              ),
              

              const SizedBox(height: 16),

              // 📅 期日入力フィールド（DatePicker）
              TextFormField(
                controller: _dateController,
                readOnly: true, // キーボードを表示しない
                decoration: const InputDecoration(
                  labelText: '期日',
                  hintText: '年/月/日',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  // 日付選択ダイアログを開く
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    // 選択した日付をコントローラに反映
                    _selectedDate = picked;
                    _dateController.text =
                        '${picked.year}/${picked.month}/${picked.day}';

                    // 期日を選んだあともフォーム状態を再評価
                    _updateFormValid();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '期日を選択してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 追加するタスクの背景色を選ぶためのカラーピッカーを実装してみましょう
              ElevatedButton(
                onPressed: () {
                  // カラーピッダーダイアログを開く処理を追加してみましょう
                  if (_isFormValid) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("背景色を選択"),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: _selectedColor, // デフォルトの色
                              onColorChanged: (color) {
                                Navigator.of(context).pop(); // ダイアログを閉じる
                                setState(() {
                                  _selectedColor = color;                                  
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: const Text("背景色を選択"),
              ),
              Container(
                width: 50,
                height: 50,
                color: _selectedColor,
              ),
              const SizedBox(height: 24),

              // 作成ボタン
              ElevatedButton(
                onPressed: _isFormValid ? () => _saveTodo() : null, // 作成時に保存する処理を追加
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid
                      ? const Color.fromARGB(255, 0, 0, 255)
                      : Colors.grey.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ), // 入力完了で活性化
                child: Text(
                  'タスクを追加',
                  // テキストの色を変更
                  style: TextStyle(
                    color: _isFormValid ? Colors.white : Colors.grey.shade700,
                    // ❗️ 活性状態は白、非活性状態はグレーにテキストの色を設定してみましょう
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final todo = Todo(
      id: widget.todo?.id,
      title: _titleController.text,
      detail: _detailController.text,
      dueDate: _selectedDate!,
      isCompleted: widget.todo?.isCompleted ?? false,
      colorBackground: _selectedColor.value,
    );

    // ❗️ 追加：リストを一度読み込んで、新しいタスクを追加して保存する
    final currentTodos = await widget.todoService.getTodos();
    
    if (widget.todo == null) {
      // 新規作成
      currentTodos.add(todo);
    } else {
      // 編集（既存のIDを探して入れ替え）
      final index = currentTodos.indexWhere((t) => t.id == todo.id);
      if (index != -1) currentTodos[index] = todo;
    }
    
    await widget.todoService.saveTodos(currentTodos); // 保存！

    if (!mounted) return;
    Navigator.pop(context, todo); // 結果を返して戻る
  }

  @override
  void dispose() {
    // 画面が閉じられる時の処理
    _titleController.dispose(); // メモリの解放
    _detailController.dispose();
    _dateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初期表示時にもバリデーション
    _updateFormValid();
  }
}