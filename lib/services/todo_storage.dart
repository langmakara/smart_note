import '../models/todo_model.dart';
import 'hive_database.dart';

class TodoStorage {
  static final TodoStorage instance = TodoStorage._init();
  TodoStorage._init();

  Future<void> initialize() async {}

  Future<List<Todo>> readAllTodos() async {
    try {
      return await HiveDatabase.instance.getAllTodos();
    } catch (e) {
      return [];
    }
  }

  Future<void> create(Todo todo) async {
    await HiveDatabase.instance.saveTodo(todo);
  }

  Future<void> update(Todo updatedTodo) async {
    await HiveDatabase.instance.updateTodo(updatedTodo);
  }

  Future<void> delete(String id) async {
    await HiveDatabase.instance.deleteTodo(id);
  }

  Future<void> addItem(String todoId, TodoItem item) async {
    final todos = await readAllTodos();
    final todo = todos.firstWhere((t) => t.id == todoId);
    todo.items.add(item);
    await update(todo);
  }

  Future<void> toggleItem(String todoId, String itemId) async {
    final todos = await readAllTodos();
    final todo = todos.firstWhere((t) => t.id == todoId);
    final item = todo.items.firstWhere((i) => i.id == itemId);
    item.isCompleted = !item.isCompleted;
    if (todo.items.every((i) => i.isCompleted)) {
      todo.isCompleted = true;
    } else {
      todo.isCompleted = false;
    }
    await update(todo);
  }

  Future<void> removeItem(String todoId, String itemId) async {
    final todos = await readAllTodos();
    final todo = todos.firstWhere((t) => t.id == todoId);
    todo.items.removeWhere((i) => i.id == itemId);
    await update(todo);
  }
}
