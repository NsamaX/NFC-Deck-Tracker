part of 'bloc.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => [];
}

class SetCardNameEvent extends CardEvent {
  final String name;

  const SetCardNameEvent({
    required this.name,
  });

  @override
  List<Object?> get props => [name];
}

class SetCardImageUrlEvent extends CardEvent {
  final String imageUrl;

  const SetCardImageUrlEvent({
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [imageUrl];
}

class SetCardDescriptionEvent extends CardEvent {
  final String description;

  const SetCardDescriptionEvent({
    required this.description,
  });

  @override
  List<Object?> get props => [description];
}

class SetCardAdditionalDataEvent extends CardEvent {
  final Map<String, dynamic> additionalData;

  const SetCardAdditionalDataEvent({
    required this.additionalData,
  });

  @override
  List<Object?> get props => [additionalData];
}

class CreateCardEvent extends CardEvent {
  final String userId;
  final String collectionId;
  final AppLocalization locale;

  const CreateCardEvent({
    required this.userId,
    required this.collectionId,
    required this.locale,
  });

  @override
  List<Object?> get props => [userId, collectionId, locale];
}

class UpdateCardEvent extends CardEvent {
  final String userId;

  const UpdateCardEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}
