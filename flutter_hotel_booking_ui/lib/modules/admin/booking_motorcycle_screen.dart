import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ui/routes/route_names.dart';
import 'package:flutter_hotel_booking_ui/utils/themes.dart';
import 'package:location_repository/location_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingMotorcycleScreen extends StatefulWidget {
  // final Location location;
  const BookingMotorcycleScreen({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BookingMotorcycleScreenState createState() =>
      _BookingMotorcycleScreenState();
}

class _BookingMotorcycleScreenState extends State<BookingMotorcycleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  String selectedLocation = 'All Locations';
  List<String> locations = ['All Locations'];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animationController.forward();
    // Load locations from Firebase
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locationsSnapshot =
        await FirebaseFirestore.instance.collection('locations').get();
    final locationNames = locationsSnapshot.docs
        .map((doc) => doc['locationName'] as String)
        .toList();

    setState(() {
      locations.addAll(locationNames);
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _navigateToDetail(String title) {
    animationController.forward();
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailScreen(
              title: title,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        )
        .then((_) => animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách xe máy dựa trên địa điểm được chọn
    final filteredMotorcycles = selectedLocation == 'All Locations'
        ? motorcycles
        : motorcycles
            .where((bikes) => bikes['bikeName'] == selectedLocation)
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDDCDC),
        elevation: 0,
        title: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.directions_car,
              color: Colors.black87,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Quản Lý Xe Thuê',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black26,
                    offset: Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLocation = newValue!;
                });
              },
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: filteredMotorcycles.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _navigateToDetail(filteredMotorcycles[index]['name']!);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.motorcycle,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            filteredMotorcycles[index]['name']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // NavigationServices(context)
          //     .gotoCreateMotorcycleScreen(widget.location.locationId);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  final List<Map<String, String>> motorcycles = [
    {'name': 'Motorcycle 1', 'location': 'Location 1'},
    {'name': 'Motorcycle 2', 'location': 'Location 2'},
    {'name': 'Motorcycle 3', 'location': 'Location 3'},
    {'name': 'Motorcycle 4', 'location': 'Location 1'},
  ];
}

class DetailScreen extends StatelessWidget {
  final String title;

  const DetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Đây là chi tiết của $title.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Xóa',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Thêm logic cập nhật tại đây
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Cập Nhật',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
