// cos popsulem w tym pliku - w nastepnym commicie postaramm się naprawić wszystko

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {


  List<Task> tasks = [
    Task(title: "Projekt Flutter", deadline: "jutro"),
    Task(title: "Ćwiczenia z matematyki", deadline: "dzisiaj"),
    Task(title: "Przeczytać o widgetach", deadline: "w tym tygodniu"),
    Task(title: "Zrobić trening", deadline: "dzisiaj"),
    Task(title: "Zjeść obiag", deadline: "jutro"),
    Task(title: "Nauczyć się na egzamin", deadline: "w następnym tygodniu"),
    Task(title: "Zrobić pranie", deadline: "jutro")
  ];



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Column(

        children: [
            ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(child: Text("$task"));
              }
            )
        ],

      )
    );
  }
}




class Task {
  final String title;
  final String deadline;
  Task({required this.title, required this.deadline});
}



class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}






class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: .center,
          children: [
            const Text('KrakFlow'), Text('Organizacja studiów'),
            Text('Dzisiejsze zadania'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
