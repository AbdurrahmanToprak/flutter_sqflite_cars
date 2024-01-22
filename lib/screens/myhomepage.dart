import 'package:flutter/material.dart';
import 'package:flutter_sqflite_cars/utils/dbhelper.dart';
import 'package:flutter_sqflite_cars/models/car.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Car> cars = [];
  List<Car> carsByName = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController milesUpdateController = TextEditingController();
  TextEditingController idDeleteController = TextEditingController();

  void _showMessageInScaffold(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text("Car App - SQFLite "),
            bottom: const TabBar(tabs: [
              Tab(
                text: "Insert",
              ),
              Tab(
                text: "View",
              ),
              Tab(
                text: "Query",
              ),
              Tab(
                text: "Update",
              ),
              Tab(
                text: "Delete",
              )
            ]),
          ),
          body: TabBarView(
            children: [
              //INSERT
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: milesController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car Miles',
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          String name = nameController.text;
                          int miles = int.parse(milesController.text);
                          _insert(name, miles);
                        },
                        child: const Text('Insert Car Details'))
                  ],
                ),
              ),
              //VİEW
              Container(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cars.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == cars.length) {
                        return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _queryAll();
                              });
                            },
                            child: const Text('Refresh'));
                      }
                      return Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            "[${cars[index].id}] ${cars[index].name} - ${cars[index].miles} miles",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    }),
              ),
              //QUERY
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: 100,
                      child: TextField(
                        controller: queryController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car Name'),
                        onChanged: (text) {
                          if (text.length >= 2) {
                            setState(() {
                              _query(text);
                            });
                          } else {
                            setState(() {
                              carsByName.clear();
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 300,
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: carsByName.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 50,
                                margin: const EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    "[${carsByName[index].id}] ${carsByName[index].name} - ${carsByName[index].miles} miles",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            }),
                      ),
                    )
                  ],
                ),
              ),

              //UPDATE
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: idUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car ID',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: nameUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car Name',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: milesUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car Miles',
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            int id = int.parse(idUpdateController.text);
                            String name = nameUpdateController.text;
                            int miles = int.parse(milesUpdateController.text);
                            _update(id, name, miles);
                          },
                          child: const Text('Update Car Details'))
                    ],
                  ),
                ),
              ),
              //DELETE
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          controller: idDeleteController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car ID',
                          ),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            int id = int.parse(idDeleteController.text);

                            _delete(id);
                          },
                          child: const Text('Delete Car Details'))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _insert(String name, int miles) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles,
    };
    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold('Inserted row id : $id ');
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows(nameController);
    cars.clear();
    allRows.forEach((row) => cars.add(Car.fromMap(row)));
    _showMessageInScaffold('Query done.');
    setState(() {});
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    carsByName.clear();
    allRows.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  void _update(int id, String name, int miles) async {
    Car car = Car(id, name, miles);
    final rowAffected = await dbHelper.update(car);
    _showMessageInScaffold('Updated $rowAffected row(s)');
  }

  void _delete(int id) async {
    final rowDeleted = await dbHelper.delete(id);
    _showMessageInScaffold('Deleted $rowDeleted row(s) : rows $id');
  }
}
