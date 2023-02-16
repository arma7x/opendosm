import 'package:flutter/material.dart';
import 'package:opendosm_pricecatcher/widgets/widgets.dart' show PremiseWidget;
import './PriceCatcherScreen.dart';
import './api.dart';

class PriceListViewer extends StatefulWidget {
  const PriceListViewer({super.key, required this.title, required this.priceList});

  final String title;
  final List<Map<String, dynamic>> priceList;

  @override
  State<PriceListViewer> createState() => _PriceListViewerState();
}

class _PriceListViewerState extends State<PriceListViewer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.priceList.length == 0 ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Data tidak tersedia!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ) : ListView.builder(
        itemCount: widget.priceList.length,
        itemBuilder: (BuildContext _, int index) {
          return Card(
            color: Colors.grey[200],
            child: Container(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "RM" + double.parse(widget.priceList[index]["price"]!.toString()).toStringAsFixed(2),
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue
                          )
                        ),
                        Text(
                          widget.priceList[index]["last_update"]!.toString(),
                          style: new TextStyle(fontWeight: FontWeight.bold)
                        ),
                      ]
                    ),
                    SizedBox(height: 8),
                    PremiseWidget(
                      premise: widget.priceList[index]["premise"]!.toString(),
                      premise_type: widget.priceList[index]["premise_type"]!.toString(),
                      address: widget.priceList[index]["address"]!.toString(),
                      district: widget.priceList[index]["district"]!.toString(),
                      state: widget.priceList[index]["state"]!.toString(),
                    ),
                  ]
                ),
              )
            )
          );
      }),
    );
  }
}
