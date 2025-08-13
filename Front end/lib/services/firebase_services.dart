import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:gymassistanat/model/post_entry.dart';

class FirebaseService {
  //send the image to the fire store
  static Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded to Firebase Storage. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  //sync this data store it in the firebase storage
  static Future<void> syncPoseToFirestore(PoseEntry entry) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance.collection(
        'pose_keypoints',
      );

      await collection.add({
        'keypoints': entry.keypointsJson,
        'timestamp': entry.timestamp,
        'image_url': entry.imageUrl,
      });

      print('Pose synced to Firestore!');
    } catch (e) {
      print('Firestore sync failed: $e');
      // TODO: Add retry or queue logic here
    }
  }

  // fetch the data from the firebase
  Future<List<PoseEntry>> fetchPoseHistoryFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('pose_keypoints')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PoseEntry(
        keypointsJson: data['keypoints'] ?? '',
        timestamp: data['timestamp'] ?? '',
        imagePath: '',
        imageUrl: data['image_url'] ?? '',
      );
    }).toList();
  }


}