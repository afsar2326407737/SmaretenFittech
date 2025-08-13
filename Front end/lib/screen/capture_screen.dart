import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../components/scaffold_message_showing.dart';
import '../db/database_helper.dart';
import '../model/post_entry.dart';
import '../services/firebase_services.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _imageFile;
  bool _loading = false;

  //pick image from the gallery
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  //Send the image to backend
  Future<void> _sendToBackend(BuildContext context) async {
    if (_imageFile == null) return;
    setState(() => _loading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.16.146.200:5000/analyze-pose'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("${response.statusCode} + thsi is the response");
        var data = jsonDecode(response.body);
        var keypoints = data['keypoints'];

        // upload image to fire store to url
        String? imageUrl = await FirebaseService.uploadImageToFirebase(
          _imageFile!,
        );

        // db code for storing the value in the mysql
        final dbHelper = DatabaseHelper();
        final timestamp = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(DateTime.now());

        // store in the local sql
        final poseEntry = PoseEntry(
          keypointsJson: jsonEncode(keypoints),
          timestamp: timestamp,
          imagePath: _imageFile!.path,
          imageUrl: imageUrl ?? "",
        );

        //db entry
        await dbHelper.insertPoseEntry(poseEntry);

        //send this to the fire base fire sotre
        await FirebaseService.syncPoseToFirestore(poseEntry);

        ScaffoldMessage.showSuccessMessage(context, "Image Posted Succesfully");

        print("Saved to SQLite: ${poseEntry.imagePath} This is the image path");
      } else {
        ScaffoldMessage.showErrorMessage(
          context,
          "Some Error Occuring in the Backend",
        );
        print({response.body});
      }
    } catch (e) {
      ScaffoldMessage.showErrorMessage(context, "Something Went Wrong");
      print(e);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 200)
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black, // Black background
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(
                    color: Colors.green, // Green border
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightGreen,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(
                      color: Colors.green, // Green text
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    label: const Text(
                      'Camera',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo, color: Colors.black),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Slight curve
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () {
                        if (_imageFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select an image before sending.',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          _sendToBackend(context);
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.green)
                    : const Text(
                        'Send to Track',
                        style: TextStyle(
                          color: Colors.green, // Green text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),
            //this is for debugging purpose
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     style: OutlinedButton.styleFrom(
            //       backgroundColor: Colors.black,
            //       side: const BorderSide(color: Colors.green, width: 2),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            //     ),
            //     onPressed: () => BackendService.debugPrintAllPoses(),
            //     child: const Text(
            //       'Show Log',
            //       style: TextStyle(
            //         color: Colors.green,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
