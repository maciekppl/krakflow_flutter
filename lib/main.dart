import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'services/task_api_services.dart';
import 'models/task.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'services/task_local_database.dart';
import 'services/task_sync_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // inicjalizacja
  await Hive.openBox("tasks"); // otwarcie kontenera

  runApp(const MyApp())
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),

        actions: [
          IconButton(
            icon: Icon(Icons.delete),

            onPressed: () {
              showDialog(
                context: context,

                builder: (context) {
                  return AlertDialog(
                    title: Text("Potwierdzenie"),

                    content: Text(
                      "Czy na pewno chcesz usunąć wszystkie zadania?",
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        child: Text("Anuluj"),
                      ),

                      TextButton(
                        onPressed: () {
                          setState(() {
                            TaskRepository.tasks.clear();
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Usunięto wszystkie zadania"),
                            ),
                          );
                        },

                        child: Text("Usuń"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),

            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wszystkie";
                    });
                  },
                  child: Text(
                    "Wszystkie",
                    style: TextStyle(
                      color: selectedFilter == "wszystkie"
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "do zrobienia";
                    });
                  },
                  child: Text(
                    "Do zrobienia",
                    style: TextStyle(
                      color: selectedFilter == "do zrobienia"
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "wykonane";
                    });
                  },
                  child: Text(
                    "Wykonane",
                    style: TextStyle(
                      color: selectedFilter == "wykonane"
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Text(
              "Dzisiejsze zadania",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,

                builder: (context, snapshot) {
                  // LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // ERROR
                  if (snapshot.hasError) {
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  }

                  // BRAK DANYCH
                  if (!snapshot.hasData) {
                    return const Center(child: Text("Brak danych"));
                  }

                  // DATA
                  final tasks = snapshot.data!;

                  int doneCount = tasks.where((task) => task.done).length;

                  List<Task> filteredTasks = tasks;

                  if (selectedFilter == "wykonane") {
                    filteredTasks = tasks.where((task) => task.done).toList();
                  } else if (selectedFilter == "do zrobienia") {
                    filteredTasks = tasks.where((task) => !task.done).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Masz dziś ${tasks.length} zadań"),

                      Text("Ukończone $doneCount zadań"),

                      SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,

                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];

                            return Dismissible(
                              key: ValueKey(task.title),

                              direction: DismissDirection.endToStart,

                              onDismissed: (direction) {
                                setState(() {
                                  filteredTasks.remove(task);
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Usunięto: ${task.title}"),
                                  ),
                                );
                              },

                              child: TaskCard(
                                title: task.title,

                                subtitle:
                                    "termin: ${task.deadline} | priorytet: ${task.priority}",

                                done: task.done,

                                onChanged: (value) {
                                  setState(() {
                                    task.done = value!;
                                  });
                                },

                                onTap: () async {
                                  final Task? updatedTask =
                                      await Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditTaskScreen(task: task),
                                        ),
                                      );

                                  if (updatedTask != null) {
                                    setState(() {
                                      filteredTasks[index] = updatedTask;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );

          if (newTask != null) {
            setState(() {
              await TaskLocalDatabase.addTask(
                newTask;
              );

              setState(() {
                tasksFuture = loadTask();
              });
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.done,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,

        leading: Checkbox(value: done, onChanged: onChanged),

        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: TextStyle(color: done ? Colors.grey : Colors.black),
        ),

        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nowe zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tytul
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // termin
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // priorytet
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // przycisk
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                );

                Navigator.pop(context, newTask);
              },
              child: Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task task;

  EditTaskScreen({super.key, required this.task});

  late final TextEditingController titleController = TextEditingController(
    text: task.title,
  );

  late final TextEditingController deadlineController = TextEditingController(
    text: task.deadline,
  );

  late final TextEditingController priorityController = TextEditingController(
    text: task.priority,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edytuj zadanie")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // tytul
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // termin
            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            // priorytet
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: task.done, // zachowany status zadania
                );

                Navigator.pop(context, updatedTask);
              },
              child: Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}
