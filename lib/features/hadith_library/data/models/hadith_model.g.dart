// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHadithModelCollection on Isar {
  IsarCollection<HadithModel> get hadithModels => this.collection();
}

const HadithModelSchema = CollectionSchema(
  name: r'HadithModel',
  id: 2996551401430268061,
  properties: {
    r'bookId': PropertySchema(
      id: 0,
      name: r'bookId',
      type: IsarType.long,
    ),
    r'bookKey': PropertySchema(
      id: 1,
      name: r'bookKey',
      type: IsarType.string,
    ),
    r'bookTitle': PropertySchema(
      id: 2,
      name: r'bookTitle',
      type: IsarType.string,
    ),
    r'chapterId': PropertySchema(
      id: 3,
      name: r'chapterId',
      type: IsarType.long,
    ),
    r'chapterTitle': PropertySchema(
      id: 4,
      name: r'chapterTitle',
      type: IsarType.string,
    ),
    r'idInBook': PropertySchema(
      id: 5,
      name: r'idInBook',
      type: IsarType.long,
    ),
    r'normalizedText': PropertySchema(
      id: 6,
      name: r'normalizedText',
      type: IsarType.string,
    ),
    r'textArabic': PropertySchema(
      id: 7,
      name: r'textArabic',
      type: IsarType.string,
    )
  },
  estimateSize: _hadithModelEstimateSize,
  serialize: _hadithModelSerialize,
  deserialize: _hadithModelDeserialize,
  deserializeProp: _hadithModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookKey_chapterId': IndexSchema(
      id: 6519925089177057250,
      name: r'bookKey_chapterId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'chapterId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'bookId': IndexSchema(
      id: 3567540928881766442,
      name: r'bookId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'normalizedText': IndexSchema(
      id: -8399031562658649671,
      name: r'normalizedText',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'normalizedText',
          type: IndexType.value,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _hadithModelGetId,
  getLinks: _hadithModelGetLinks,
  attach: _hadithModelAttach,
  version: '3.1.0+1',
);

int _hadithModelEstimateSize(
  HadithModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookKey.length * 3;
  bytesCount += 3 + object.bookTitle.length * 3;
  bytesCount += 3 + object.chapterTitle.length * 3;
  bytesCount += 3 + object.normalizedText.length * 3;
  bytesCount += 3 + object.textArabic.length * 3;
  return bytesCount;
}

void _hadithModelSerialize(
  HadithModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.bookId);
  writer.writeString(offsets[1], object.bookKey);
  writer.writeString(offsets[2], object.bookTitle);
  writer.writeLong(offsets[3], object.chapterId);
  writer.writeString(offsets[4], object.chapterTitle);
  writer.writeLong(offsets[5], object.idInBook);
  writer.writeString(offsets[6], object.normalizedText);
  writer.writeString(offsets[7], object.textArabic);
}

HadithModel _hadithModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HadithModel(
    bookId: reader.readLong(offsets[0]),
    bookKey: reader.readString(offsets[1]),
    bookTitle: reader.readString(offsets[2]),
    chapterId: reader.readLong(offsets[3]),
    chapterTitle: reader.readString(offsets[4]),
    idInBook: reader.readLong(offsets[5]),
    normalizedText: reader.readString(offsets[6]),
    textArabic: reader.readString(offsets[7]),
  );
  object.id = id;
  return object;
}

P _hadithModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hadithModelGetId(HadithModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hadithModelGetLinks(HadithModel object) {
  return [];
}

void _hadithModelAttach(
    IsarCollection<dynamic> col, Id id, HadithModel object) {
  object.id = id;
}

extension HadithModelQueryWhereSort
    on QueryBuilder<HadithModel, HadithModel, QWhere> {
  QueryBuilder<HadithModel, HadithModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhere> anyBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bookId'),
      );
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhere> anyNormalizedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'normalizedText'),
      );
    });
  }
}

