import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

enum Kit {
  foil,
  sabre,
  epee,
  bodywire,
  headwire,
  epeeMask,
  foilMask,
  sabreMask,
  steamGlove,
  sabreGlove,
  jacket,
  breeches,
  plastron,
  foilLame,
  sabreLame
}

Map equipMap = Map();
Map charges = Map();
List<String> names = [];

String kitToString(Kit kit) {
  String res;
  switch (kit) {
    case (Kit.foil):
      {
        res = "Foil";
        break;
      }
    case (Kit.sabre):
      {
        res = "Sabre";
        break;
      }
    case (Kit.epee):
      {
        res = "Épée";
        break;
      }
    case (Kit.bodywire):
      {
        res = "Bodywire";
        break;
      }
    case (Kit.headwire):
      {
        res = "Headwire";
        break;
      }
    case (Kit.epeeMask):
      {
        res = "Épée mask";
        break;
      }
    case (Kit.foilMask):
      {
        res = "Foil mask";
        break;
      }
    case (Kit.sabreMask):
      {
        res = "Sabre mask";
        break;
      }
    case (Kit.steamGlove):
      {
        res = "Steam glove";
        break;
      }
    case (Kit.sabreGlove):
      {
        res = "Sabre glove";
        break;
      }
    case (Kit.jacket):
      {
        res = "Jacket";
        break;
      }
    case (Kit.breeches):
      {
        res = "Breeches";
        break;
      }
    case (Kit.plastron):
      {
        res = "Plastron";
        break;
      }
    case (Kit.foilLame):
      {
        res = "Foil lamé";
        break;
      }
    case (Kit.sabreLame):
      {
        res = "Sabre lamé";
        break;
      }
  }
  return res;
}

Future<Map> equipReq() async {
  final response = await http.post(
      Uri.parse(
          'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/tables/equipment_types/query'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
      });

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to connect to database");
  }
}

Future<Map> chargesReq() async {
  final response = await http.post(
    Uri.parse(
        'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/sql'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
    },
    body: jsonEncode(<String, String>{
      'statement':
          'SELECT "GUID",SUM((date_part(\'day\', "rentals"."xata.updatedAt" - "rentals"."xata.createdAt")+1)*price)  FROM "rentals" INNER JOIN equipment_types ON rentals.equipment_name = equipment_types.id WHERE "is_returned"=TRUE GROUP BY "GUID" LIMIT 1000;',
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to connect to database");
  }
}

Future<bool> markAsPaid(List<String> nameList) async {
  var nameListString = "";
  for (var i = 0; i < nameList.length - 1; i++) {
    nameListString += "'${nameList[i]}', ";
  }
  nameListString += "'${nameList[nameList.length - 1]}'";
  final response = await http.post(
    Uri.parse(
        'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/sql'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
    },
    body: jsonEncode({
      "statement":
          'DELETE FROM "rentals" WHERE "GUID" IN ($nameListString) AND "is_returned"=True',
    }),
  );
  if (response.statusCode != 200) {
    return false;
  } else {
    return true;
  }
}

Future<bool> markAsReturned(List<String> ids) async {
  print(ids);
  print(jsonEncode({
    "operations": [
      for (var id in ids)
        {
          "update": {
            "table": "rentals",
            "id": id,
            "fields": {"is_returned": true}
          }
        }
    ]
  }));
  var idString = "";
  for (var i = 0; i < ids.length - 1; i++) {
    idString += "'${ids[i]}', ";
  }
  idString += "'${ids[ids.length - 1]}'";
  final response = await http.post(
      Uri.parse(
          'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/transaction'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
      },
      body: jsonEncode({
        "operations": [
          for (var id in ids)
            {
              "update": {
                "table": "rentals",
                "id": id,
                "fields": {"is_returned": true}
              }
            }
        ]
      }));
  print(response.body);
  if (response.statusCode != 200) {
    return false;
  } else {
    return true;
  }
}

Future<Map> getNames() async {
  final response = await http.post(
    Uri.parse(
        'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/sql'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
    },
    body: jsonEncode({
      "statement": 'SELECT name FROM "members"',
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to connect to database");
  }
}

Future<Map> rentalsReq() async {
  final response = await http.post(
    Uri.parse(
        'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/sql'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
    },
    body: jsonEncode({
      "statement":
          'SELECT "GUID",name,rentals.id FROM "rentals" INNER JOIN equipment_types ON rentals.equipment_name = equipment_types.id WHERE is_returned = false',
    }),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to connect to database");
  }
}

Widget buttonEnabler(data, List<bool> selected, current, func,
    String buttonText, context, String field) {
  if (selected.any((element) => element)) {
    return Center(
        child: ElevatedButton(
            onPressed: () {
              List<String> nameList = [];
              for (var i = 0; i < selected.length; i++) {
                if (selected[i]) {
                  nameList.add(data[i][field]);
                }
              }
              var ret = func(nameList);
              var rettext = "";
              ret.then((val) => {
                    if (val)
                      {rettext = "Request successfully submitted"}
                    else
                      {rettext = "Request failed"},
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                                title: const Text('Notification'),
                                content: Text(rettext),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'OK');
                                    },
                                    child: const Text('OK'),
                                  ),
                                ]))
                  });
              current.setState(() {});
            },
            child: Text(buttonText)));
  } else {
    return Center(
        child: ElevatedButton(onPressed: null, child: Text(buttonText)));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUFC Rental App',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 56, 101)),
        useMaterial3: true,
      ),
      home: new LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({
    super.key,
  });
  @override
  LoadingPageState createState() => LoadingPageState();
}

