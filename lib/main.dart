import 'package:flutter/material.dart';
import 'package:opendosm_pricecatcher/modules/screens.dart';

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PriceCatcherScreen(title: "PriceCatcher");
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