extension HadithModelQueryWhere
    on QueryBuilder<HadithModel, HadithModel, QWhereClause> {
  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyEqualToAnyChapterId(String bookKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookKey_chapterId',
        value: [bookKey],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyNotEqualToAnyChapterId(String bookKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [],
              upper: [bookKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [],
              upper: [bookKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyChapterIdEqualTo(String bookKey, int chapterId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookKey_chapterId',
        value: [bookKey, chapterId],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyEqualToChapterIdNotEqualTo(String bookKey, int chapterId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey],
              upper: [bookKey, chapterId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey, chapterId],
              includeLower: false,
              upper: [bookKey],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey, chapterId],
              includeLower: false,
              upper: [bookKey],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey_chapterId',
              lower: [bookKey],
              upper: [bookKey, chapterId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyEqualToChapterIdGreaterThan(
    String bookKey,
    int chapterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookKey_chapterId',
        lower: [bookKey, chapterId],
        includeLower: include,
        upper: [bookKey],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyEqualToChapterIdLessThan(
    String bookKey,
    int chapterId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookKey_chapterId',
        lower: [bookKey],
        upper: [bookKey, chapterId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      bookKeyEqualToChapterIdBetween(
    String bookKey,
    int lowerChapterId,
    int upperChapterId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookKey_chapterId',
        lower: [bookKey, lowerChapterId],
        includeLower: includeLower,
        upper: [bookKey, upperChapterId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> bookIdEqualTo(
      int bookId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookId',
        value: [bookId],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> bookIdNotEqualTo(
      int bookId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [bookId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookId',
              lower: [],
              upper: [bookId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> bookIdGreaterThan(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [bookId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> bookIdLessThan(
    int bookId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [],
        upper: [bookId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause> bookIdBetween(
    int lowerBookId,
    int upperBookId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'bookId',
        lower: [lowerBookId],
        includeLower: includeLower,
        upper: [upperBookId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextEqualTo(String normalizedText) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedText',
        value: [normalizedText],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextNotEqualTo(String normalizedText) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedText',
              lower: [],
              upper: [normalizedText],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedText',
              lower: [normalizedText],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedText',
              lower: [normalizedText],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'normalizedText',
              lower: [],
              upper: [normalizedText],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextGreaterThan(
    String normalizedText, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'normalizedText',
        lower: [normalizedText],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextLessThan(
    String normalizedText, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'normalizedText',
        lower: [],
        upper: [normalizedText],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextBetween(
    String lowerNormalizedText,
    String upperNormalizedText, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'normalizedText',
        lower: [lowerNormalizedText],
        includeLower: includeLower,
        upper: [upperNormalizedText],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextStartsWith(String NormalizedTextPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'normalizedText',
        lower: [NormalizedTextPrefix],
        upper: ['$NormalizedTextPrefix\u{FFFFF}'],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'normalizedText',
        value: [''],
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterWhereClause>
      normalizedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'normalizedText',
              upper: [''],
            ))
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'normalizedText',
              lower: [''],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.greaterThan(
              indexName: r'normalizedText',
              lower: [''],
            ))
            .addWhereClause(IndexWhereClause.lessThan(
              indexName: r'normalizedText',
              upper: [''],
            ));
      }
    });
  }
}

extension HadithModelQueryFilter
    on QueryBuilder<HadithModel, HadithModel, QFilterCondition> {
  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> bookKeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookKey',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookKey',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      bookTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chapterTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chapterTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      chapterTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chapterTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idInBookEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idInBook',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      idInBookGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idInBook',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      idInBookLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idInBook',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition> idInBookBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idInBook',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'normalizedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'normalizedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'normalizedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'normalizedText',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      normalizedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'normalizedText',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'textArabic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'textArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'textArabic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'textArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterFilterCondition>
      textArabicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'textArabic',
        value: '',
      ));
    });
  }
}

extension HadithModelQueryObject
    on QueryBuilder<HadithModel, HadithModel, QFilterCondition> {}

extension HadithModelQueryLinks
    on QueryBuilder<HadithModel, HadithModel, QFilterCondition> {}

extension HadithModelQuerySortBy
    on QueryBuilder<HadithModel, HadithModel, QSortBy> {
  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByChapterTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy>
      sortByChapterTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByIdInBook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idInBook', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByIdInBookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idInBook', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByNormalizedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedText', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy>
      sortByNormalizedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedText', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByTextArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> sortByTextArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textArabic', Sort.desc);
    });
  }
}

extension HadithModelQuerySortThenBy
    on QueryBuilder<HadithModel, HadithModel, QSortThenBy> {
  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookId', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByBookTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookTitle', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByChapterTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy>
      thenByChapterTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterTitle', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByIdInBook() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idInBook', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByIdInBookDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idInBook', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByNormalizedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedText', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy>
      thenByNormalizedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'normalizedText', Sort.desc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByTextArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QAfterSortBy> thenByTextArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textArabic', Sort.desc);
    });
  }
}

extension HadithModelQueryWhereDistinct
    on QueryBuilder<HadithModel, HadithModel, QDistinct> {
  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByBookId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookId');
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByBookKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByBookTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterId');
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByChapterTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByIdInBook() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idInBook');
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByNormalizedText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'normalizedText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithModel, HadithModel, QDistinct> distinctByTextArabic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textArabic', caseSensitive: caseSensitive);
    });
  }
}

extension HadithModelQueryProperty
    on QueryBuilder<HadithModel, HadithModel, QQueryProperty> {
  QueryBuilder<HadithModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HadithModel, int, QQueryOperations> bookIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookId');
    });
  }

  QueryBuilder<HadithModel, String, QQueryOperations> bookKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookKey');
    });
  }

  QueryBuilder<HadithModel, String, QQueryOperations> bookTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookTitle');
    });
  }

  QueryBuilder<HadithModel, int, QQueryOperations> chapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterId');
    });
  }

  QueryBuilder<HadithModel, String, QQueryOperations> chapterTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterTitle');
    });
  }

  QueryBuilder<HadithModel, int, QQueryOperations> idInBookProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idInBook');
    });
  }

  QueryBuilder<HadithModel, String, QQueryOperations> normalizedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'normalizedText');
    });
  }

  QueryBuilder<HadithModel, String, QQueryOperations> textArabicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textArabic');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHadithBookModelCollection on Isar {
  IsarCollection<HadithBookModel> get hadithBookModels => this.collection();
}

