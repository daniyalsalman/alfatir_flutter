// lib/qibla_compass_screen.dart

import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:permission_handler/permission_handler.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _getPermissions();
  }

  Future<void> _getPermissions() async {
    if (await Permission.location.request().isGranted) {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Compass')),
      body: FutureBuilder(
        future: FlutterQiblah.androidDeviceSensorSupport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.data == true) {
            // Sensors supported
            return _hasPermission
                ? const QiblaCompassWidget()
                : Center(
                    child: ElevatedButton(
                      onPressed: _getPermissions,
                      child: const Text('Request Location Permission'),
                    ),
                  );
          } else {
            return const Center(child: Text("Your device doesn't support Qibla sensors"));
          }
        },
      ),
    );
  }
}

class QiblaCompassWidget extends StatelessWidget {
  const QiblaCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("Waiting for sensor data..."));
        }

        final qiblahDirection = snapshot.data!;
        
        // qiblahDirection.direction: Device heading (0-360)
        // qiblahDirection.offset: Qibla bearing relative to North
        // We want the arrow to point to Qibla relative to the device.
        // Rotation = (Bearing - Heading)
        
        // For animation smoothness
        var direction = qiblahDirection.qiblah; // The deviation from North to Qibla
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${qiblahDirection.offset.toStringAsFixed(1)}°",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Qibla Angle"),
              const SizedBox(height: 50),
              SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. The Compass Dial (Optional: rotates to point North)
                    // If you want a static dial, just show an image. 
                    // If you want the dial to rotate with the phone so 'N' points North:
                    // Transform.rotate(angle: (qiblahDirection.direction * (pi / 180) * -1), child: Image.asset('...')),
                    
                    // Simple representation: A fixed circle background
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                    
                    // 2. The Needle pointing to Qibla
                    // The arrow should rotate to point towards the Qibla
                    // Angle = (Qibla Bearing - Device Heading) * (pi / 180)
                    Transform.rotate(
                      angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.navigation, // Use a nice arrow icon or asset
                        size: 100,
                        color: Colors.green,
                      ),
                    ),
                    
                    // 3. Static North marker for reference (optional if using simple arrow)
                    const Positioned(
                      top: 10,
                      child: Text("N", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Calibrate your compass by waving your device in a figure-8 motion if accuracy is low.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}