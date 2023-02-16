import 'package:flutter/material.dart';
import 'package:opendosm_pricecatcher/modules/screens.dart';
import 'package:sqlite3/common.dart';
import './database/database.dart'
  if (dart.library.io) './database/database_android.dart'
  if (dart.library.html) './database/database_web.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenDOSM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'OpenDOSM'),
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

  CommonDatabase? dBInstance;

  void _loadingDialog(bool show) {
    if (show == true) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext _) {
          return AlertDialog(
            content: Container(child: new LinearProgressIndicator()),
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  _initilize() async {
    try {
      _loadingDialog(true);
      dBInstance = await (Database()).GetDatabase();
      _loadingDialog(false);
    } catch (err) {
      print(err);
      _loadingDialog(false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initilize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            color: Colors.grey[200],
            child: Container(
              child: ListTile(
                leading: Icon(
                  Icons.price_change,
                  size: 28.0,
                ),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(
                  "PriceCatcher",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PriceCatcherScreen(title: "PriceCatcher", dBInstance: dBInstance);
                    }),
                  );
                }
              )
            )
          ),
          Card(
            color: Colors.grey[200],
            child: Container(
              child: ListTile(
                leading: Icon(
                  Icons.store,
                  size: 28.0,
                ),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(
                  "Premis(Senarai Harga)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      // TODO Premises(title: "PriceCatcher", dBInstance: dBInstance);
                      return PriceCatcherScreen(title: "PriceCatcher", dBInstance: dBInstance);
                    }),
                  );
                }
              )
            )
          ),
        ],
      ),
    );
  }
}
