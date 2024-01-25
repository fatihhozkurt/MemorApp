import 'package:get/get.dart';
import 'package:task_management/db/db_helper.dart';
import 'package:task_management/models/task.dart';

class TaskController extends GetxController {
  //this will hold the data and update the ui

  @override
  void onReady() {
    getTasks();
    super.onReady();
  }

  final RxList<Task> taskList = List<Task>.empty().obs;

  // add data to table
  //second brackets means they are named optional parameters
  Future<void> addTask({required Task task}) async {
    await DBHelper.insert(task);
  }

  // get all the data from table
  void getTasks() async {
    List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
  }

  // delete data from table
  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  // update data int table
  void markTaskCompleted(int? id) async {
    await DBHelper.update(id);
    getTasks();
  }
}
