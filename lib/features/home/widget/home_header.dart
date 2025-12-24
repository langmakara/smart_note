import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueAccent,
      child: const Text(
        "ខែ ធ្នូ ២០២៣",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
