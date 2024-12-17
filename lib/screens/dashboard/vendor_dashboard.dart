import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../new_changes/screens/home_new.dart';
import '../../widgets/vendor_drawer.dart';
import '../profiles/vendor_new.dart';

class VendorDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {'name': 'Plumber', 'description': 'Post plumbing services', 'icon': Icons.plumbing},
    {'name': 'Electrician', 'description': 'Post electrical services', 'icon': Icons.electrical_services},
    {'name': 'Cleaner', 'description': 'Post cleaning services', 'icon': Icons.cleaning_services},
    {'name': 'Painter', 'description': 'Post painting services', 'icon': Icons.format_paint},
    {'name': 'Carpenter', 'description': 'Post carpentry services', 'icon': Icons.handyman},
  ];

  final TextEditingController serviceNameController = TextEditingController();
  final TextEditingController serviceDescriptionController = TextEditingController();
  final TextEditingController serviceExperienceController = TextEditingController();
  final TextEditingController serviceExpensesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: VendorDrawer(),


      body: CustomScrollView(
        slivers: [
          // SliverAppBar with CircleAvatar for Profile and Logo
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.lightBlue, AppColors.darkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Vendor Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.lightBlue,
          ),

          // Service Grid inside a Sliver
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1, // Square cards
            ),

            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final service = services[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(service['icon'], size: 40, color: AppColors.lightBlue),
                      SizedBox(height: 10),
                      Text(
                        service['name'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        service['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              },
              childCount: services.length, // Number of items in the grid
            ),
          ),
        ],
      ),
    );
  }

}
