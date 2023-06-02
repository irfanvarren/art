import 'package:flutter/material.dart';
//import 'package:art/layout/adaptive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onPressed: () {},
        ),
        title: const Text(
          "Logo",
        ),
      ),
      body: const Center(
        child: Text(
          "Home",
        ),
      ),
    );
  }
}
