import 'package:nfc_deck_tracker/data/model/page.dart';

import '../entity/page.dart';

class PageMapper {
  static PageEntity toEntity(PageModel model) => PageEntity(
        collectionId: model.collectionId,
        paging: model.paging,
      );

  static PageModel toModel(PageEntity entity) => PageModel(
        collectionId: entity.collectionId,
        paging: entity.paging,
      );
}
