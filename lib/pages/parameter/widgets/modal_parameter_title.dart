import 'package:flutter/material.dart';

class ModalParameterTitle extends StatelessWidget {
  const ModalParameterTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Paramétrage",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.orange,
      ),
    );
  }
}
