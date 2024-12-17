import 'package:flutter/material.dart';
import '../../colors/colors.dart';
import '../../widgets/customer_drawer.dart';

class ConsumerDashboard extends StatelessWidget {
  final bool showDrawer;

  ConsumerDashboard({this.showDrawer = true});

  final List<Map<String, dynamic>> services = [
    {'name': 'Plumber', 'description': 'Expert plumbing services', 'icon': Icons.plumbing},
    {'name': 'Electrician', 'description': 'Electrical repairs and installations', 'icon': Icons.electrical_services},
    {'name': 'Cleaner', 'description': 'Professional cleaning services', 'icon': Icons.cleaning_services},
    {'name': 'Painter', 'description': 'House and office painting', 'icon': Icons.format_paint},
    {'name': 'Carpenter', 'description': 'Carpentry work and repairs', 'icon': Icons.handyman},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer ? CustomDrawer() : null, // Use the CustomDrawer widget
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: showDrawer,
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
                    'Our Services',
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    'Services Offered',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 30.0,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to service detail
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black45,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                service['icon'],
                                size: 40,
                                color: AppColors.lightBlue,
                              ),
                              SizedBox(height: 10),
                              Text(
                                service['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                service['description'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: services.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
