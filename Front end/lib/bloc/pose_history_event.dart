part of 'pose_history_bloc.dart';

sealed class PoseHistoryEvent extends Equatable {
  const PoseHistoryEvent();
}

class LoadPoseHistory extends PoseHistoryEvent {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AddPoseEntry extends PoseHistoryEvent {
  final PoseEntry entry;
  AddPoseEntry(this.entry);
  @override
  List<Object?> get props => [entry];
}
class SyncToCloud extends PoseHistoryEvent {
  final PoseEntry entry;
  SyncToCloud(this.entry);
  @override
  List<Object?> get props => [entry];
}
