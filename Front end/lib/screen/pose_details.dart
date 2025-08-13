import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymassistanat/components/appbar.dart';

import '../model/post_entry.dart';
import '../services/photo_map_services.dart';
import 'show_full_screen.dart';

class PoseDetailScreen extends StatefulWidget {
  final PoseEntry entry;

  const PoseDetailScreen({super.key, required this.entry});

  @override
  State<PoseDetailScreen> createState() => _PoseDetailScreenState();
}

class _PoseDetailScreenState extends State<PoseDetailScreen> {
  bool showOverlay = false;
  late List<dynamic> keypoints;

  // track the dots
  final List<List<int>> poseConnections = [
    [0, 1], [1, 2], [2, 3], [3, 7], // right arm
    [0, 4], [4, 5], [5, 6], [6, 8], // left arm
    [9, 10], // eyes
    [11, 12], // shoulders
    [11, 13], [13, 15], // right leg
    [12, 14], [14, 16], // left leg
    [11, 23], [12, 24], // torso sides
    [23, 24], // hips
    [23, 25], [25, 27], // right lower leg
    [24, 26], [26, 28], // left lower leg
  ];

  @override
  void initState() {
    super.initState();
    try {
      keypoints = jsonDecode(widget.entry.keypointsJson ?? '[]');
    } catch (_) {
      keypoints = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: widget.entry.imageUrl != null
                        ? Image.network(widget.entry.imageUrl ?? "https://as2.ftcdn.net/jpg/02/43/13/15/1000_F_243131531_jmNppYX9Ux2Hj2RV9yYR1swicwcYr8EQ.jpg", fit: BoxFit.cover)
                        : Container(color: Colors.grey[900]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Uploaded on: ${widget.entry.timestamp}",
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    showOverlay ? Icons.visibility_off : Icons.visibility,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullscreenPoseView(
                          imagePath: widget.entry.imageUrl
                              ??
                              // image error handling
                              "https://as2.ftcdn.net/jpg/02/43/13/15/1000_F_243131531_jmNppYX9Ux2Hj2RV9yYR1swicwcYr8EQ.jpg",
                          keypoints: keypoints,
                          poseConnections: poseConnections,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Table(
                border: TableBorder.all(color: Colors.green),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Colors.green),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Point", style: TextStyle(color: Colors.black)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("X", style: TextStyle(color: Colors.black)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Y", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  ...keypoints.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var point = entry.value;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("$idx", style: const TextStyle(color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(point['x'].toStringAsFixed(3), style: const TextStyle(color: Colors.white)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(point['y'].toStringAsFixed(3), style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

