import 'package:flutter/material.dart';
import 'package:sqlite3/common.dart';
import 'package:opendosm_pricecatcher/widgets/widgets.dart' show PremiseWidget;
import './PriceList.dart';

class PremiseList extends StatefulWidget {
  const PremiseList({
    super.key,
    required this.title,
    this.dBInstance
  });

  final String title;

  final CommonDatabase? dBInstance;

  @override
  State<PremiseList> createState() => _PremiseListState();
}

class _PremiseListState extends State<PremiseList> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> premises = [];
  Map<String, Map<String, List<String>>> states = {};

  String premiseLookupState = "";
  String premiseLookupDistrict = "";
  String premiseLookupPremiseType = "";

  _initilize() async {
    try {
      Map<String, Map<String, List<String>>> tempStates = {};
      var _states = widget.dBInstance!.select("SELECT state, district, premise_type FROM premises WHERE NOT premise_code=-1 GROUP BY state, district, premise_type ORDER BY state ASC, district ASC, premise_type ASC;");
      for (var x in _states.rows) {
        final state = x[0]!.toString().trim();
        final district = x[1]!.toString().trim();
        final type = x[2]!.toString().trim();
        if (tempStates.containsKey(state) == false) {
          tempStates[state] = {};
        }
        if (tempStates[state]!.containsKey(district) == false) {
          tempStates[state]![district] = [];
        }
        tempStates[state]![district]!.add(type);
      }
      setState(() {
        states = tempStates;
      });
      _filterPremises();
    } catch (err) {
      print(err);
    }
  }

  _filterPremises() {
    if (widget.dBInstance != null) {
      var select_stmt = "SELECT * from premises";
      var where_stmt = ["WHERE NOT premise_code=-1"];
      if (premiseLookupState != "") {
        where_stmt.add(" premises.state='${premiseLookupState}'");
      }
      if (premiseLookupDistrict != "") {
        where_stmt.add(" premises.district='${premiseLookupDistrict}'");
      }
      if (premiseLookupPremiseType != "") {
        where_stmt.add(" premises.premise_type='${premiseLookupPremiseType}'");
      }
      var order_stmt = "ORDER BY state ASC, district ASC, premise_type ASC";
      var _premises = widget.dBInstance!.select([select_stmt, where_stmt.join(" AND"), order_stmt].join(' '));
      setState(() {
        premises = _premises.cast<Map<String, dynamic>>();
      });
    }
    scaffoldKey.currentState!.closeEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initilize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            tooltip: "Filter",
            onPressed: () {
              scaffoldKey.currentState!.openEndDrawer();
            },
          )
        ]
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.90,
        child: Drawer(
          child: Column(
            children: [
              SizedBox(height: 10),
              ListTile(
                title: DropdownButton(
                  isExpanded: true,
                  value: premiseLookupState,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Negeri"),
                    ),
                    ...states.keys.map((String state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(state),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      premiseLookupState = newValue!;
                    });
                    premiseLookupDistrict = "";
                    premiseLookupPremiseType = "";
                  },
                ),
              ),
              if (premiseLookupState != "") ListTile(
                title: DropdownButton(
                  isExpanded: true,
                  value: premiseLookupDistrict,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Daerah"),
                    ),
                    ...states[premiseLookupState]!.keys.map((String district) {
                      return DropdownMenuItem(
                        value: district,
                        child: Text(district),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      premiseLookupDistrict = newValue!;
                    });
                    premiseLookupPremiseType = "";
                  },
                ),
              ),
              if (premiseLookupDistrict != "") ListTile(
                title: DropdownButton(
                  isExpanded: true,
                  value: premiseLookupPremiseType,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Jenis Premis"),
                    ),
                    ...states[premiseLookupState]![premiseLookupDistrict]!.map((String type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      premiseLookupPremiseType = newValue!;
                    });
                  },
                ),
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width - 70,
                height: 40,
                color: Theme.of(context).colorScheme.primary,
                child: new Text(
                  "TAPIS LOKASI",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white
                  )
                ),
                onPressed: () {
                  if (premises.length > 0){
                    _scrollController.jumpTo(0);
                  }
                  _filterPremises();
                },
              ),
              SizedBox(height: 8),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width - 70,
                height: 40,
                color: Colors.red,
                child: new Text(
                  "RALAT TAPISAN",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white
                  )
                ),
                onPressed: () {
                  if (premises.length > 0){
                    _scrollController.jumpTo(0);
                  }
                  premiseLookupState = "";
                  premiseLookupDistrict = "";
                  premiseLookupPremiseType = "";
                  _filterPremises();
                },
              )
            ],
          ),
        )
      ),
      body: premises.length > 0 ? ListView.builder(
        controller: _scrollController,
        itemCount: premises.length,
        itemBuilder: (BuildContext _, int index) {
          return Card(
            color: Colors.grey[200],
            child: Container(
              child: ListTile(
                title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    SizedBox(height: 10),
                    PremiseWidget(
                      premise: premises[index]["premise"]!.toString(),
                      premise_type: premises[index]["premise_type"]!.toString(),
                      address: premises[index]["address"]!.toString(),
                      district: premises[index]["district"]!.toString(),
                      state: premises[index]["state"]!.toString(),
                    ),
                    SizedBox(height: 10),
                  ]
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PriceList(
                        title: premises[index]["premise"]!.toString(),
                        premise_code: premises[index]["premise_code"]!,
                        dBInstance: widget.dBInstance
                      );
                    }),
                  );
                }
              )
            )
          );
        }
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Data tidak tersedia!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
