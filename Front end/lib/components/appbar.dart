import 'package:flutter/material.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Smartan FitTech",
        style: TextStyle(
          color: Colors.green, // Green text
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: Colors.white, // Black background
      elevation: 4, // Slight shadow
      centerTitle: true, // Center align the title
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
