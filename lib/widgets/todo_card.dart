import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // dueDateを「12月30日(月)」形式で表示するために使う
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo; // このカードに表示するデータ（title / detail / dueDate を使って表示しよう）
  final VoidCallback? onToggle; // チェックボタンを押したときの処理（onPressedに渡して呼ばれるようにしよう）
  final VoidCallback onTap; // カード全体がタップされたときの処理（onTapに渡して呼ばれるようにしよう）
  const TodoCard({
    super.key,
    required this.todo,
    this.onToggle,
    required this.onTap, // チェックボタンを押したときの処理も引数として受け取るようにしよう（requiredは必須であることを示すキーワードです）
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // カード全体がタップされたときの処理を追加
      child:Card(
      color: Color(todo.colorBackground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // チェックボタン：isCompletedでアイコンを出し分け、押したらonToggleが呼ばれるようにしよう
            IconButton(
              iconSize: 32,
              icon: Icon(
                todo.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: Colors.white,
              ),
              onPressed: onToggle,
            ),
            const SizedBox(width: 8),
            // テキスト群：横に伸ばしたいのでExpandedで包もう
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    todo.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('M月d日(E)', 'ja').format(todo.dueDate),
                    // dueDateを日本語表記に変換して表示しよう
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}