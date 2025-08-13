import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../model/post_entry.dart';
import '../services/firebase_services.dart';

part 'pose_history_event.dart';
part 'pose_history_state.dart';

class PoseHistoryBloc extends Bloc<PoseHistoryEvent, PoseHistoryState> {
  final DatabaseHelper dbHelper;
  final FirebaseService firebaseService;

  PoseHistoryBloc(
      {required this.dbHelper, required this.firebaseService}
      ) : super(PoseHistoryInitial()) {
    on<LoadPoseHistory>((event, emit) async {
      emit(PoseHistoryLoading());
      try {

        final localEntries = await dbHelper.getAllPoseEntries();
        List<PoseEntry> mergedEntries = List.from(localEntries);

        try {

          final cloudEntries = await firebaseService
              .fetchPoseHistoryFromFirestore()
              .timeout(
            const Duration(seconds: 2),
            // send the local storage data to the front end
            onTimeout: () {
              emit(PoseHistoryLoaded(mergedEntries));
              throw TimeoutException('Fetching pose history timed out');
            },
          );
          if (cloudEntries != null) {
            for (var cloudEntry in cloudEntries) {
              final exists = mergedEntries.any((local) => local.timestamp == cloudEntry.timestamp);
              if (!exists) {
                mergedEntries.add(cloudEntry);
                await dbHelper.insertPoseEntry(cloudEntry);
              }
            }
          }

        } catch (e) {
          print("Cloud fetch failed: $e");
          // No cloud data → still emit local
          emit(PoseHistoryLoaded(mergedEntries));
          return; // Stop here so we don't emit twice
        }

        // Sort and send final merged list
        mergedEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        emit(PoseHistoryLoaded(mergedEntries));

      } catch (e) {
        emit(PoseHistoryError('Failed to load pose history: $e'));
      }
    });


    on<AddPoseEntry>((event, emit) async {
      try {
        await dbHelper.insertPoseEntry(event.entry);
        emit(PoseEntryAdded());
        add(LoadPoseHistory());
      } catch (e) {
        emit(PoseHistoryError('Failed to add pose entry: $e'));
      }
    });
  }
}
