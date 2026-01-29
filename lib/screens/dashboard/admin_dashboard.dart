import 'package:flutter/material.dart';
import '../inventory/item_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // AdminDashboard can act as a wrapper or just directly show the list
    // The prompt says "Redirect automatically to Dashboard Admin"
    // So this is the main container for Admin features.
    // For now, it mainly contains the ItemList with admin privileges.
    return const ItemListScreen(isAdmin: true);
  }
}
