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

  void _showDisclaimerNotice() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext _) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Text(
                  "1. Ini BUKAN APLIKASI RASMI oleh Department of Statistics Malaysia (DOSM)",
                  style: TextStyle(fontWeight: FontWeight.bold)
                ),
                SizedBox(height: 5),
                Text("2. Data harga, premis dan barangan diperoleh dari OpenDOSM dan diarkibkan ke dalam format sqlite(dikemaskini setiap hari)"),
                SizedBox(height: 5),
                Text("3. Aplikasi ini mungkin memaparkan data-data yang lama atau yang kurang tepat"),
                SizedBox(height: 5),
                Text("4. Pembangun aplikasi tidak bertanggungjawab sekiranya data yang dipaparkan di dalam aplikasi ini kurang tepat"),
                SizedBox(height: 5),
                Text("5. Sumber terbuka repositori sqlite:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("https://github.com/arma7x/opendosm-parquet-to-sqlite"),
                SizedBox(height: 5),
                Text("6. Sumber terbuka repositori aplikasi:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("https://github.com/arma7x/opendosm"),
                SizedBox(height: 5),
                Text("7. Sumber terbuka repositori OpenDOSM:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("https://github.com/dosm-malaysia/aksara-data"),
                SizedBox(height: 5),
                Text("License:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("This data is made open under the Creative Commons Attribution 4.0 International License (CC BY 4.0). A human-readable copy of the license is available here(https://creativecommons.org/licenses/by/4.0/)"),
              ]
            )
          )
        );
      },
    );
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
                  color: Colors.blue,
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
                  color: Colors.blue,
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
                      return PremiseList(title: "Premis", dBInstance: dBInstance);
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
                  Icons.warning,
                  size: 28.0,
                  color: Colors.blue,
                ),
                trailing: const Icon(Icons.arrow_forward_ios ),
                title: Text(
                  "Notis Penafian",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: _showDisclaimerNotice
              )
            )
          ),
        ],
      ),
    );
  }
}
