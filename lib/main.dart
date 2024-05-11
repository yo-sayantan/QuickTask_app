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

  runApp(MaterialApp(
    home: const LoginPage(),
    theme: ThemeData(
      primaryColor: Colors.indigo, // Updated primary color
      hintColor: Colors.deepOrange, // Updated accent color
      scaffoldBackgroundColor: Colors.grey[200], // Updated scaffold background color
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
    // Show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate == null) return; // User canceled date selection
    // Save todo with target date
    await saveTodo(todoController.text, selectedDate);
    setState(() {
      todoController.clear();
    });
  }

  void logout() {
    // Redirect to the login page upon logout
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
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: <Widget>[
          TextButton(
            onPressed: logout,
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white, // Change the text color
                fontSize: 16, // Change the font size
                fontWeight: FontWeight.bold, // Apply bold font weight
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white.withOpacity(0.8), // Set the color and opacity
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
                                ? Text('Due: ${DateFormat('dd-MMM-yyyy').format(varTargetDate)}') // Format date as MM/dd/yyyy
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
    // Extract date part from the DateTime object
    final todoDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final todo = ParseObject('Todo')
      ..set('title', title)
      ..set('done', false)
      ..set('targetDate', todoDate); // Save only the date part
    await todo.save();
  }

  Future<List<ParseObject>> getTodo() async {
    QueryBuilder<ParseObject> queryTodo =
    QueryBuilder<ParseObject>(ParseObject('Todo'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
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
