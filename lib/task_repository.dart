// class Task {
//   final String title;
//   final String deadline;
//   bool done;
//   final String priority;

//   Task({
//     required this.title,
//     required this.deadline,
//     required this.done,
//     required this.priority,
//   });
// }

import 'models/task.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Projekt Flutter",
      deadline: "jutro",
      done: false,
      priority: "wysoki",
    ),
    Task(
      title: "Ćwiczenia z matematyki",
      deadline: "dzisiaj",
      done: true,
      priority: "wysoki",
    ),
    Task(
      title: "Przeczytać o widgetach",
      deadline: "w tym tygodniu",
      done: false,
      priority: "średni",
    ),
    Task(
      title: "Zrobić trening",
      deadline: "dzisiaj",
      done: false,
      priority: "niski",
    ),
    Task(
      title: "Zjeść obiag",
      deadline: "jutro",
      done: false,
      priority: "niski",
    ),
    Task(
      title: "Nauczyć się na egzamin",
      deadline: "w następnym tygodniu",
      done: false,
      priority: "niski",
    ),
  ];
}
