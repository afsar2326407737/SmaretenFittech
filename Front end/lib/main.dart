import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymassistanat/components/appbar.dart';
import 'package:gymassistanat/screen/capture_screen.dart';
import 'package:gymassistanat/screen/history_screen.dart';
import 'package:gymassistanat/services/firebase_services.dart';
import 'bloc/pose_history_bloc.dart';
import 'db/database_helper.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PoseApp());
}

class PoseApp extends StatelessWidget {
  const PoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PoseHistoryBloc(
            dbHelper: DatabaseHelper(),
            firebaseService: FirebaseService(),
          )..add(LoadPoseHistory()),
        ),
      ],
      child: MaterialApp(
        title: 'Pose Analysis Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black26),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    CaptureScreen(),
    HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt, ),
            activeIcon: Icon(Icons.camera_alt, color: Colors.white), // Active state
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            activeIcon: Icon(Icons.history, color: Colors.white),
            label: 'History',
          ),
        ],
        backgroundColor: Colors.black26,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green, // Active item color
        unselectedItemColor: Colors.white70, // Inactive color
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed, // Prevent shifting
        elevation: 8, // Slight shadow
        onTap: _onItemTapped,
      ),
    );
  }
}