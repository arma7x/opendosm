import 'package:flutter/material.dart';

class PremiseWidget extends StatelessWidget {
  const PremiseWidget({
    super.key,
    required this.premise,
    required this.premise_type,
    required this.address,
    required this.district,
    required this.state,

  });

  final String premise;
  final String premise_type;
  final String address;
  final String district;
  final String state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(premise),
            Text("(", style: new TextStyle(fontWeight: FontWeight.bold)),
            Text(premise_type, style: new TextStyle(fontWeight: FontWeight.bold)),
            Text(")", style: new TextStyle(fontWeight: FontWeight.bold)),
          ]
        ),
        SizedBox(height: 5),
        Text(address),
        SizedBox(height: 8),
        Text(
          district + ", " +  state,
          style: new TextStyle(
            fontSize: 14.0,
          )
        )
      ]
    );
  }
}
