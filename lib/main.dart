import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_priority_marker/priority_marker_layer.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: controller,
        options: MapOptions(
          center: const LatLng(37.3044847, 127.0446371),
          zoom: 15,
          onMapEvent: (p0) {
            log(p0.zoom.toString());
          },
          interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PriorityMarkerLayer(markers: [
            PriorityMarker(
              point: const LatLng(37.3044847, 127.0446371),
              priority: priorityVeryHigh,
              builder: (context) {
                return const Icon(Icons.place);
              },
            ),
            PriorityMarker(
              point: const LatLng(37.3044847, 127.0452371),
              priority: priorityHigh,
              builder: (context) {
                return const Icon(Icons.place);
              },
            ),
            PriorityMarker(
              point: const LatLng(37.3044847, 127.0458371),
              priority: priorityMedium,
              builder: (context) {
                return const Icon(Icons.place);
              },
            ),
            PriorityMarker(
              point: const LatLng(37.3044847, 127.0464371),
              priority: priorityLow,
              builder: (context) {
                return const Icon(Icons.place);
              },
            ),
            PriorityMarker(
              point: const LatLng(37.3044847, 127.0470371),
              priority: priorityVeryLow,
              builder: (context) {
                return const Icon(Icons.place);
              },
            ),
          ]),
        ],
      ),
    );
  }
}
