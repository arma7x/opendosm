import 'package:flutter/material.dart';
import 'package:sqlite3/common.dart' as common;

class PriceList extends StatefulWidget {
  const PriceList({
    super.key,
    required this.title,
    required this.premise_code,
    this.dBInstance,
  });

  final String title;
  final int premise_code;

  final common.CommonDatabase? dBInstance;

  @override
  State<PriceList> createState() => _PriceListState();
}

class _PriceListState extends State<PriceList> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> items = [];
  List<String> itemGroups = [];
  List<String> itemCategories = [];

  String itemLookupGroup = "";
  String itemLookupCategory = "";

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
    _loadingDialog(true);
    await Future.delayed(Duration(milliseconds: 200));
    try {
      List<String> tempItemGroups = [];
      var _itemGroups = widget.dBInstance!.select("SELECT item_group FROM items WHERE NOT item_code=-1 GROUP BY item_group;");
      for (var x in _itemGroups.rows) {
        tempItemGroups.add(x[0]!.toString());
      }
      List<String> tempItemCategories = [];
      var _itemCategories = widget.dBInstance!.select("SELECT item_category FROM items WHERE NOT item_code=-1 GROUP BY item_category;");
      for (var x in _itemCategories.rows) {
        tempItemCategories.add(x[0]!.toString());
      }
      setState(() {
        itemGroups = tempItemGroups;
        itemCategories = tempItemCategories;
      });
      _filterItems();
      _loadingDialog(false);
    } catch (err) {
      print(err);
      _loadingDialog(false);
    }
  }

  _filterItems() {
    if (widget.dBInstance != null) {
      var select_stmt = "SELECT items.*, prices.date as last_update, prices.price FROM items";
      var join_stmt = ["LEFT JOIN prices ON prices.item_code = items.item_code", "LEFT JOIN premises ON premises.premise_code = prices.premise_code"];
      var where_stmt = ["WHERE NOT items.item_code=-1", " prices.price IS NOT NULL", " premises.premise_code=${widget.premise_code}"];
      if (itemLookupGroup != "") {
        where_stmt.add(" items.item_group='${itemLookupGroup}'");
      }
      if (itemLookupCategory != "") {
        where_stmt.add(" items.item_category='${itemLookupCategory}'");
      }
      var order_stmt = "ORDER BY prices.price ASC";
      var _items = widget.dBInstance!.select([select_stmt, join_stmt.join(' '), where_stmt.join(" AND"), order_stmt].join(' '));
      setState(() {
        items = _items.cast<Map<String, dynamic>>();
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
                height: 40,
                color: Theme.of(context).colorScheme.primary,
                child: new Text(
                  "TAPIS BARANGAN",
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
      body: items.length > 0 ? ListView.builder(
        controller: _scrollController,
        itemCount: items.length,
        itemBuilder: (BuildContext _, int index) {
          return Card(
            color: Colors.grey[200],
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    items[index]["item"]!.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 5),
                  Text("Unit: " + items[index]["unit"]!.toString()),
                  Text("Kumpulan: " + items[index]["item_group"]!.toString()),
                  Text("Kategori: " + items[index]["item_category"]!.toString()),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "RM" + double.parse(items[index]["price"]!.toString()).toStringAsFixed(2),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Text(items[index]["last_update"]!.toString()),
                    ]
                  )
                ],
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
