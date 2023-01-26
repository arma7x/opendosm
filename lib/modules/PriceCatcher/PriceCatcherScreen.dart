import 'package:flutter/material.dart';
import './PriceCatcherViewer.dart';
import './api.dart';

class PriceCatcherScreen extends StatefulWidget {
  const PriceCatcherScreen({super.key, required this.title});

  final String title;

  @override
  State<PriceCatcherScreen> createState() => _PriceCatcherScreenState();
}

class _PriceCatcherScreenState extends State<PriceCatcherScreen> {

  List<Map<String, String>> priceCatcher = [];

  Map<int, dynamic> itemLookup = {};
  Map<String, List<int>> itemLookupGroupIndex = {};
  Map<String, List<int>> itemLookupCategoryIndex = {};

  Map<int, dynamic> premiseLookup = {};
  Map<String, Map<String, Map<String, List<int>>>> premiseLookupIndex = {};

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
      var d = await Api.GetData();
      setState(() {
        priceCatcher = d["priceCatcher"];
      });
      Map<int, dynamic> _itemLookup = {};
      Map<String, List<int>> _itemLookupGroupIndex = {};
      Map<String, List<int>> _itemLookupCategoryIndex = {};
      var tempItemLookup = await Api.ExtractData(d["itemLookup"]!["href"]);
      tempItemLookup["table"]!["data"]!.forEach((_item) {
        final Map<String, dynamic> item = Map.from(_item);
        final int item_code = item["item_code"]!.toInt();
        if (item_code >= 1) {
          _itemLookup[item_code] = item;
          final item_group = item["item_group"]!.toString();
          if (_itemLookupGroupIndex.containsKey(item_group) == false) {
            _itemLookupGroupIndex[item_group] = <int>[];
          }
          _itemLookupGroupIndex[item_group]!.add(item_code);
          final item_category = item["item_category"]!.toString();
          if (_itemLookupCategoryIndex.containsKey(item_category) == false) {
            _itemLookupCategoryIndex[item_category] = <int>[];
          }
          _itemLookupCategoryIndex[item_category]!.add(item_code);
        }
      });

      Map<int, dynamic> _premiseLookup = {};
      Map<String, Map<String, Map<String, List<int>>>> _premiseLookupIndex = {};
      var tempPremiseLookup = await Api.ExtractData(d["premiseLookup"]!["href"]);
      tempPremiseLookup["table"]!["data"]!.forEach((_premise) {
        final Map<String, dynamic> premise = Map.from(_premise);
        final int premise_code = premise["premise_code"]!.toInt();
        if (premise_code >= 1) {
          _premiseLookup[premise_code] = premise;
          final state = premise["state"]!.toString();
          if (_premiseLookupIndex.containsKey(state) == false) {
            _premiseLookupIndex[state] = {};
          }
          final district = premise["district"]!.toString();
          if (_premiseLookupIndex[state]!.containsKey(district) == false) {
            _premiseLookupIndex[state]![district] = {};
          }
          final premise_type = premise["premise_type"]!.toString();
          if (_premiseLookupIndex[state]![district]!.containsKey(premise_type) == false) {
            _premiseLookupIndex[state]![district]![premise_type] = <int>[];
          }
          _premiseLookupIndex[state]![district]![premise_type]!.add(premise_code);
        }
      });

      setState(() {
        itemLookup = _itemLookup;
        itemLookupGroupIndex = _itemLookupGroupIndex;
        itemLookupCategoryIndex = _itemLookupCategoryIndex;
        premiseLookup = _premiseLookup;
        premiseLookupIndex = _premiseLookupIndex;
      });

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
      _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: priceCatcher.length == 0 ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Data not available",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ) : ListView.builder(
        itemCount: priceCatcher.length,
        itemBuilder: (BuildContext _, int index) {
          return Card(
            color: Colors.grey[200],
            child: Container(
              child: ListTile(
                trailing: const Icon(Icons.arrow_forward_ios),
                title: Text(priceCatcher[index]["name"]!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PriceCatcherViewer(
                        title: priceCatcher[index]["name"]!,
                        href: priceCatcher[index]["href"]!,
                        itemLookup: itemLookup,
                        itemLookupGroupIndex: itemLookupGroupIndex,
                        itemLookupCategoryIndex: itemLookupCategoryIndex,
                        premiseLookup: premiseLookup,
                        premiseLookupIndex: premiseLookupIndex,
                      );
                    }),
                  );
                }
              )
            )
          );
      }),
    );
  }
}
