import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_parse/login.dart'; // Import the LoginPage file
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'creds.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  final currentUser = await ParseUser.currentUser();
  runApp(MaterialApp(
    home: currentUser == null ? const LoginPage() : const LoginPage(),
    theme: ThemeData(
      primaryColor: Colors.indigo,
      hintColor: Colors.deepOrange,
      scaffoldBackgroundColor: Colors.grey[200],
      // hintColor: Colors.teal,
      fontFamily: 'Montserrat',
    ),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todoController = TextEditingController();

  void addToDo() async {
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Empty title"),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null) return;
    await saveTodo(todoController.text, selectedDate);
    setState(() {
      todoController.clear();
    });
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QuickTask Pro",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            // align: left,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          TextButton(
            onPressed: logout,
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: todoController,
                      decoration: InputDecoration(
                        labelText: "New Task",
                        labelStyle: const TextStyle(color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: addToDo,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ParseObject>>(
              future: getTodo(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Error..."),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No Data..."),
                      );
                    } else {
                      // Sort the list based on targetDate and completion status
                      snapshot.data!.sort((a, b) {
                        final DateTime? dateA = a.get<DateTime>('targetDate');
                        final DateTime? dateB = b.get<DateTime>('targetDate');
                        final bool doneA = a.get<bool>('done') ?? false;
                        final bool doneB = b.get<bool>('done') ?? false;

                        // Incomplete tasks should come before completed tasks
                        if (!doneA && doneB) {
                          return -1;
                        } else if (doneA && !doneB) {
                          return 1;
                        }

                        // Sort by targetDate if both tasks have the same completion status
                        if (dateA == null && dateB == null) {
                          return 0;
                        } else if (dateA == null) {
                          return 1;
                        } else if (dateB == null) {
                          return -1;
                        }
                        return dateA.compareTo(dateB);
                      });
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final varTodo = snapshot.data![index];
                          final varTitle = varTodo.get<String>('title')!;
                          final varDone = varTodo.get<bool>('done')!;
                          final varTargetDate = varTodo.get<DateTime>('targetDate');
                          return ListTile(
                            title: Text(varTitle),
                            subtitle: varTargetDate != null
                                ? Text('Due: ${DateFormat('dd-MMM-yyyy').format(varTargetDate)}')
                                : null,
                            leading: CircleAvatar(
                              backgroundColor:
                              varDone ? Colors.green : Colors.blue,
                              foregroundColor: Colors.white,
                              child: Icon(
                                varDone ? Icons.check : Icons.error,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: varDone,
                                  onChanged: (value) async {
                                    await updateTodo(
                                        varTodo.objectId!, value!);
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await deleteTodo(varTodo.objectId!);
                                    setState(() {});
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveTodo(String title, DateTime targetDate) async {
    final todoDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final currentUser = await ParseUser.currentUser();
    final userId = currentUser?.objectId;
    if (userId != null) {
      final todo = ParseObject('Todo')
        ..set('title', title)
        ..set('done', false)
        ..set('targetDate', todoDate)
        ..set('userId', userId);
      await todo.save();
    }
  }

  Future<List<ParseObject>> getTodo() async {
    final currentUser = await ParseUser.currentUser();
    final userId = currentUser?.objectId;
    if (userId != null) {
      QueryBuilder<ParseObject> queryTodo =
      QueryBuilder<ParseObject>(ParseObject('Todo'))
        ..whereEqualTo('userId', userId);
      final ParseResponse apiResponse = await queryTodo.query();

      if (apiResponse.success && apiResponse.results != null) {
        return apiResponse.results as List<ParseObject>;
      }
    }
    return [];
  }

  Future<void> updateTodo(String id, bool done) async {
    var todo = ParseObject('Todo')
      ..objectId = id
      ..set('done', done);
    await todo.save();
  }

  Future<void> deleteTodo(String id) async {
    var todo = ParseObject('Todo')..objectId = id;
    await todo.delete();
  }
}
