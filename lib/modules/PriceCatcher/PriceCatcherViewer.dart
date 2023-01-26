import 'package:flutter/material.dart';
import './api.dart';

class PriceCatcherViewer extends StatefulWidget {
  const PriceCatcherViewer({
    super.key,
    required this.title,
    required this.href,
    required this.itemLookup,
    required this.itemLookupGroupIndex,
    required this.itemLookupCategoryIndex,
    required this.premiseLookup,
    required this.premiseLookupIndex,
  });

  final String title;
  final String href;

  final Map<int, dynamic> itemLookup;
  final Map<String, List<int>> itemLookupGroupIndex;
  final Map<String, List<int>> itemLookupCategoryIndex;

  final Map<int, dynamic> premiseLookup; // use on item.premise_code
  final Map<String, Map<String, Map<String, List<int>>>> premiseLookupIndex;

  @override
  State<PriceCatcherViewer> createState() => _PriceCatcherViewerState();
}

class _PriceCatcherViewerState extends State<PriceCatcherViewer> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];

  String itemLookupGroupIndex = "";
  String itemLookupCategoryIndex = "";

  String premiseLookupState = "";
  String premiseLookupDistrict = "";
  String premiseLookupPremiseType = "";

  _fetchData() async {
    try {
      List<Map<String, dynamic>> _products = [];
      var tempProducts = await Api.ExtractData(widget.href);
      tempProducts["table"]!["data"]!.forEach((_product) {
        final Map<String, dynamic> product = Map.from(_product);
        _products.add(product);
      });
      setState(() {
        products = _products;
        filteredProducts = _products;
      });
    } catch (err) {
      print(err);
    }
  }

  _filter() {
    scaffoldKey.currentState!.closeEndDrawer();
    bool filterByItemCode = false;
    List<int> filterItemCodeList = [];
    if (itemLookupGroupIndex != "" && itemLookupCategoryIndex == "") {
      filterByItemCode = true;
      filterItemCodeList = widget.itemLookupGroupIndex[itemLookupGroupIndex]!;
    } else if (itemLookupGroupIndex == "" && itemLookupCategoryIndex != "") {
      filterByItemCode = true;
      filterItemCodeList = widget.itemLookupCategoryIndex[itemLookupCategoryIndex]!;
    } else if (itemLookupGroupIndex != "" && itemLookupCategoryIndex != "") {
      filterByItemCode = true;
      filterItemCodeList = widget.itemLookupGroupIndex[itemLookupGroupIndex]!;
      filterItemCodeList = filterItemCodeList.where((code) {
        return widget.itemLookupCategoryIndex[itemLookupCategoryIndex]!.indexOf(code) > -1;
      }).toList();
    }
    if (filterByItemCode == true && filterItemCodeList.length == 0) {
      var t = [
        if (itemLookupGroupIndex != "") itemLookupGroupIndex,
        if (itemLookupCategoryIndex != "") itemLookupCategoryIndex
      ];
      final snackBar = SnackBar(content: Text("Tiada barang berkaitan dengan ${t.join(' atau ')}"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      List<Map<String, dynamic>> _filteredProducts = [];
      bool filterByPremiseCode = true;
      List<int> filterPremiseCodeList = [];
      if (premiseLookupState != "" && premiseLookupDistrict != "" && premiseLookupPremiseType != "") {
        filterPremiseCodeList = widget.premiseLookupIndex[premiseLookupState]![premiseLookupDistrict]![premiseLookupPremiseType]!;
      } else if (premiseLookupState != "" && premiseLookupDistrict != "") {
        widget.premiseLookupIndex[premiseLookupState]![premiseLookupDistrict]!.forEach((k, list) {
          filterPremiseCodeList = [...filterPremiseCodeList, ...list];
        });
      } else if (premiseLookupState != "") {
        widget.premiseLookupIndex[premiseLookupState]!.forEach((_, premiseTypes) {
          if (premiseTypes != null) {
            premiseTypes!.forEach((_, list) {
              filterPremiseCodeList = [...filterPremiseCodeList, ...list];
            });
          }
        });
      } else {
        filterByPremiseCode = false;
      }
      if (filterByItemCode == true && filterByPremiseCode == true) {
        _filteredProducts = products.where((product) {
          final item_code = product["item_code"]!.toInt();
          final premise_code = product["premise_code"]!.toInt();
          return filterItemCodeList.indexOf(item_code) > -1 && filterPremiseCodeList.indexOf(premise_code) > -1;
        }).toList();
      } else if (filterByItemCode == true) {
        _filteredProducts = products.where((product) {
          final item_code = product["item_code"]!.toInt();
          return filterItemCodeList.indexOf(item_code) > -1;
        }).toList();
      } else if (filterByPremiseCode == true) {
        _filteredProducts = products.where((product) {
          final premise_code = product["premise_code"]!.toInt();
          return filterPremiseCodeList.indexOf(premise_code) > -1;
        }).toList();
      } else {
        _filteredProducts = [...products];
      }
      if (_filteredProducts.length == 0) {
        final snackBar = SnackBar(content: Text("Tiada barang sepadan dengan carian anda"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          filteredProducts = _filteredProducts;
        });
      }
    }
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
                  value: itemLookupGroupIndex,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Kumpulan"),
                    ),
                    ...widget.itemLookupGroupIndex.keys.map((String group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      itemLookupGroupIndex = newValue!;
                    });
                  },
                ),
              ),
              ListTile(
                title: DropdownButton(
                  isExpanded: true,
                  value: itemLookupCategoryIndex,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: "",
                      child: Text("Semua Kategori"),
                    ),
                    ...widget.itemLookupCategoryIndex.keys.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList()
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      itemLookupCategoryIndex = newValue!;
                    });
                  },
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
                    ...widget.premiseLookupIndex.keys.map((String state) {
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
                    ...widget.premiseLookupIndex[premiseLookupState]!.keys.map((String district) {
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
                    ...widget.premiseLookupIndex[premiseLookupState]![premiseLookupDistrict]!.keys.map((String type) {
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
                onPressed: _filter,
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
                  itemLookupGroupIndex = "";
                  itemLookupCategoryIndex = "";
                  premiseLookupState = "";
                  premiseLookupDistrict = "";
                  premiseLookupPremiseType = "";
                  _filter();
                },
              )
            ],
          ),
        )
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
                  widget.href,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onTap: () {}
              )
            )
          ),
        ],
      ),
    );
  }
}