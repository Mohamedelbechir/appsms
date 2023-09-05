import 'package:flutter/material.dart';

class ModalParameterTitle extends StatelessWidget {
  const ModalParameterTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 15),
      child: Text(
        "Paramétrage",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
          color: Colors.orange,
        ),
      ),
    );
  }
}
