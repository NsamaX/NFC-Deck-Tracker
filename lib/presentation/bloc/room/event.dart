part of 'bloc.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class CloseRoomEvent extends RoomEvent {
  final String roomId;
  const CloseRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class CreateRoomEvent extends RoomEvent {
  final List<String> playerIds;
  const CreateRoomEvent({required this.playerIds});

  @override
  List<Object?> get props => [playerIds];
}

class JoinRoomEvent extends RoomEvent {
  final String roomId;
  final String userId;
  const JoinRoomEvent({required this.roomId, required this.userId});

  @override
  List<Object?> get props => [roomId, userId];
}

class UpdateRoomEvent extends RoomEvent {
  final RoomEntity room;
  const UpdateRoomEvent({required this.room});

  @override
  List<Object?> get props => [room];
}
