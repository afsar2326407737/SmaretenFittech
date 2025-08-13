import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gymassistanat/screen/pose_details.dart';

import '../services/photo_map_services.dart';

class FullscreenPoseView extends StatelessWidget {
  final String imagePath;
  final List<dynamic> keypoints;
  final List<List<int>> poseConnections;

  const FullscreenPoseView({
    super.key,
    required this.imagePath,
    required this.keypoints,
    required this.poseConnections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(imagePath, fit: BoxFit.contain),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: PosePainter(keypoints, poseConnections),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
