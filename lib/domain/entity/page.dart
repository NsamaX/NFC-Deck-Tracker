import 'package:equatable/equatable.dart';

class PageEntity extends Equatable {
  final String collectionId;
  final Map<String, dynamic> paging;

  const PageEntity({
    required this.collectionId,
    required this.paging,
  });

  PageEntity copyWith({
    String? collectionId,
    Map<String, dynamic>? paging,
  }) =>
      PageEntity(
        collectionId: collectionId ?? this.collectionId,
        paging: paging ?? this.paging,
      );

  @override
  List<Object?> get props => [
        collectionId,
        paging,
      ];
}