class LoadingPageState extends State<LoadingPage> {
  bool _alreadySeen = false;

  @override
  Widget build(BuildContext context) {
    if (_alreadySeen) {
      return const MyHomePage(title: 'GUFC Rental App');
    } else {
      _alreadySeen = true;
      return const IntroScreen();
    }
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    super.key,
  });
  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
      reverseCurve: Curves.fastOutSlowIn,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _controller.forward();
        } else if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  Widget _buildIndicators(BuildContext context, Widget? child) {
    return Center(
      child: CircularProgressIndicator(value: _animation.value),
    );
  }

  final Future<List<Map<dynamic, dynamic>>> _requests =
      Future.wait([equipReq(), getNames()]);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: _requests,
        builder: (BuildContext context, AsyncSnapshot<List> requestList) {
          if (requestList.hasError) {
            return const Text(
              'A system error has occurred.',
              style: TextStyle(color: Colors.red, fontSize: 32),
            );
          } else if (requestList.hasData) {
            for (var kitDict in requestList.data![0]["records"]) {
              equipMap[kitDict["name"]] = kitDict["id"]!;
            }
            for (var nameDict in requestList.data![1]["records"]) {
              names.add(nameDict["name"]!);
            }
            return const MyHomePage(title: 'GUFC Rental App');
          } else {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 0, 56, 101),
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                  title: Text("GUFC Rental App"),
                ),
                body: AnimatedBuilder(
                  animation: _animation,
                  builder: _buildIndicators,
                ));
          }
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Loan {
  String? guid = '';
  List<Kit> kit = [];
}

class LoanKit extends StatefulWidget {
  const LoanKit({
    super.key,
  });
  @override
  State<LoanKit> createState() => _LoanKitState();
}

