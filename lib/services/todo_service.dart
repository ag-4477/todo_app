import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/todo.dart';
import 'package:flutter/material.dart';

class TodoService {
  static const String _storageKey = 'todos';
  final SharedPreferences _prefs;

  TodoService(this._prefs);

  // 保存されているTODOリストを読み込む（非同期処理）
  Future<List<Todo>> getTodos() async {
    // 保存されているJSONデータを取得
    final String? todosJson = await _prefs.getString(_storageKey);

    // データがない場合は空のリストを返す
    if (todosJson == null) return [];

    // JSON文字列をDartのオブジェクトに変換
    final List<dynamic> decoded = jsonDecode(todosJson);

    return decoded
        .map((json) => Todo(
              id: json['id'],
              title: json['title'],
              detail: json['detail'] ?? '', 
              dueDate: DateTime.parse(json['dueDate'] ??
                  DateTime.now().toIso8601String()), // dueDateがない場合は現在日時
              isCompleted: json['isCompleted'],
              colorBackground: json['colorBackground'] ?? Colors.blue.toARGB32(), // colorBackgroundがない場合は青色
            ))
        .toList();
  }

  // TODOリストを保存する（非同期処理）
  Future<void> saveTodos(List<Todo> todos) async {
    // TodoオブジェクトをJSONに変換できる形に変換
    final List<Map<String, dynamic>> jsonData = todos
        .map((todo) => {
              'id': todo.id,
              'title': todo.title,
              'detail': todo.detail,
              'dueDate': todo.dueDate.toIso8601String(),
              'isCompleted': todo.isCompleted,
              'colorBackground': todo.colorBackground, // カラーの値を保存
            })
        .toList();

    // JSON文字列に変換
    final String encoded = jsonEncode(jsonData);
    
    // 変換した文字列を保存
    await _prefs.setString(_storageKey, encoded);
  }
}