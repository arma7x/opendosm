import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import './api.dart';
import 'package:sqlite3/common.dart';

class PriceCatcherScreen extends StatefulWidget {
  const PriceCatcherScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<PriceCatcherScreen> createState() => _PriceCatcherScreenState();
}

class _PriceCatcherScreenState extends State<PriceCatcherScreen> {

  Api api = new Api();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> items = [];
  List<String> itemGroups = [];
  List<String> itemCategories = [];
  Map<String, Map<String, List<String>>> states = {};

  String itemLookupGroup = "";
  String itemLookupCategory = "";

  String premiseLookupState = "";
  String premiseLookupDistrict = "";
  String premiseLookupPremiseType = "";

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

  _fetchData() async {
    try {
      _loadingDialog(true);
      dBInstance = await Api.GetDatabaseWeb();
      List<String> tempItemGroups = [];
      var _itemGroups = dBInstance!.select('''
        SELECT item_group FROM items
        WHERE NOT item_group='UNKNOWN'
        GROUP BY item_group;
        '''
      );
      for (var x in _itemGroups.rows) {
        tempItemGroups.add(x[0]!.toString());
      }
      List<String> tempItemCategories = [];
      var _itemCategories = dBInstance!.select('''
        SELECT item_category FROM items
        WHERE NOT item_category='UNKNOWN'
        GROUP BY item_category
        '''
      );
      for (var x in _itemCategories.rows) {
        tempItemCategories.add(x[0]!.toString());
      }
      Map<String, Map<String, List<String>>> tempStates = {};
      var _states = dBInstance!.select('''
        SELECT state, district, premise_type FROM premises
        WHERE NOT state='UNKNOWN'
        GROUP BY state, district, premise_type
        ORDER BY state ASC, district ASC, premise_type ASC
        '''
      );
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
        itemGroups = tempItemGroups;
        itemCategories = tempItemCategories;
        states = tempStates;
      });
      _loadingDialog(false);
      _filterItems();
    } catch (err) {
      _loadingDialog(false);
    }
  }

  _filterItems() {
    if (dBInstance != null) {
      var select_stmt = "SELECT * FROM items";
      var where_stmt = ["WHERE NOT item_code=-1"];
      if (itemLookupGroup != "") {
        where_stmt.add(" item_group='${itemLookupGroup}'");
      }
      if (itemLookupCategory != "") {
        where_stmt.add(" item_category='${itemLookupCategory}'");
      }
      var _items = dBInstance!.select([select_stmt, where_stmt.join(" AND")].join(' '));
      setState(() {
        items = _items.cast<Map<String, dynamic>>();
      });
    }
    scaffoldKey.currentState!.closeEndDrawer();
  }

  _getPriceList(int item_code) {
    var select_stmt = "SELECT prices.date as last_update, prices.price, premises.* FROM items";
    var join_stmt = ["LEFT JOIN prices ON prices.item_code = items.item_code", "LEFT JOIN premises ON premises.premise_code = prices.premise_code"];
    var where_stmt = ["WHERE NOT items.item='UNKNOWN'", " prices.price IS NOT NULL", " premises.premise_code IS NOT NULL", " items.item_code=${item_code}"];
    if (premiseLookupState != "") {
      where_stmt.add(" premises.state='${premiseLookupState}'");
    }
    if (premiseLookupDistrict != "") {
      where_stmt.add(" premises.district='${premiseLookupDistrict}'");
    }
    if (premiseLookupPremiseType != "") {
      where_stmt.add(" premises.premise_type='${premiseLookupPremiseType}'");
    }
    var order_stmt = "ORDER BY prices.price ASC";
    var _priceList = dBInstance!.select([select_stmt, join_stmt.join(" "), where_stmt.join(" AND"), order_stmt].join(' '));
    print(_priceList.cast<Map<String, dynamic>>().length);
  }

  _showLocationFilter(BuildContext ctx, int item_code) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(5.0),
              child: Wrap(
                children: <Widget>[
                  Center(
                    child: Text(
                      "Pilih Lokasi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
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
                    minWidth: MediaQuery.of(context).size.width,
                    height: 45,
                    color: Theme.of(context).colorScheme.primary,
                    child: new Text(
                      "CARIAN",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white
                      )
                    ),
                    onPressed: () {
                      _getPriceList(item_code);
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    minWidth: MediaQuery.of(context).size.width,
                    height: 45,
                    color: Colors.red,
                    child: new Text(
                      "RALAT",
                      style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.white
                      )
                    ),
                    onPressed: () {
                      setState(() {
                        premiseLookupState = "";
                        premiseLookupDistrict = "";
                        premiseLookupPremiseType = "";
                      });
                    },
                  )
                ],
              ),
            );
        });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
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
                  value: itemLookupGroup,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Kumpulan"),
                    ),
                    ...itemGroups.map((String group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      itemLookupGroup = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: DropdownButton(
                  isExpanded: true,
                  value: itemLookupCategory,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Kategori"),
                    ),
                    ...itemCategories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      itemLookupCategory = newValue!;
                    });
                  },
                ),
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width - 70,
                height: 45,
                color: Theme.of(context).colorScheme.primary,
                child: new Text(
                  "TAPIS CARIAN",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white
                  )
                ),
                onPressed: () {
                  if (items.length > 0){
                    _scrollController.jumpTo(0);
                  }
                  _filterItems();
                },
              ),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width - 70,
                height: 45,
                color: Colors.red,
                child: new Text(
                  "RALAT CARIAN",
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white
                  )
                ),
                onPressed: () {
                  if (items.length > 0){
                    _scrollController.jumpTo(0);
                  }
                  itemLookupGroup = "";
                  itemLookupCategory = "";
                  _filterItems();
                },
              )
            ],
          ),
        )
      ),
      body: items.length > 0 ? ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) {
          return Divider(
            thickness: 1.0,
            color: Colors.grey,
          );
        },
        itemCount: items.length,
        itemBuilder: (BuildContext _, int index) {
          return ListTile(
            leading: const Icon(Icons.list),
            trailing: Text(
              items[index]["unit"]!.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
            ),
            title: Text(
              items[index]["item"]!.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onTap: () {
              _showLocationFilter(context, items[index]["item_code"]);
            }
          );
        }
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Data not available",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