class _LoanKitState extends State<LoanKit> {
  final Loan loan = Loan();
  String nameDropdown = names[0];
  final List<Kit> dropdownValue = [Kit.values.first];
  final List<Widget> wList = [];
  var _counter = 0;
  var setup = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  Future<bool> _handleSubmitted() async {
    loan.kit = [];
    final form = _formKey.currentState!;
    form.save();

    Map<String, List<Map<String, String>>> reqMap = {"records": []};
    for (var kit in loan.kit) {
      reqMap["records"]!.add({
        "GUID": loan.guid!,
        "equipment_name": equipMap[kit.toString().split(".")[1]]
      });
    }
    try {
      var response = await http.post(
          Uri.parse(
              'https://Ins0lence-s-workspace-lhfu3f.eu-west-1.xata.sh/db/GUFC-rental:main/tables/rentals/bulk'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer xau_oNtG8sSdD91LeZHnvqZ856KK841oewji1',
          },
          body: jsonEncode(reqMap));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);

    if (!setup) {
      wList.add(DropdownButtonFormField<String>(
        icon: const Icon(Icons.arrow_downward),
        value: nameDropdown,
        decoration: const InputDecoration(
          filled: true,
          icon: Icon(Icons.person),
          labelText: "Name",
        ),
        onChanged: (String? value) {
          setState(() {
            nameDropdown = value!;
          });
        },
        items: names.map((e) {
          return DropdownMenuItem<String>(value: e, child: Text(e));
        }).toList(),
        onSaved: (value) {
          loan.guid = value;
        },
      ));
      wList.add(sizedBoxSpace);
      wList.add(
        DropdownButtonFormField<Kit>(
          value: dropdownValue.elementAt(0),
          icon: const Icon(Icons.arrow_downward),
          onChanged: (Kit? value) {
            setState(() {
              dropdownValue[0] = value!;
            });
          },
          onSaved: (value) {
            loan.kit.add(value!);
          },
          items: Kit.values.map<DropdownMenuItem<Kit>>((Kit value) {
            return DropdownMenuItem<Kit>(
              value: value,
              child: Text(kitToString(value)),
            );
          }).toList(),
        ),
      );
      wList.add(sizedBoxSpace);
      setup = true;
    }

    void _addKit() {
      setState(() {
        _counter++;
      });
      dropdownValue.add(Kit.values.first);
      wList.add(DropdownButtonFormField<Kit>(
        value: dropdownValue.elementAt(_counter),
        icon: const Icon(Icons.arrow_downward),
        onChanged: (Kit? value) {
          setState(() {
            dropdownValue[_counter] = value!;
          });
        },
        onSaved: (value) {
          loan.kit.add(value!);
        },
        items: Kit.values.map<DropdownMenuItem<Kit>>((Kit value) {
          return DropdownMenuItem<Kit>(
            value: value,
            child: Text(kitToString(value)),
          );
        }).toList(),
      ));
      wList.add(sizedBoxSpace);
    }

    void _removeKit() {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
        dropdownValue.removeLast();
        wList.removeLast();
        wList.removeLast();
      }
    }

    return Scrollbar(
        child: ListView(children: [
      Form(key: _formKey, child: Column(children: wList)),
      Row(
        children: [
          ElevatedButton(
            onPressed: () {
              var ret = _handleSubmitted();
              var rettext = "";
              ret.then((val) => {
                    if (val)
                      {rettext = "Request successfully submitted"}
                    else
                      {rettext = "Request failed"},
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                                title: const Text('Notification'),
                                content: Text(rettext),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, 'OK');
                                      if (val) {
                                        _formKey.currentState!.reset();
                                      }
                                    },
                                    child: const Text('OK'),
                                  ),
                                ]))
                  });
            },
            child: Text("Submit"),
          ),
          ElevatedButton(
            onPressed: _addKit,
            child: Text("Add"),
          ),
          ElevatedButton(
            onPressed: _removeKit,
            child: Text("Delete"),
          )
        ],
      ),
    ]));
  }
}

class KitList extends StatefulWidget {
  const KitList({
    super.key,
  });
  @override
  State<KitList> createState() => _KitListState();
}

