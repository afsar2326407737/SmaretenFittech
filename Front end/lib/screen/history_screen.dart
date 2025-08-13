import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymassistanat/screen/pose_details.dart';

import '../bloc/pose_history_bloc.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  //network check
  Future<bool> _hasNetwork() async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PoseHistoryBloc>().add(LoadPoseHistory());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PoseHistoryBloc, PoseHistoryState>(
      builder: (context, state) {
        if (state is PoseHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PoseHistoryLoaded) {
          if (state.entries.isEmpty) {
            return const Center(
              child: Text(
                'No pose history yet.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: state.entries.length,
            itemBuilder: (_, i) {
              final entry = state.entries[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PoseDetailScreen(entry: entry),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: FutureBuilder<bool>(
                            future: _hasNetwork(),
                            builder: (context, snapshot) {
                              bool online = snapshot.data ?? false;
                              if (online &&
                                  entry.imageUrl != null &&
                                  entry.imageUrl!.isNotEmpty) {
                                return Image.network(
                                  entry.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    if (entry.imagePath != null &&
                                        File(entry.imagePath).existsSync()) {
                                      return Image.file(
                                        File(entry.imagePath),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    } else {
                                      return Container(
                                        color: Colors.black,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      );
                                    }
                                  },
                                );
                              } else {
                                if (entry.imagePath != null &&
                                    File(entry.imagePath).existsSync()) {
                                  return Image.file(
                                    File(entry.imagePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                } else {
                                  return Container(
                                    color: Colors.black,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      )
                      ,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          entry.timestamp,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        if (state is PoseHistoryError) {
          return Center(child: Text(state.message));
        }
        return Container();
      },
    );
  }
}