const HadithBookModelSchema = CollectionSchema(
  name: r'HadithBookModel',
  id: 5289402219338488084,
  properties: {
    r'authorArabic': PropertySchema(
      id: 0,
      name: r'authorArabic',
      type: IsarType.string,
    ),
    r'authorEnglish': PropertySchema(
      id: 1,
      name: r'authorEnglish',
      type: IsarType.string,
    ),
    r'key': PropertySchema(
      id: 2,
      name: r'key',
      type: IsarType.string,
    ),
    r'nameArabic': PropertySchema(
      id: 3,
      name: r'nameArabic',
      type: IsarType.string,
    ),
    r'nameEnglish': PropertySchema(
      id: 4,
      name: r'nameEnglish',
      type: IsarType.string,
    )
  },
  estimateSize: _hadithBookModelEstimateSize,
  serialize: _hadithBookModelSerialize,
  deserialize: _hadithBookModelDeserialize,
  deserializeProp: _hadithBookModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _hadithBookModelGetId,
  getLinks: _hadithBookModelGetLinks,
  attach: _hadithBookModelAttach,
  version: '3.1.0+1',
);

int _hadithBookModelEstimateSize(
  HadithBookModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.authorArabic.length * 3;
  bytesCount += 3 + object.authorEnglish.length * 3;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.nameArabic.length * 3;
  bytesCount += 3 + object.nameEnglish.length * 3;
  return bytesCount;
}

void _hadithBookModelSerialize(
  HadithBookModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authorArabic);
  writer.writeString(offsets[1], object.authorEnglish);
  writer.writeString(offsets[2], object.key);
  writer.writeString(offsets[3], object.nameArabic);
  writer.writeString(offsets[4], object.nameEnglish);
}

HadithBookModel _hadithBookModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HadithBookModel(
    authorArabic: reader.readString(offsets[0]),
    authorEnglish: reader.readString(offsets[1]),
    key: reader.readString(offsets[2]),
    nameArabic: reader.readString(offsets[3]),
    nameEnglish: reader.readString(offsets[4]),
  );
  object.id = id;
  return object;
}

