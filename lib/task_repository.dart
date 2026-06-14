import 'models/task.dart';

class TaskRepository {
  static List<Task> tasks = [
    Task(
      id: 1,
      title: 'Projekt Flutter',
      deadline: 'jutro',
      done: false,
      priority: 'wysoki',
    ),
    Task(
      id: 2,
      title: 'Cwiczenia z matematyki',
      deadline: 'dzisiaj',
      done: true,
      priority: 'wysoki',
    ),
    Task(
      id: 3,
      title: 'Przeczytac o widgetach',
      deadline: 'w tym tygodniu',
      done: false,
      priority: 'sredni',
    ),
    Task(
      id: 4,
      title: 'Zrobic trening',
      deadline: 'dzisiaj',
      done: false,
      priority: 'niski',
    ),
    Task(
      id: 5,
      title: 'Zjesc obiad',
      deadline: 'jutro',
      done: false,
      priority: 'niski',
    ),
    Task(
      id: 6,
      title: 'Nauczyc sie na egzamin',
      deadline: 'w nastepnym tygodniu',
      done: false,
      priority: 'niski',
    ),
  ];
}
