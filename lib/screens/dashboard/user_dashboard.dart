import 'package:flutter/material.dart';
import '../inventory/item_list_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // UserDashboard acts as container for User features.
    return const ItemListScreen(isAdmin: true);
  }
}
