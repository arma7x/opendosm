import 'package:flutter/material.dart';
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
              "Data not available",
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
                    Text("RM" + double.parse(widget.priceList[index]["price"]!.toString()).toStringAsFixed(2)),
                    Text(widget.priceList[index]["last_update"]!.toString()),
                    Text(widget.priceList[index]["premise"]!.toString()),
                    Text(widget.priceList[index]["address"]!.toString()),
                    Text(widget.priceList[index]["premise_type"]!.toString()),
                    Text(widget.priceList[index]["state"]!.toString()),
                    Text(widget.priceList[index]["district"]!.toString())
                  ]
                ),
              )
            )
          );
      }),
    );
  }
}