class _KitListState extends State<KitList> with SingleTickerProviderStateMixin {
  final Future<Map> rentalsReqFuture = rentalsReq();
  late AnimationController _controller;
  late Animation<double> _animation;
  List<bool> selected = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
      reverseCurve: Curves.fastOutSlowIn,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _controller.forward();
        } else if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  Widget _buildIndicators(BuildContext context, Widget? child) {
    return Center(
      child: CircularProgressIndicator(value: _animation.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: rentalsReqFuture,
        builder: (BuildContext context, AsyncSnapshot<Map> rentalsReqLocal) {
          if (rentalsReqLocal.hasData) {
            late var data;
            if (!_loaded) {
              _loaded = true;
              if (rentalsReqLocal.data!.isNotEmpty) {
                for (var _ in rentalsReqLocal.data!["records"]) {
                  selected.add(false);
                }
              }
            }
            if (rentalsReqLocal.data!.isNotEmpty) {
              data = rentalsReqLocal.data!["records"];
            } else {
              data = [];
            }
            return Scrollbar(
                child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Name'),
                    ),
                    DataColumn(
                      label: Text('Equipment'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    selected.length,
                    (int index) => DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        // All rows will have the same selected color.
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        // Even rows will have a grey color.
                        if (index.isEven) {
                          return Colors.grey.withOpacity(0.3);
                        }
                        return null; // Use default value for other states and odd rows.
                      }),
                      cells: <DataCell>[
                        DataCell(Text(data[index]["GUID"])),
                        DataCell(Text(kitToString(Kit.values.firstWhere((e) =>
                            e.toString() == 'Kit.' + data[index]["name"]))))
                      ],
                      selected: selected[index],
                      onSelectChanged: (bool? value) {
                        setState(() {
                          selected[index] = value!;
                        });
                      },
                    ),
                  ),
                ),
                buttonEnabler(data, selected, this, markAsReturned,
                    "Mark as returned", context, "id")
              ],
            ));
          } else {
            return AnimatedBuilder(
              animation: _animation,
              builder: _buildIndicators,
            );
          }
        });
  }
}

class Charges extends StatefulWidget {
  const Charges({
    super.key,
  });
  @override
  State<Charges> createState() => _ChargesState();
}

class _ChargesState extends State<Charges> with SingleTickerProviderStateMixin {
  final Future<Map> chargesReqFuture = chargesReq();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    )..forward();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.9, curve: Curves.fastOutSlowIn),
      reverseCurve: Curves.fastOutSlowIn,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _controller.forward();
        } else if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  Widget _buildIndicators(BuildContext context, Widget? child) {
    return Center(
      child: CircularProgressIndicator(value: _animation.value),
    );
  }

  List<bool> selected = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: chargesReqFuture,
        builder: (BuildContext context, AsyncSnapshot<Map> chargesReqLocal) {
          if (chargesReqLocal.hasData) {
            late var data;
            if (!_loaded) {
              _loaded = true;
              if (chargesReqLocal.data!.isNotEmpty) {
                for (var _ in chargesReqLocal.data!["records"]) {
                  selected.add(false);
                }
              }
            }
            if (chargesReqLocal.data!.isNotEmpty) {
              data = chargesReqLocal.data!["records"];
            } else {
              data = [];
            }
            return Scrollbar(
                child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Name'),
                    ),
                    DataColumn(
                      label: Text('Amount owed'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    selected.length,
                    (int index) => DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        // All rows will have the same selected color.
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        // Even rows will have a grey color.
                        if (index.isEven) {
                          return Colors.grey.withOpacity(0.3);
                        }
                        return null; // Use default value for other states and odd rows.
                      }),
                      cells: <DataCell>[
                        DataCell(Text(data[index]["GUID"])),
                        DataCell(Text(data[index]["sum"].toString()))
                      ],
                      selected: selected[index],
                      onSelectChanged: (bool? value) {
                        setState(() {
                          selected[index] = value!;
                        });
                      },
                    ),
                  ),
                ),
                buttonEnabler(data, selected, this, markAsPaid, "Mark as paid",
                    context, "GUID")
              ],
            ));
          } else {
            return AnimatedBuilder(
              animation: _animation,
              builder: _buildIndicators,
            );
          }
        });
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LoanKit(),
    Charges(),
    KitList(),
  ];

  static const bottomNavigationBarItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: const Icon(Icons.add_comment),
      label: "Loan kit",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.calendar_today),
      label: "Charges",
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.account_circle),
      label: "Kit on Loan",
    )
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 0, 56, 101),
        backgroundColor: colorScheme.primary,
        titleTextStyle: TextStyle(color: colorScheme.onPrimary, fontSize: 20),
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: bottomNavigationBarItems,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: textTheme.bodySmall!.fontSize!,
        unselectedFontSize: textTheme.bodySmall!.fontSize!,
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(0.38),
        backgroundColor: colorScheme.primary,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