P _hadithBookModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hadithBookModelGetId(HadithBookModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hadithBookModelGetLinks(HadithBookModel object) {
  return [];
}

void _hadithBookModelAttach(
    IsarCollection<dynamic> col, Id id, HadithBookModel object) {
  object.id = id;
}

extension HadithBookModelByIndex on IsarCollection<HadithBookModel> {
  Future<HadithBookModel?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  HadithBookModel? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<HadithBookModel?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<HadithBookModel?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(HadithBookModel object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(HadithBookModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<HadithBookModel> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<HadithBookModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension HadithBookModelQueryWhereSort
    on QueryBuilder<HadithBookModel, HadithBookModel, QWhere> {
  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HadithBookModelQueryWhere
    on QueryBuilder<HadithBookModel, HadithBookModel, QWhereClause> {
  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause> keyEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterWhereClause>
      keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension HadithBookModelQueryFilter
    on QueryBuilder<HadithBookModel, HadithBookModel, QFilterCondition> {
  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorArabic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorArabic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorArabicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'authorEnglish',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'authorEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'authorEnglish',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'authorEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      authorEnglishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'authorEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameArabic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameArabic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameArabicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nameEnglish',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nameEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nameEnglish',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nameEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterFilterCondition>
      nameEnglishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nameEnglish',
        value: '',
      ));
    });
  }
}

extension HadithBookModelQueryObject
    on QueryBuilder<HadithBookModel, HadithBookModel, QFilterCondition> {}

extension HadithBookModelQueryLinks
    on QueryBuilder<HadithBookModel, HadithBookModel, QFilterCondition> {}

extension HadithBookModelQuerySortBy
    on QueryBuilder<HadithBookModel, HadithBookModel, QSortBy> {
  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByAuthorArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByAuthorArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByAuthorEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByAuthorEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorEnglish', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByNameArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByNameArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByNameEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      sortByNameEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEnglish', Sort.desc);
    });
  }
}

extension HadithBookModelQuerySortThenBy
    on QueryBuilder<HadithBookModel, HadithBookModel, QSortThenBy> {
  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByAuthorArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByAuthorArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByAuthorEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByAuthorEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authorEnglish', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByNameArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByNameArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByNameEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QAfterSortBy>
      thenByNameEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameEnglish', Sort.desc);
    });
  }
}

extension HadithBookModelQueryWhereDistinct
    on QueryBuilder<HadithBookModel, HadithBookModel, QDistinct> {
  QueryBuilder<HadithBookModel, HadithBookModel, QDistinct>
      distinctByAuthorArabic({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorArabic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QDistinct>
      distinctByAuthorEnglish({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authorEnglish',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QDistinct>
      distinctByNameArabic({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameArabic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithBookModel, HadithBookModel, QDistinct>
      distinctByNameEnglish({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameEnglish', caseSensitive: caseSensitive);
    });
  }
}

extension HadithBookModelQueryProperty
    on QueryBuilder<HadithBookModel, HadithBookModel, QQueryProperty> {
  QueryBuilder<HadithBookModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HadithBookModel, String, QQueryOperations>
      authorArabicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorArabic');
    });
  }

  QueryBuilder<HadithBookModel, String, QQueryOperations>
      authorEnglishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authorEnglish');
    });
  }

  QueryBuilder<HadithBookModel, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<HadithBookModel, String, QQueryOperations> nameArabicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameArabic');
    });
  }

  QueryBuilder<HadithBookModel, String, QQueryOperations>
      nameEnglishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameEnglish');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHadithChapterModelCollection on Isar {
  IsarCollection<HadithChapterModel> get hadithChapterModels =>
      this.collection();
}

const HadithChapterModelSchema = CollectionSchema(
  name: r'HadithChapterModel',
  id: 1912754278107920604,
  properties: {
    r'bookKey': PropertySchema(
      id: 0,
      name: r'bookKey',
      type: IsarType.string,
    ),
    r'chapterId': PropertySchema(
      id: 1,
      name: r'chapterId',
      type: IsarType.long,
    ),
    r'titleArabic': PropertySchema(
      id: 2,
      name: r'titleArabic',
      type: IsarType.string,
    ),
    r'titleEnglish': PropertySchema(
      id: 3,
      name: r'titleEnglish',
      type: IsarType.string,
    )
  },
  estimateSize: _hadithChapterModelEstimateSize,
  serialize: _hadithChapterModelSerialize,
  deserialize: _hadithChapterModelDeserialize,
  deserializeProp: _hadithChapterModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'bookKey': IndexSchema(
      id: 4514689629122669550,
      name: r'bookKey',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bookKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _hadithChapterModelGetId,
  getLinks: _hadithChapterModelGetLinks,
  attach: _hadithChapterModelAttach,
  version: '3.1.0+1',
);

int _hadithChapterModelEstimateSize(
  HadithChapterModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookKey.length * 3;
  bytesCount += 3 + object.titleArabic.length * 3;
  bytesCount += 3 + object.titleEnglish.length * 3;
  return bytesCount;
}

void _hadithChapterModelSerialize(
  HadithChapterModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bookKey);
  writer.writeLong(offsets[1], object.chapterId);
  writer.writeString(offsets[2], object.titleArabic);
  writer.writeString(offsets[3], object.titleEnglish);
}

