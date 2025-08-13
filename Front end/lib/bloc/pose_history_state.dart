part of 'pose_history_bloc.dart';

sealed class PoseHistoryState extends Equatable {
  const PoseHistoryState();
}

final class PoseHistoryInitial extends PoseHistoryState {
  @override
  List<Object> get props => [];
}

final class PoseHistoryLoading extends PoseHistoryState{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class PoseHistoryLoaded extends PoseHistoryState {
  final List<PoseEntry> entries;
  PoseHistoryLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}
class PoseHistoryError extends PoseHistoryState {
  final String message;
  PoseHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
class PoseEntryAdded extends PoseHistoryState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class PoseEntrySynced extends PoseHistoryState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

