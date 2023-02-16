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
        Text(
          premise,
          style: new TextStyle(
            fontWeight: FontWeight.bold
          )
        ),
        SizedBox(height: 5),
        Text(address),
        SizedBox(height: 8),
        Text(
          premise_type + ", " + district + ", " +  state,
          style: new TextStyle(
            fontSize: 14.0,
          )
        )
      ]
    );
  }
}
