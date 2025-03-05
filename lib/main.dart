import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen Implementation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'IQAMAH TIME')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset('assets/images/splash_logo.png.png', width: 250), // Ensure correct image path
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 30), // Adds bottom padding
            child: Text(
              'Developed by IT Docx',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xff172e38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WebViewController _controller;
  double _progress = 0.0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _progress = progress / 100; // Convert progress to percentage
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://iqamahtime.com'));
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Location location = Location();
      await location.getLocation();
    }
  }

  Future<void> _refreshWebView() async {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xff172e38)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Iqamah Time',
                    style: TextStyle(color: Color(0xff13a55c), fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _controller.loadRequest(Uri.parse('https://iqamahtime.com'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.find_in_page),
              title: const Text('Find Nearby Mosque'),
              onTap: () {
                Navigator.pop(context);
                _controller.loadRequest(Uri.parse('https://www.iqamahtime.com/near-mosques/?lat=31.5203696&lng=74.3587473'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New Mosque'),
              onTap: () {
                Navigator.pop(context);
                _controller.loadRequest(Uri.parse('https://www.iqamahtime.com/login/?redirect_to=https%3A%2F%2Fwww.iqamahtime.com%2Fadd-mosques%2F'));
                // Future feature: Navigate to settings screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Exit'),
              onTap: () {
                Navigator.pop(context);
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
                // Exit the app
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshWebView,
            child: WebViewWidget(controller: _controller),
          ),
          if (_progress < 1.0) // Show progress bar when loading
            LinearProgressIndicator(value: _progress, color: Colors.blue),
        ],
      ),
    );
  }
}