HadithChapterModel _hadithChapterModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HadithChapterModel(
    bookKey: reader.readString(offsets[0]),
    chapterId: reader.readLong(offsets[1]),
    titleArabic: reader.readString(offsets[2]),
    titleEnglish: reader.readString(offsets[3]),
  );
  object.id = id;
  return object;
}

P _hadithChapterModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _hadithChapterModelGetId(HadithChapterModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _hadithChapterModelGetLinks(
    HadithChapterModel object) {
  return [];
}

void _hadithChapterModelAttach(
    IsarCollection<dynamic> col, Id id, HadithChapterModel object) {
  object.id = id;
}

extension HadithChapterModelQueryWhereSort
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QWhere> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HadithChapterModelQueryWhere
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QWhereClause> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      bookKeyEqualTo(String bookKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'bookKey',
        value: [bookKey],
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterWhereClause>
      bookKeyNotEqualTo(String bookKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey',
              lower: [],
              upper: [bookKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey',
              lower: [bookKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey',
              lower: [bookKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'bookKey',
              lower: [],
              upper: [bookKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension HadithChapterModelQueryFilter
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QFilterCondition> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookKey',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      bookKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookKey',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      chapterIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      chapterIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      chapterIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chapterId',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      chapterIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chapterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titleArabic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titleArabic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titleArabic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleArabicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titleArabic',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titleEnglish',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titleEnglish',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titleEnglish',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titleEnglish',
        value: '',
      ));
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterFilterCondition>
      titleEnglishIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titleEnglish',
        value: '',
      ));
    });
  }
}

extension HadithChapterModelQueryObject
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QFilterCondition> {}

extension HadithChapterModelQueryLinks
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QFilterCondition> {}

extension HadithChapterModelQuerySortBy
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QSortBy> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByBookKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByBookKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByTitleArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByTitleArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByTitleEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      sortByTitleEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleEnglish', Sort.desc);
    });
  }
}

extension HadithChapterModelQuerySortThenBy
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QSortThenBy> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByBookKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByBookKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookKey', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByChapterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chapterId', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByTitleArabic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleArabic', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByTitleArabicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleArabic', Sort.desc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByTitleEnglish() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleEnglish', Sort.asc);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QAfterSortBy>
      thenByTitleEnglishDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titleEnglish', Sort.desc);
    });
  }
}

extension HadithChapterModelQueryWhereDistinct
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QDistinct> {
  QueryBuilder<HadithChapterModel, HadithChapterModel, QDistinct>
      distinctByBookKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QDistinct>
      distinctByChapterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chapterId');
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QDistinct>
      distinctByTitleArabic({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titleArabic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HadithChapterModel, HadithChapterModel, QDistinct>
      distinctByTitleEnglish({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titleEnglish', caseSensitive: caseSensitive);
    });
  }
}

extension HadithChapterModelQueryProperty
    on QueryBuilder<HadithChapterModel, HadithChapterModel, QQueryProperty> {
  QueryBuilder<HadithChapterModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HadithChapterModel, String, QQueryOperations> bookKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookKey');
    });
  }

  QueryBuilder<HadithChapterModel, int, QQueryOperations> chapterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chapterId');
    });
  }

  QueryBuilder<HadithChapterModel, String, QQueryOperations>
      titleArabicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titleArabic');
    });
  }

  QueryBuilder<HadithChapterModel, String, QQueryOperations>
      titleEnglishProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titleEnglish');
    });
  }
}
