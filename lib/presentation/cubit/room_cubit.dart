import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/close_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/join_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_room.dart';

part 'room_state.dart';

class RoomCubit extends Cubit<RoomState> {
  final CloseRoomUsecase closeRoomUsecase;
  final CreateRoomUsecase createRoomUsecase;
  final FetchRoomUsecase fetchRoomUsecase;
  final JoinRoomUsecase joinRoomUsecase;
  final UpdateRoomUsecase updateRoomUsecase;

  RoomCubit({
    required this.closeRoomUsecase,
    required this.createRoomUsecase,
    required this.fetchRoomUsecase,
    required this.joinRoomUsecase,
    required this.updateRoomUsecase,
  }) : super(const RoomState());
}
