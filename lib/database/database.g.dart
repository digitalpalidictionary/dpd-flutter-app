// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DpdRootsTable extends DpdRoots with TableInfo<$DpdRootsTable, DpdRoot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DpdRootsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootMeta = const VerificationMeta('root');
  @override
  late final GeneratedColumn<String> root = GeneratedColumn<String>(
    'root',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootInCompsMeta = const VerificationMeta(
    'rootInComps',
  );
  @override
  late final GeneratedColumn<String> rootInComps = GeneratedColumn<String>(
    'root_in_comps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootHasVerbMeta = const VerificationMeta(
    'rootHasVerb',
  );
  @override
  late final GeneratedColumn<String> rootHasVerb = GeneratedColumn<String>(
    'root_has_verb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootGroupMeta = const VerificationMeta(
    'rootGroup',
  );
  @override
  late final GeneratedColumn<int> rootGroup = GeneratedColumn<int>(
    'root_group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootSignMeta = const VerificationMeta(
    'rootSign',
  );
  @override
  late final GeneratedColumn<String> rootSign = GeneratedColumn<String>(
    'root_sign',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootMeaningMeta = const VerificationMeta(
    'rootMeaning',
  );
  @override
  late final GeneratedColumn<String> rootMeaning = GeneratedColumn<String>(
    'root_meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanskritRootMeta = const VerificationMeta(
    'sanskritRoot',
  );
  @override
  late final GeneratedColumn<String> sanskritRoot = GeneratedColumn<String>(
    'sanskrit_root',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sanskritRootMeaningMeta =
      const VerificationMeta('sanskritRootMeaning');
  @override
  late final GeneratedColumn<String> sanskritRootMeaning =
      GeneratedColumn<String>(
        'sanskrit_root_meaning',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sanskritRootClassMeta = const VerificationMeta(
    'sanskritRootClass',
  );
  @override
  late final GeneratedColumn<String> sanskritRootClass =
      GeneratedColumn<String>(
        'sanskrit_root_class',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rootExampleMeta = const VerificationMeta(
    'rootExample',
  );
  @override
  late final GeneratedColumn<String> rootExample = GeneratedColumn<String>(
    'root_example',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootInfoMeta = const VerificationMeta(
    'rootInfo',
  );
  @override
  late final GeneratedColumn<String> rootInfo = GeneratedColumn<String>(
    'root_info',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    root,
    rootInComps,
    rootHasVerb,
    rootGroup,
    rootSign,
    rootMeaning,
    sanskritRoot,
    sanskritRootMeaning,
    sanskritRootClass,
    rootExample,
    rootInfo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dpd_roots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DpdRoot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root')) {
      context.handle(
        _rootMeta,
        root.isAcceptableOrUnknown(data['root']!, _rootMeta),
      );
    } else if (isInserting) {
      context.missing(_rootMeta);
    }
    if (data.containsKey('root_in_comps')) {
      context.handle(
        _rootInCompsMeta,
        rootInComps.isAcceptableOrUnknown(
          data['root_in_comps']!,
          _rootInCompsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootInCompsMeta);
    }
    if (data.containsKey('root_has_verb')) {
      context.handle(
        _rootHasVerbMeta,
        rootHasVerb.isAcceptableOrUnknown(
          data['root_has_verb']!,
          _rootHasVerbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootHasVerbMeta);
    }
    if (data.containsKey('root_group')) {
      context.handle(
        _rootGroupMeta,
        rootGroup.isAcceptableOrUnknown(data['root_group']!, _rootGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_rootGroupMeta);
    }
    if (data.containsKey('root_sign')) {
      context.handle(
        _rootSignMeta,
        rootSign.isAcceptableOrUnknown(data['root_sign']!, _rootSignMeta),
      );
    } else if (isInserting) {
      context.missing(_rootSignMeta);
    }
    if (data.containsKey('root_meaning')) {
      context.handle(
        _rootMeaningMeta,
        rootMeaning.isAcceptableOrUnknown(
          data['root_meaning']!,
          _rootMeaningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootMeaningMeta);
    }
    if (data.containsKey('sanskrit_root')) {
      context.handle(
        _sanskritRootMeta,
        sanskritRoot.isAcceptableOrUnknown(
          data['sanskrit_root']!,
          _sanskritRootMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sanskritRootMeta);
    }
    if (data.containsKey('sanskrit_root_meaning')) {
      context.handle(
        _sanskritRootMeaningMeta,
        sanskritRootMeaning.isAcceptableOrUnknown(
          data['sanskrit_root_meaning']!,
          _sanskritRootMeaningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sanskritRootMeaningMeta);
    }
    if (data.containsKey('sanskrit_root_class')) {
      context.handle(
        _sanskritRootClassMeta,
        sanskritRootClass.isAcceptableOrUnknown(
          data['sanskrit_root_class']!,
          _sanskritRootClassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sanskritRootClassMeta);
    }
    if (data.containsKey('root_example')) {
      context.handle(
        _rootExampleMeta,
        rootExample.isAcceptableOrUnknown(
          data['root_example']!,
          _rootExampleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootExampleMeta);
    }
    if (data.containsKey('root_info')) {
      context.handle(
        _rootInfoMeta,
        rootInfo.isAcceptableOrUnknown(data['root_info']!, _rootInfoMeta),
      );
    } else if (isInserting) {
      context.missing(_rootInfoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {root};
  @override
  DpdRoot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DpdRoot(
      root: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root'],
      )!,
      rootInComps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_in_comps'],
      )!,
      rootHasVerb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_has_verb'],
      )!,
      rootGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}root_group'],
      )!,
      rootSign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_sign'],
      )!,
      rootMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_meaning'],
      )!,
      sanskritRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanskrit_root'],
      )!,
      sanskritRootMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanskrit_root_meaning'],
      )!,
      sanskritRootClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanskrit_root_class'],
      )!,
      rootExample: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_example'],
      )!,
      rootInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_info'],
      )!,
    );
  }

  @override
  $DpdRootsTable createAlias(String alias) {
    return $DpdRootsTable(attachedDatabase, alias);
  }
}

class DpdRoot extends DataClass implements Insertable<DpdRoot> {
  final String root;
  final String rootInComps;
  final String rootHasVerb;
  final int rootGroup;
  final String rootSign;
  final String rootMeaning;
  final String sanskritRoot;
  final String sanskritRootMeaning;
  final String sanskritRootClass;
  final String rootExample;
  final String rootInfo;
  const DpdRoot({
    required this.root,
    required this.rootInComps,
    required this.rootHasVerb,
    required this.rootGroup,
    required this.rootSign,
    required this.rootMeaning,
    required this.sanskritRoot,
    required this.sanskritRootMeaning,
    required this.sanskritRootClass,
    required this.rootExample,
    required this.rootInfo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root'] = Variable<String>(root);
    map['root_in_comps'] = Variable<String>(rootInComps);
    map['root_has_verb'] = Variable<String>(rootHasVerb);
    map['root_group'] = Variable<int>(rootGroup);
    map['root_sign'] = Variable<String>(rootSign);
    map['root_meaning'] = Variable<String>(rootMeaning);
    map['sanskrit_root'] = Variable<String>(sanskritRoot);
    map['sanskrit_root_meaning'] = Variable<String>(sanskritRootMeaning);
    map['sanskrit_root_class'] = Variable<String>(sanskritRootClass);
    map['root_example'] = Variable<String>(rootExample);
    map['root_info'] = Variable<String>(rootInfo);
    return map;
  }

  DpdRootsCompanion toCompanion(bool nullToAbsent) {
    return DpdRootsCompanion(
      root: Value(root),
      rootInComps: Value(rootInComps),
      rootHasVerb: Value(rootHasVerb),
      rootGroup: Value(rootGroup),
      rootSign: Value(rootSign),
      rootMeaning: Value(rootMeaning),
      sanskritRoot: Value(sanskritRoot),
      sanskritRootMeaning: Value(sanskritRootMeaning),
      sanskritRootClass: Value(sanskritRootClass),
      rootExample: Value(rootExample),
      rootInfo: Value(rootInfo),
    );
  }

  factory DpdRoot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DpdRoot(
      root: serializer.fromJson<String>(json['root']),
      rootInComps: serializer.fromJson<String>(json['rootInComps']),
      rootHasVerb: serializer.fromJson<String>(json['rootHasVerb']),
      rootGroup: serializer.fromJson<int>(json['rootGroup']),
      rootSign: serializer.fromJson<String>(json['rootSign']),
      rootMeaning: serializer.fromJson<String>(json['rootMeaning']),
      sanskritRoot: serializer.fromJson<String>(json['sanskritRoot']),
      sanskritRootMeaning: serializer.fromJson<String>(
        json['sanskritRootMeaning'],
      ),
      sanskritRootClass: serializer.fromJson<String>(json['sanskritRootClass']),
      rootExample: serializer.fromJson<String>(json['rootExample']),
      rootInfo: serializer.fromJson<String>(json['rootInfo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'root': serializer.toJson<String>(root),
      'rootInComps': serializer.toJson<String>(rootInComps),
      'rootHasVerb': serializer.toJson<String>(rootHasVerb),
      'rootGroup': serializer.toJson<int>(rootGroup),
      'rootSign': serializer.toJson<String>(rootSign),
      'rootMeaning': serializer.toJson<String>(rootMeaning),
      'sanskritRoot': serializer.toJson<String>(sanskritRoot),
      'sanskritRootMeaning': serializer.toJson<String>(sanskritRootMeaning),
      'sanskritRootClass': serializer.toJson<String>(sanskritRootClass),
      'rootExample': serializer.toJson<String>(rootExample),
      'rootInfo': serializer.toJson<String>(rootInfo),
    };
  }

  DpdRoot copyWith({
    String? root,
    String? rootInComps,
    String? rootHasVerb,
    int? rootGroup,
    String? rootSign,
    String? rootMeaning,
    String? sanskritRoot,
    String? sanskritRootMeaning,
    String? sanskritRootClass,
    String? rootExample,
    String? rootInfo,
  }) => DpdRoot(
    root: root ?? this.root,
    rootInComps: rootInComps ?? this.rootInComps,
    rootHasVerb: rootHasVerb ?? this.rootHasVerb,
    rootGroup: rootGroup ?? this.rootGroup,
    rootSign: rootSign ?? this.rootSign,
    rootMeaning: rootMeaning ?? this.rootMeaning,
    sanskritRoot: sanskritRoot ?? this.sanskritRoot,
    sanskritRootMeaning: sanskritRootMeaning ?? this.sanskritRootMeaning,
    sanskritRootClass: sanskritRootClass ?? this.sanskritRootClass,
    rootExample: rootExample ?? this.rootExample,
    rootInfo: rootInfo ?? this.rootInfo,
  );
  DpdRoot copyWithCompanion(DpdRootsCompanion data) {
    return DpdRoot(
      root: data.root.present ? data.root.value : this.root,
      rootInComps: data.rootInComps.present
          ? data.rootInComps.value
          : this.rootInComps,
      rootHasVerb: data.rootHasVerb.present
          ? data.rootHasVerb.value
          : this.rootHasVerb,
      rootGroup: data.rootGroup.present ? data.rootGroup.value : this.rootGroup,
      rootSign: data.rootSign.present ? data.rootSign.value : this.rootSign,
      rootMeaning: data.rootMeaning.present
          ? data.rootMeaning.value
          : this.rootMeaning,
      sanskritRoot: data.sanskritRoot.present
          ? data.sanskritRoot.value
          : this.sanskritRoot,
      sanskritRootMeaning: data.sanskritRootMeaning.present
          ? data.sanskritRootMeaning.value
          : this.sanskritRootMeaning,
      sanskritRootClass: data.sanskritRootClass.present
          ? data.sanskritRootClass.value
          : this.sanskritRootClass,
      rootExample: data.rootExample.present
          ? data.rootExample.value
          : this.rootExample,
      rootInfo: data.rootInfo.present ? data.rootInfo.value : this.rootInfo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DpdRoot(')
          ..write('root: $root, ')
          ..write('rootInComps: $rootInComps, ')
          ..write('rootHasVerb: $rootHasVerb, ')
          ..write('rootGroup: $rootGroup, ')
          ..write('rootSign: $rootSign, ')
          ..write('rootMeaning: $rootMeaning, ')
          ..write('sanskritRoot: $sanskritRoot, ')
          ..write('sanskritRootMeaning: $sanskritRootMeaning, ')
          ..write('sanskritRootClass: $sanskritRootClass, ')
          ..write('rootExample: $rootExample, ')
          ..write('rootInfo: $rootInfo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    root,
    rootInComps,
    rootHasVerb,
    rootGroup,
    rootSign,
    rootMeaning,
    sanskritRoot,
    sanskritRootMeaning,
    sanskritRootClass,
    rootExample,
    rootInfo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DpdRoot &&
          other.root == this.root &&
          other.rootInComps == this.rootInComps &&
          other.rootHasVerb == this.rootHasVerb &&
          other.rootGroup == this.rootGroup &&
          other.rootSign == this.rootSign &&
          other.rootMeaning == this.rootMeaning &&
          other.sanskritRoot == this.sanskritRoot &&
          other.sanskritRootMeaning == this.sanskritRootMeaning &&
          other.sanskritRootClass == this.sanskritRootClass &&
          other.rootExample == this.rootExample &&
          other.rootInfo == this.rootInfo);
}

class DpdRootsCompanion extends UpdateCompanion<DpdRoot> {
  final Value<String> root;
  final Value<String> rootInComps;
  final Value<String> rootHasVerb;
  final Value<int> rootGroup;
  final Value<String> rootSign;
  final Value<String> rootMeaning;
  final Value<String> sanskritRoot;
  final Value<String> sanskritRootMeaning;
  final Value<String> sanskritRootClass;
  final Value<String> rootExample;
  final Value<String> rootInfo;
  final Value<int> rowid;
  const DpdRootsCompanion({
    this.root = const Value.absent(),
    this.rootInComps = const Value.absent(),
    this.rootHasVerb = const Value.absent(),
    this.rootGroup = const Value.absent(),
    this.rootSign = const Value.absent(),
    this.rootMeaning = const Value.absent(),
    this.sanskritRoot = const Value.absent(),
    this.sanskritRootMeaning = const Value.absent(),
    this.sanskritRootClass = const Value.absent(),
    this.rootExample = const Value.absent(),
    this.rootInfo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DpdRootsCompanion.insert({
    required String root,
    required String rootInComps,
    required String rootHasVerb,
    required int rootGroup,
    required String rootSign,
    required String rootMeaning,
    required String sanskritRoot,
    required String sanskritRootMeaning,
    required String sanskritRootClass,
    required String rootExample,
    required String rootInfo,
    this.rowid = const Value.absent(),
  }) : root = Value(root),
       rootInComps = Value(rootInComps),
       rootHasVerb = Value(rootHasVerb),
       rootGroup = Value(rootGroup),
       rootSign = Value(rootSign),
       rootMeaning = Value(rootMeaning),
       sanskritRoot = Value(sanskritRoot),
       sanskritRootMeaning = Value(sanskritRootMeaning),
       sanskritRootClass = Value(sanskritRootClass),
       rootExample = Value(rootExample),
       rootInfo = Value(rootInfo);
  static Insertable<DpdRoot> custom({
    Expression<String>? root,
    Expression<String>? rootInComps,
    Expression<String>? rootHasVerb,
    Expression<int>? rootGroup,
    Expression<String>? rootSign,
    Expression<String>? rootMeaning,
    Expression<String>? sanskritRoot,
    Expression<String>? sanskritRootMeaning,
    Expression<String>? sanskritRootClass,
    Expression<String>? rootExample,
    Expression<String>? rootInfo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (root != null) 'root': root,
      if (rootInComps != null) 'root_in_comps': rootInComps,
      if (rootHasVerb != null) 'root_has_verb': rootHasVerb,
      if (rootGroup != null) 'root_group': rootGroup,
      if (rootSign != null) 'root_sign': rootSign,
      if (rootMeaning != null) 'root_meaning': rootMeaning,
      if (sanskritRoot != null) 'sanskrit_root': sanskritRoot,
      if (sanskritRootMeaning != null)
        'sanskrit_root_meaning': sanskritRootMeaning,
      if (sanskritRootClass != null) 'sanskrit_root_class': sanskritRootClass,
      if (rootExample != null) 'root_example': rootExample,
      if (rootInfo != null) 'root_info': rootInfo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DpdRootsCompanion copyWith({
    Value<String>? root,
    Value<String>? rootInComps,
    Value<String>? rootHasVerb,
    Value<int>? rootGroup,
    Value<String>? rootSign,
    Value<String>? rootMeaning,
    Value<String>? sanskritRoot,
    Value<String>? sanskritRootMeaning,
    Value<String>? sanskritRootClass,
    Value<String>? rootExample,
    Value<String>? rootInfo,
    Value<int>? rowid,
  }) {
    return DpdRootsCompanion(
      root: root ?? this.root,
      rootInComps: rootInComps ?? this.rootInComps,
      rootHasVerb: rootHasVerb ?? this.rootHasVerb,
      rootGroup: rootGroup ?? this.rootGroup,
      rootSign: rootSign ?? this.rootSign,
      rootMeaning: rootMeaning ?? this.rootMeaning,
      sanskritRoot: sanskritRoot ?? this.sanskritRoot,
      sanskritRootMeaning: sanskritRootMeaning ?? this.sanskritRootMeaning,
      sanskritRootClass: sanskritRootClass ?? this.sanskritRootClass,
      rootExample: rootExample ?? this.rootExample,
      rootInfo: rootInfo ?? this.rootInfo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (root.present) {
      map['root'] = Variable<String>(root.value);
    }
    if (rootInComps.present) {
      map['root_in_comps'] = Variable<String>(rootInComps.value);
    }
    if (rootHasVerb.present) {
      map['root_has_verb'] = Variable<String>(rootHasVerb.value);
    }
    if (rootGroup.present) {
      map['root_group'] = Variable<int>(rootGroup.value);
    }
    if (rootSign.present) {
      map['root_sign'] = Variable<String>(rootSign.value);
    }
    if (rootMeaning.present) {
      map['root_meaning'] = Variable<String>(rootMeaning.value);
    }
    if (sanskritRoot.present) {
      map['sanskrit_root'] = Variable<String>(sanskritRoot.value);
    }
    if (sanskritRootMeaning.present) {
      map['sanskrit_root_meaning'] = Variable<String>(
        sanskritRootMeaning.value,
      );
    }
    if (sanskritRootClass.present) {
      map['sanskrit_root_class'] = Variable<String>(sanskritRootClass.value);
    }
    if (rootExample.present) {
      map['root_example'] = Variable<String>(rootExample.value);
    }
    if (rootInfo.present) {
      map['root_info'] = Variable<String>(rootInfo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DpdRootsCompanion(')
          ..write('root: $root, ')
          ..write('rootInComps: $rootInComps, ')
          ..write('rootHasVerb: $rootHasVerb, ')
          ..write('rootGroup: $rootGroup, ')
          ..write('rootSign: $rootSign, ')
          ..write('rootMeaning: $rootMeaning, ')
          ..write('sanskritRoot: $sanskritRoot, ')
          ..write('sanskritRootMeaning: $sanskritRootMeaning, ')
          ..write('sanskritRootClass: $sanskritRootClass, ')
          ..write('rootExample: $rootExample, ')
          ..write('rootInfo: $rootInfo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DpdHeadwordsTable extends DpdHeadwords
    with TableInfo<$DpdHeadwordsTable, DpdHeadword> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DpdHeadwordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lemma1Meta = const VerificationMeta('lemma1');
  @override
  late final GeneratedColumn<String> lemma1 = GeneratedColumn<String>(
    'lemma_1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lemma2Meta = const VerificationMeta('lemma2');
  @override
  late final GeneratedColumn<String> lemma2 = GeneratedColumn<String>(
    'lemma_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarMeta = const VerificationMeta(
    'grammar',
  );
  @override
  late final GeneratedColumn<String> grammar = GeneratedColumn<String>(
    'grammar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _derivedFromMeta = const VerificationMeta(
    'derivedFrom',
  );
  @override
  late final GeneratedColumn<String> derivedFrom = GeneratedColumn<String>(
    'derived_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _negMeta = const VerificationMeta('neg');
  @override
  late final GeneratedColumn<String> neg = GeneratedColumn<String>(
    'neg',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verbMeta = const VerificationMeta('verb');
  @override
  late final GeneratedColumn<String> verb = GeneratedColumn<String>(
    'verb',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transMeta = const VerificationMeta('trans');
  @override
  late final GeneratedColumn<String> trans = GeneratedColumn<String>(
    'trans',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plusCaseMeta = const VerificationMeta(
    'plusCase',
  );
  @override
  late final GeneratedColumn<String> plusCase = GeneratedColumn<String>(
    'plus_case',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _derivativeMeta = const VerificationMeta(
    'derivative',
  );
  @override
  late final GeneratedColumn<String> derivative = GeneratedColumn<String>(
    'derivative',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaning1Meta = const VerificationMeta(
    'meaning1',
  );
  @override
  late final GeneratedColumn<String> meaning1 = GeneratedColumn<String>(
    'meaning_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaningLitMeta = const VerificationMeta(
    'meaningLit',
  );
  @override
  late final GeneratedColumn<String> meaningLit = GeneratedColumn<String>(
    'meaning_lit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meaning2Meta = const VerificationMeta(
    'meaning2',
  );
  @override
  late final GeneratedColumn<String> meaning2 = GeneratedColumn<String>(
    'meaning_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootKeyMeta = const VerificationMeta(
    'rootKey',
  );
  @override
  late final GeneratedColumn<String> rootKey = GeneratedColumn<String>(
    'root_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dpd_roots (root)',
    ),
  );
  static const VerificationMeta _rootSignMeta = const VerificationMeta(
    'rootSign',
  );
  @override
  late final GeneratedColumn<String> rootSign = GeneratedColumn<String>(
    'root_sign',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootBaseMeta = const VerificationMeta(
    'rootBase',
  );
  @override
  late final GeneratedColumn<String> rootBase = GeneratedColumn<String>(
    'root_base',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyRootMeta = const VerificationMeta(
    'familyRoot',
  );
  @override
  late final GeneratedColumn<String> familyRoot = GeneratedColumn<String>(
    'family_root',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyWordMeta = const VerificationMeta(
    'familyWord',
  );
  @override
  late final GeneratedColumn<String> familyWord = GeneratedColumn<String>(
    'family_word',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyCompoundMeta = const VerificationMeta(
    'familyCompound',
  );
  @override
  late final GeneratedColumn<String> familyCompound = GeneratedColumn<String>(
    'family_compound',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdiomsMeta = const VerificationMeta(
    'familyIdioms',
  );
  @override
  late final GeneratedColumn<String> familyIdioms = GeneratedColumn<String>(
    'family_idioms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familySetMeta = const VerificationMeta(
    'familySet',
  );
  @override
  late final GeneratedColumn<String> familySet = GeneratedColumn<String>(
    'family_set',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _constructionMeta = const VerificationMeta(
    'construction',
  );
  @override
  late final GeneratedColumn<String> construction = GeneratedColumn<String>(
    'construction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compoundTypeMeta = const VerificationMeta(
    'compoundType',
  );
  @override
  late final GeneratedColumn<String> compoundType = GeneratedColumn<String>(
    'compound_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compoundConstructionMeta =
      const VerificationMeta('compoundConstruction');
  @override
  late final GeneratedColumn<String> compoundConstruction =
      GeneratedColumn<String>(
        'compound_construction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _source1Meta = const VerificationMeta(
    'source1',
  );
  @override
  late final GeneratedColumn<String> source1 = GeneratedColumn<String>(
    'source_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sutta1Meta = const VerificationMeta('sutta1');
  @override
  late final GeneratedColumn<String> sutta1 = GeneratedColumn<String>(
    'sutta_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _example1Meta = const VerificationMeta(
    'example1',
  );
  @override
  late final GeneratedColumn<String> example1 = GeneratedColumn<String>(
    'example_1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _source2Meta = const VerificationMeta(
    'source2',
  );
  @override
  late final GeneratedColumn<String> source2 = GeneratedColumn<String>(
    'source_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sutta2Meta = const VerificationMeta('sutta2');
  @override
  late final GeneratedColumn<String> sutta2 = GeneratedColumn<String>(
    'sutta_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _example2Meta = const VerificationMeta(
    'example2',
  );
  @override
  late final GeneratedColumn<String> example2 = GeneratedColumn<String>(
    'example_2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _antonymMeta = const VerificationMeta(
    'antonym',
  );
  @override
  late final GeneratedColumn<String> antonym = GeneratedColumn<String>(
    'antonym',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synonymMeta = const VerificationMeta(
    'synonym',
  );
  @override
  late final GeneratedColumn<String> synonym = GeneratedColumn<String>(
    'synonym',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
    'stem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suffixMeta = const VerificationMeta('suffix');
  @override
  late final GeneratedColumn<String> suffix = GeneratedColumn<String>(
    'suffix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inflectionsHtmlMeta = const VerificationMeta(
    'inflectionsHtml',
  );
  @override
  late final GeneratedColumn<String> inflectionsHtml = GeneratedColumn<String>(
    'inflections_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _freqHtmlMeta = const VerificationMeta(
    'freqHtml',
  );
  @override
  late final GeneratedColumn<String> freqHtml = GeneratedColumn<String>(
    'freq_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ebtCountMeta = const VerificationMeta(
    'ebtCount',
  );
  @override
  late final GeneratedColumn<int> ebtCount = GeneratedColumn<int>(
    'ebt_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nonIaMeta = const VerificationMeta('nonIa');
  @override
  late final GeneratedColumn<String> nonIa = GeneratedColumn<String>(
    'non_ia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sanskritMeta = const VerificationMeta(
    'sanskrit',
  );
  @override
  late final GeneratedColumn<String> sanskrit = GeneratedColumn<String>(
    'sanskrit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cognateMeta = const VerificationMeta(
    'cognate',
  );
  @override
  late final GeneratedColumn<String> cognate = GeneratedColumn<String>(
    'cognate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneticMeta = const VerificationMeta(
    'phonetic',
  );
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
    'phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _varPhoneticMeta = const VerificationMeta(
    'varPhonetic',
  );
  @override
  late final GeneratedColumn<String> varPhonetic = GeneratedColumn<String>(
    'var_phonetic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _varTextMeta = const VerificationMeta(
    'varText',
  );
  @override
  late final GeneratedColumn<String> varText = GeneratedColumn<String>(
    'var_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentaryMeta = const VerificationMeta(
    'commentary',
  );
  @override
  late final GeneratedColumn<String> commentary = GeneratedColumn<String>(
    'commentary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lemma1,
    lemma2,
    pos,
    grammar,
    derivedFrom,
    neg,
    verb,
    trans,
    plusCase,
    derivative,
    meaning1,
    meaningLit,
    meaning2,
    rootKey,
    rootSign,
    rootBase,
    familyRoot,
    familyWord,
    familyCompound,
    familyIdioms,
    familySet,
    construction,
    compoundType,
    compoundConstruction,
    source1,
    sutta1,
    example1,
    source2,
    sutta2,
    example2,
    antonym,
    synonym,
    variant,
    stem,
    pattern,
    suffix,
    inflectionsHtml,
    freqHtml,
    ebtCount,
    nonIa,
    sanskrit,
    cognate,
    link,
    phonetic,
    varPhonetic,
    varText,
    origin,
    notes,
    commentary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dpd_headwords';
  @override
  VerificationContext validateIntegrity(
    Insertable<DpdHeadword> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lemma_1')) {
      context.handle(
        _lemma1Meta,
        lemma1.isAcceptableOrUnknown(data['lemma_1']!, _lemma1Meta),
      );
    } else if (isInserting) {
      context.missing(_lemma1Meta);
    }
    if (data.containsKey('lemma_2')) {
      context.handle(
        _lemma2Meta,
        lemma2.isAcceptableOrUnknown(data['lemma_2']!, _lemma2Meta),
      );
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    if (data.containsKey('grammar')) {
      context.handle(
        _grammarMeta,
        grammar.isAcceptableOrUnknown(data['grammar']!, _grammarMeta),
      );
    }
    if (data.containsKey('derived_from')) {
      context.handle(
        _derivedFromMeta,
        derivedFrom.isAcceptableOrUnknown(
          data['derived_from']!,
          _derivedFromMeta,
        ),
      );
    }
    if (data.containsKey('neg')) {
      context.handle(
        _negMeta,
        neg.isAcceptableOrUnknown(data['neg']!, _negMeta),
      );
    }
    if (data.containsKey('verb')) {
      context.handle(
        _verbMeta,
        verb.isAcceptableOrUnknown(data['verb']!, _verbMeta),
      );
    }
    if (data.containsKey('trans')) {
      context.handle(
        _transMeta,
        trans.isAcceptableOrUnknown(data['trans']!, _transMeta),
      );
    }
    if (data.containsKey('plus_case')) {
      context.handle(
        _plusCaseMeta,
        plusCase.isAcceptableOrUnknown(data['plus_case']!, _plusCaseMeta),
      );
    }
    if (data.containsKey('derivative')) {
      context.handle(
        _derivativeMeta,
        derivative.isAcceptableOrUnknown(data['derivative']!, _derivativeMeta),
      );
    }
    if (data.containsKey('meaning_1')) {
      context.handle(
        _meaning1Meta,
        meaning1.isAcceptableOrUnknown(data['meaning_1']!, _meaning1Meta),
      );
    }
    if (data.containsKey('meaning_lit')) {
      context.handle(
        _meaningLitMeta,
        meaningLit.isAcceptableOrUnknown(data['meaning_lit']!, _meaningLitMeta),
      );
    }
    if (data.containsKey('meaning_2')) {
      context.handle(
        _meaning2Meta,
        meaning2.isAcceptableOrUnknown(data['meaning_2']!, _meaning2Meta),
      );
    }
    if (data.containsKey('root_key')) {
      context.handle(
        _rootKeyMeta,
        rootKey.isAcceptableOrUnknown(data['root_key']!, _rootKeyMeta),
      );
    }
    if (data.containsKey('root_sign')) {
      context.handle(
        _rootSignMeta,
        rootSign.isAcceptableOrUnknown(data['root_sign']!, _rootSignMeta),
      );
    }
    if (data.containsKey('root_base')) {
      context.handle(
        _rootBaseMeta,
        rootBase.isAcceptableOrUnknown(data['root_base']!, _rootBaseMeta),
      );
    }
    if (data.containsKey('family_root')) {
      context.handle(
        _familyRootMeta,
        familyRoot.isAcceptableOrUnknown(data['family_root']!, _familyRootMeta),
      );
    }
    if (data.containsKey('family_word')) {
      context.handle(
        _familyWordMeta,
        familyWord.isAcceptableOrUnknown(data['family_word']!, _familyWordMeta),
      );
    }
    if (data.containsKey('family_compound')) {
      context.handle(
        _familyCompoundMeta,
        familyCompound.isAcceptableOrUnknown(
          data['family_compound']!,
          _familyCompoundMeta,
        ),
      );
    }
    if (data.containsKey('family_idioms')) {
      context.handle(
        _familyIdiomsMeta,
        familyIdioms.isAcceptableOrUnknown(
          data['family_idioms']!,
          _familyIdiomsMeta,
        ),
      );
    }
    if (data.containsKey('family_set')) {
      context.handle(
        _familySetMeta,
        familySet.isAcceptableOrUnknown(data['family_set']!, _familySetMeta),
      );
    }
    if (data.containsKey('construction')) {
      context.handle(
        _constructionMeta,
        construction.isAcceptableOrUnknown(
          data['construction']!,
          _constructionMeta,
        ),
      );
    }
    if (data.containsKey('compound_type')) {
      context.handle(
        _compoundTypeMeta,
        compoundType.isAcceptableOrUnknown(
          data['compound_type']!,
          _compoundTypeMeta,
        ),
      );
    }
    if (data.containsKey('compound_construction')) {
      context.handle(
        _compoundConstructionMeta,
        compoundConstruction.isAcceptableOrUnknown(
          data['compound_construction']!,
          _compoundConstructionMeta,
        ),
      );
    }
    if (data.containsKey('source_1')) {
      context.handle(
        _source1Meta,
        source1.isAcceptableOrUnknown(data['source_1']!, _source1Meta),
      );
    }
    if (data.containsKey('sutta_1')) {
      context.handle(
        _sutta1Meta,
        sutta1.isAcceptableOrUnknown(data['sutta_1']!, _sutta1Meta),
      );
    }
    if (data.containsKey('example_1')) {
      context.handle(
        _example1Meta,
        example1.isAcceptableOrUnknown(data['example_1']!, _example1Meta),
      );
    }
    if (data.containsKey('source_2')) {
      context.handle(
        _source2Meta,
        source2.isAcceptableOrUnknown(data['source_2']!, _source2Meta),
      );
    }
    if (data.containsKey('sutta_2')) {
      context.handle(
        _sutta2Meta,
        sutta2.isAcceptableOrUnknown(data['sutta_2']!, _sutta2Meta),
      );
    }
    if (data.containsKey('example_2')) {
      context.handle(
        _example2Meta,
        example2.isAcceptableOrUnknown(data['example_2']!, _example2Meta),
      );
    }
    if (data.containsKey('antonym')) {
      context.handle(
        _antonymMeta,
        antonym.isAcceptableOrUnknown(data['antonym']!, _antonymMeta),
      );
    }
    if (data.containsKey('synonym')) {
      context.handle(
        _synonymMeta,
        synonym.isAcceptableOrUnknown(data['synonym']!, _synonymMeta),
      );
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('stem')) {
      context.handle(
        _stemMeta,
        stem.isAcceptableOrUnknown(data['stem']!, _stemMeta),
      );
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    }
    if (data.containsKey('suffix')) {
      context.handle(
        _suffixMeta,
        suffix.isAcceptableOrUnknown(data['suffix']!, _suffixMeta),
      );
    }
    if (data.containsKey('inflections_html')) {
      context.handle(
        _inflectionsHtmlMeta,
        inflectionsHtml.isAcceptableOrUnknown(
          data['inflections_html']!,
          _inflectionsHtmlMeta,
        ),
      );
    }
    if (data.containsKey('freq_html')) {
      context.handle(
        _freqHtmlMeta,
        freqHtml.isAcceptableOrUnknown(data['freq_html']!, _freqHtmlMeta),
      );
    }
    if (data.containsKey('ebt_count')) {
      context.handle(
        _ebtCountMeta,
        ebtCount.isAcceptableOrUnknown(data['ebt_count']!, _ebtCountMeta),
      );
    }
    if (data.containsKey('non_ia')) {
      context.handle(
        _nonIaMeta,
        nonIa.isAcceptableOrUnknown(data['non_ia']!, _nonIaMeta),
      );
    }
    if (data.containsKey('sanskrit')) {
      context.handle(
        _sanskritMeta,
        sanskrit.isAcceptableOrUnknown(data['sanskrit']!, _sanskritMeta),
      );
    }
    if (data.containsKey('cognate')) {
      context.handle(
        _cognateMeta,
        cognate.isAcceptableOrUnknown(data['cognate']!, _cognateMeta),
      );
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    }
    if (data.containsKey('phonetic')) {
      context.handle(
        _phoneticMeta,
        phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta),
      );
    }
    if (data.containsKey('var_phonetic')) {
      context.handle(
        _varPhoneticMeta,
        varPhonetic.isAcceptableOrUnknown(
          data['var_phonetic']!,
          _varPhoneticMeta,
        ),
      );
    }
    if (data.containsKey('var_text')) {
      context.handle(
        _varTextMeta,
        varText.isAcceptableOrUnknown(data['var_text']!, _varTextMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('commentary')) {
      context.handle(
        _commentaryMeta,
        commentary.isAcceptableOrUnknown(data['commentary']!, _commentaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DpdHeadword map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DpdHeadword(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lemma1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma_1'],
      )!,
      lemma2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma_2'],
      ),
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      ),
      grammar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar'],
      ),
      derivedFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derived_from'],
      ),
      neg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}neg'],
      ),
      verb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verb'],
      ),
      trans: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trans'],
      ),
      plusCase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plus_case'],
      ),
      derivative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derivative'],
      ),
      meaning1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_1'],
      ),
      meaningLit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_lit'],
      ),
      meaning2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning_2'],
      ),
      rootKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_key'],
      ),
      rootSign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_sign'],
      ),
      rootBase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_base'],
      ),
      familyRoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_root'],
      ),
      familyWord: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_word'],
      ),
      familyCompound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_compound'],
      ),
      familyIdioms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_idioms'],
      ),
      familySet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_set'],
      ),
      construction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}construction'],
      ),
      compoundType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_type'],
      ),
      compoundConstruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_construction'],
      ),
      source1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_1'],
      ),
      sutta1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sutta_1'],
      ),
      example1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_1'],
      ),
      source2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_2'],
      ),
      sutta2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sutta_2'],
      ),
      example2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_2'],
      ),
      antonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}antonym'],
      ),
      synonym: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synonym'],
      ),
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      stem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stem'],
      ),
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      ),
      suffix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suffix'],
      ),
      inflectionsHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inflections_html'],
      ),
      freqHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}freq_html'],
      ),
      ebtCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ebt_count'],
      ),
      nonIa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}non_ia'],
      ),
      sanskrit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sanskrit'],
      ),
      cognate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cognate'],
      ),
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      ),
      phonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phonetic'],
      ),
      varPhonetic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}var_phonetic'],
      ),
      varText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}var_text'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      commentary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commentary'],
      ),
    );
  }

  @override
  $DpdHeadwordsTable createAlias(String alias) {
    return $DpdHeadwordsTable(attachedDatabase, alias);
  }
}

class DpdHeadword extends DataClass implements Insertable<DpdHeadword> {
  final int id;
  final String lemma1;
  final String? lemma2;
  final String? pos;
  final String? grammar;
  final String? derivedFrom;
  final String? neg;
  final String? verb;
  final String? trans;
  final String? plusCase;
  final String? derivative;
  final String? meaning1;
  final String? meaningLit;
  final String? meaning2;
  final String? rootKey;
  final String? rootSign;
  final String? rootBase;
  final String? familyRoot;
  final String? familyWord;
  final String? familyCompound;
  final String? familyIdioms;
  final String? familySet;
  final String? construction;
  final String? compoundType;
  final String? compoundConstruction;
  final String? source1;
  final String? sutta1;
  final String? example1;
  final String? source2;
  final String? sutta2;
  final String? example2;
  final String? antonym;
  final String? synonym;
  final String? variant;
  final String? stem;
  final String? pattern;
  final String? suffix;
  final String? inflectionsHtml;
  final String? freqHtml;
  final int? ebtCount;
  final String? nonIa;
  final String? sanskrit;
  final String? cognate;
  final String? link;
  final String? phonetic;
  final String? varPhonetic;
  final String? varText;
  final String? origin;
  final String? notes;
  final String? commentary;
  const DpdHeadword({
    required this.id,
    required this.lemma1,
    this.lemma2,
    this.pos,
    this.grammar,
    this.derivedFrom,
    this.neg,
    this.verb,
    this.trans,
    this.plusCase,
    this.derivative,
    this.meaning1,
    this.meaningLit,
    this.meaning2,
    this.rootKey,
    this.rootSign,
    this.rootBase,
    this.familyRoot,
    this.familyWord,
    this.familyCompound,
    this.familyIdioms,
    this.familySet,
    this.construction,
    this.compoundType,
    this.compoundConstruction,
    this.source1,
    this.sutta1,
    this.example1,
    this.source2,
    this.sutta2,
    this.example2,
    this.antonym,
    this.synonym,
    this.variant,
    this.stem,
    this.pattern,
    this.suffix,
    this.inflectionsHtml,
    this.freqHtml,
    this.ebtCount,
    this.nonIa,
    this.sanskrit,
    this.cognate,
    this.link,
    this.phonetic,
    this.varPhonetic,
    this.varText,
    this.origin,
    this.notes,
    this.commentary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lemma_1'] = Variable<String>(lemma1);
    if (!nullToAbsent || lemma2 != null) {
      map['lemma_2'] = Variable<String>(lemma2);
    }
    if (!nullToAbsent || pos != null) {
      map['pos'] = Variable<String>(pos);
    }
    if (!nullToAbsent || grammar != null) {
      map['grammar'] = Variable<String>(grammar);
    }
    if (!nullToAbsent || derivedFrom != null) {
      map['derived_from'] = Variable<String>(derivedFrom);
    }
    if (!nullToAbsent || neg != null) {
      map['neg'] = Variable<String>(neg);
    }
    if (!nullToAbsent || verb != null) {
      map['verb'] = Variable<String>(verb);
    }
    if (!nullToAbsent || trans != null) {
      map['trans'] = Variable<String>(trans);
    }
    if (!nullToAbsent || plusCase != null) {
      map['plus_case'] = Variable<String>(plusCase);
    }
    if (!nullToAbsent || derivative != null) {
      map['derivative'] = Variable<String>(derivative);
    }
    if (!nullToAbsent || meaning1 != null) {
      map['meaning_1'] = Variable<String>(meaning1);
    }
    if (!nullToAbsent || meaningLit != null) {
      map['meaning_lit'] = Variable<String>(meaningLit);
    }
    if (!nullToAbsent || meaning2 != null) {
      map['meaning_2'] = Variable<String>(meaning2);
    }
    if (!nullToAbsent || rootKey != null) {
      map['root_key'] = Variable<String>(rootKey);
    }
    if (!nullToAbsent || rootSign != null) {
      map['root_sign'] = Variable<String>(rootSign);
    }
    if (!nullToAbsent || rootBase != null) {
      map['root_base'] = Variable<String>(rootBase);
    }
    if (!nullToAbsent || familyRoot != null) {
      map['family_root'] = Variable<String>(familyRoot);
    }
    if (!nullToAbsent || familyWord != null) {
      map['family_word'] = Variable<String>(familyWord);
    }
    if (!nullToAbsent || familyCompound != null) {
      map['family_compound'] = Variable<String>(familyCompound);
    }
    if (!nullToAbsent || familyIdioms != null) {
      map['family_idioms'] = Variable<String>(familyIdioms);
    }
    if (!nullToAbsent || familySet != null) {
      map['family_set'] = Variable<String>(familySet);
    }
    if (!nullToAbsent || construction != null) {
      map['construction'] = Variable<String>(construction);
    }
    if (!nullToAbsent || compoundType != null) {
      map['compound_type'] = Variable<String>(compoundType);
    }
    if (!nullToAbsent || compoundConstruction != null) {
      map['compound_construction'] = Variable<String>(compoundConstruction);
    }
    if (!nullToAbsent || source1 != null) {
      map['source_1'] = Variable<String>(source1);
    }
    if (!nullToAbsent || sutta1 != null) {
      map['sutta_1'] = Variable<String>(sutta1);
    }
    if (!nullToAbsent || example1 != null) {
      map['example_1'] = Variable<String>(example1);
    }
    if (!nullToAbsent || source2 != null) {
      map['source_2'] = Variable<String>(source2);
    }
    if (!nullToAbsent || sutta2 != null) {
      map['sutta_2'] = Variable<String>(sutta2);
    }
    if (!nullToAbsent || example2 != null) {
      map['example_2'] = Variable<String>(example2);
    }
    if (!nullToAbsent || antonym != null) {
      map['antonym'] = Variable<String>(antonym);
    }
    if (!nullToAbsent || synonym != null) {
      map['synonym'] = Variable<String>(synonym);
    }
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    if (!nullToAbsent || stem != null) {
      map['stem'] = Variable<String>(stem);
    }
    if (!nullToAbsent || pattern != null) {
      map['pattern'] = Variable<String>(pattern);
    }
    if (!nullToAbsent || suffix != null) {
      map['suffix'] = Variable<String>(suffix);
    }
    if (!nullToAbsent || inflectionsHtml != null) {
      map['inflections_html'] = Variable<String>(inflectionsHtml);
    }
    if (!nullToAbsent || freqHtml != null) {
      map['freq_html'] = Variable<String>(freqHtml);
    }
    if (!nullToAbsent || ebtCount != null) {
      map['ebt_count'] = Variable<int>(ebtCount);
    }
    if (!nullToAbsent || nonIa != null) {
      map['non_ia'] = Variable<String>(nonIa);
    }
    if (!nullToAbsent || sanskrit != null) {
      map['sanskrit'] = Variable<String>(sanskrit);
    }
    if (!nullToAbsent || cognate != null) {
      map['cognate'] = Variable<String>(cognate);
    }
    if (!nullToAbsent || link != null) {
      map['link'] = Variable<String>(link);
    }
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    if (!nullToAbsent || varPhonetic != null) {
      map['var_phonetic'] = Variable<String>(varPhonetic);
    }
    if (!nullToAbsent || varText != null) {
      map['var_text'] = Variable<String>(varText);
    }
    if (!nullToAbsent || origin != null) {
      map['origin'] = Variable<String>(origin);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || commentary != null) {
      map['commentary'] = Variable<String>(commentary);
    }
    return map;
  }

  DpdHeadwordsCompanion toCompanion(bool nullToAbsent) {
    return DpdHeadwordsCompanion(
      id: Value(id),
      lemma1: Value(lemma1),
      lemma2: lemma2 == null && nullToAbsent
          ? const Value.absent()
          : Value(lemma2),
      pos: pos == null && nullToAbsent ? const Value.absent() : Value(pos),
      grammar: grammar == null && nullToAbsent
          ? const Value.absent()
          : Value(grammar),
      derivedFrom: derivedFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(derivedFrom),
      neg: neg == null && nullToAbsent ? const Value.absent() : Value(neg),
      verb: verb == null && nullToAbsent ? const Value.absent() : Value(verb),
      trans: trans == null && nullToAbsent
          ? const Value.absent()
          : Value(trans),
      plusCase: plusCase == null && nullToAbsent
          ? const Value.absent()
          : Value(plusCase),
      derivative: derivative == null && nullToAbsent
          ? const Value.absent()
          : Value(derivative),
      meaning1: meaning1 == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning1),
      meaningLit: meaningLit == null && nullToAbsent
          ? const Value.absent()
          : Value(meaningLit),
      meaning2: meaning2 == null && nullToAbsent
          ? const Value.absent()
          : Value(meaning2),
      rootKey: rootKey == null && nullToAbsent
          ? const Value.absent()
          : Value(rootKey),
      rootSign: rootSign == null && nullToAbsent
          ? const Value.absent()
          : Value(rootSign),
      rootBase: rootBase == null && nullToAbsent
          ? const Value.absent()
          : Value(rootBase),
      familyRoot: familyRoot == null && nullToAbsent
          ? const Value.absent()
          : Value(familyRoot),
      familyWord: familyWord == null && nullToAbsent
          ? const Value.absent()
          : Value(familyWord),
      familyCompound: familyCompound == null && nullToAbsent
          ? const Value.absent()
          : Value(familyCompound),
      familyIdioms: familyIdioms == null && nullToAbsent
          ? const Value.absent()
          : Value(familyIdioms),
      familySet: familySet == null && nullToAbsent
          ? const Value.absent()
          : Value(familySet),
      construction: construction == null && nullToAbsent
          ? const Value.absent()
          : Value(construction),
      compoundType: compoundType == null && nullToAbsent
          ? const Value.absent()
          : Value(compoundType),
      compoundConstruction: compoundConstruction == null && nullToAbsent
          ? const Value.absent()
          : Value(compoundConstruction),
      source1: source1 == null && nullToAbsent
          ? const Value.absent()
          : Value(source1),
      sutta1: sutta1 == null && nullToAbsent
          ? const Value.absent()
          : Value(sutta1),
      example1: example1 == null && nullToAbsent
          ? const Value.absent()
          : Value(example1),
      source2: source2 == null && nullToAbsent
          ? const Value.absent()
          : Value(source2),
      sutta2: sutta2 == null && nullToAbsent
          ? const Value.absent()
          : Value(sutta2),
      example2: example2 == null && nullToAbsent
          ? const Value.absent()
          : Value(example2),
      antonym: antonym == null && nullToAbsent
          ? const Value.absent()
          : Value(antonym),
      synonym: synonym == null && nullToAbsent
          ? const Value.absent()
          : Value(synonym),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      stem: stem == null && nullToAbsent ? const Value.absent() : Value(stem),
      pattern: pattern == null && nullToAbsent
          ? const Value.absent()
          : Value(pattern),
      suffix: suffix == null && nullToAbsent
          ? const Value.absent()
          : Value(suffix),
      inflectionsHtml: inflectionsHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(inflectionsHtml),
      freqHtml: freqHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(freqHtml),
      ebtCount: ebtCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ebtCount),
      nonIa: nonIa == null && nullToAbsent
          ? const Value.absent()
          : Value(nonIa),
      sanskrit: sanskrit == null && nullToAbsent
          ? const Value.absent()
          : Value(sanskrit),
      cognate: cognate == null && nullToAbsent
          ? const Value.absent()
          : Value(cognate),
      link: link == null && nullToAbsent ? const Value.absent() : Value(link),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      varPhonetic: varPhonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(varPhonetic),
      varText: varText == null && nullToAbsent
          ? const Value.absent()
          : Value(varText),
      origin: origin == null && nullToAbsent
          ? const Value.absent()
          : Value(origin),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      commentary: commentary == null && nullToAbsent
          ? const Value.absent()
          : Value(commentary),
    );
  }

  factory DpdHeadword.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DpdHeadword(
      id: serializer.fromJson<int>(json['id']),
      lemma1: serializer.fromJson<String>(json['lemma1']),
      lemma2: serializer.fromJson<String?>(json['lemma2']),
      pos: serializer.fromJson<String?>(json['pos']),
      grammar: serializer.fromJson<String?>(json['grammar']),
      derivedFrom: serializer.fromJson<String?>(json['derivedFrom']),
      neg: serializer.fromJson<String?>(json['neg']),
      verb: serializer.fromJson<String?>(json['verb']),
      trans: serializer.fromJson<String?>(json['trans']),
      plusCase: serializer.fromJson<String?>(json['plusCase']),
      derivative: serializer.fromJson<String?>(json['derivative']),
      meaning1: serializer.fromJson<String?>(json['meaning1']),
      meaningLit: serializer.fromJson<String?>(json['meaningLit']),
      meaning2: serializer.fromJson<String?>(json['meaning2']),
      rootKey: serializer.fromJson<String?>(json['rootKey']),
      rootSign: serializer.fromJson<String?>(json['rootSign']),
      rootBase: serializer.fromJson<String?>(json['rootBase']),
      familyRoot: serializer.fromJson<String?>(json['familyRoot']),
      familyWord: serializer.fromJson<String?>(json['familyWord']),
      familyCompound: serializer.fromJson<String?>(json['familyCompound']),
      familyIdioms: serializer.fromJson<String?>(json['familyIdioms']),
      familySet: serializer.fromJson<String?>(json['familySet']),
      construction: serializer.fromJson<String?>(json['construction']),
      compoundType: serializer.fromJson<String?>(json['compoundType']),
      compoundConstruction: serializer.fromJson<String?>(
        json['compoundConstruction'],
      ),
      source1: serializer.fromJson<String?>(json['source1']),
      sutta1: serializer.fromJson<String?>(json['sutta1']),
      example1: serializer.fromJson<String?>(json['example1']),
      source2: serializer.fromJson<String?>(json['source2']),
      sutta2: serializer.fromJson<String?>(json['sutta2']),
      example2: serializer.fromJson<String?>(json['example2']),
      antonym: serializer.fromJson<String?>(json['antonym']),
      synonym: serializer.fromJson<String?>(json['synonym']),
      variant: serializer.fromJson<String?>(json['variant']),
      stem: serializer.fromJson<String?>(json['stem']),
      pattern: serializer.fromJson<String?>(json['pattern']),
      suffix: serializer.fromJson<String?>(json['suffix']),
      inflectionsHtml: serializer.fromJson<String?>(json['inflectionsHtml']),
      freqHtml: serializer.fromJson<String?>(json['freqHtml']),
      ebtCount: serializer.fromJson<int?>(json['ebtCount']),
      nonIa: serializer.fromJson<String?>(json['nonIa']),
      sanskrit: serializer.fromJson<String?>(json['sanskrit']),
      cognate: serializer.fromJson<String?>(json['cognate']),
      link: serializer.fromJson<String?>(json['link']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      varPhonetic: serializer.fromJson<String?>(json['varPhonetic']),
      varText: serializer.fromJson<String?>(json['varText']),
      origin: serializer.fromJson<String?>(json['origin']),
      notes: serializer.fromJson<String?>(json['notes']),
      commentary: serializer.fromJson<String?>(json['commentary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lemma1': serializer.toJson<String>(lemma1),
      'lemma2': serializer.toJson<String?>(lemma2),
      'pos': serializer.toJson<String?>(pos),
      'grammar': serializer.toJson<String?>(grammar),
      'derivedFrom': serializer.toJson<String?>(derivedFrom),
      'neg': serializer.toJson<String?>(neg),
      'verb': serializer.toJson<String?>(verb),
      'trans': serializer.toJson<String?>(trans),
      'plusCase': serializer.toJson<String?>(plusCase),
      'derivative': serializer.toJson<String?>(derivative),
      'meaning1': serializer.toJson<String?>(meaning1),
      'meaningLit': serializer.toJson<String?>(meaningLit),
      'meaning2': serializer.toJson<String?>(meaning2),
      'rootKey': serializer.toJson<String?>(rootKey),
      'rootSign': serializer.toJson<String?>(rootSign),
      'rootBase': serializer.toJson<String?>(rootBase),
      'familyRoot': serializer.toJson<String?>(familyRoot),
      'familyWord': serializer.toJson<String?>(familyWord),
      'familyCompound': serializer.toJson<String?>(familyCompound),
      'familyIdioms': serializer.toJson<String?>(familyIdioms),
      'familySet': serializer.toJson<String?>(familySet),
      'construction': serializer.toJson<String?>(construction),
      'compoundType': serializer.toJson<String?>(compoundType),
      'compoundConstruction': serializer.toJson<String?>(compoundConstruction),
      'source1': serializer.toJson<String?>(source1),
      'sutta1': serializer.toJson<String?>(sutta1),
      'example1': serializer.toJson<String?>(example1),
      'source2': serializer.toJson<String?>(source2),
      'sutta2': serializer.toJson<String?>(sutta2),
      'example2': serializer.toJson<String?>(example2),
      'antonym': serializer.toJson<String?>(antonym),
      'synonym': serializer.toJson<String?>(synonym),
      'variant': serializer.toJson<String?>(variant),
      'stem': serializer.toJson<String?>(stem),
      'pattern': serializer.toJson<String?>(pattern),
      'suffix': serializer.toJson<String?>(suffix),
      'inflectionsHtml': serializer.toJson<String?>(inflectionsHtml),
      'freqHtml': serializer.toJson<String?>(freqHtml),
      'ebtCount': serializer.toJson<int?>(ebtCount),
      'nonIa': serializer.toJson<String?>(nonIa),
      'sanskrit': serializer.toJson<String?>(sanskrit),
      'cognate': serializer.toJson<String?>(cognate),
      'link': serializer.toJson<String?>(link),
      'phonetic': serializer.toJson<String?>(phonetic),
      'varPhonetic': serializer.toJson<String?>(varPhonetic),
      'varText': serializer.toJson<String?>(varText),
      'origin': serializer.toJson<String?>(origin),
      'notes': serializer.toJson<String?>(notes),
      'commentary': serializer.toJson<String?>(commentary),
    };
  }

  DpdHeadword copyWith({
    int? id,
    String? lemma1,
    Value<String?> lemma2 = const Value.absent(),
    Value<String?> pos = const Value.absent(),
    Value<String?> grammar = const Value.absent(),
    Value<String?> derivedFrom = const Value.absent(),
    Value<String?> neg = const Value.absent(),
    Value<String?> verb = const Value.absent(),
    Value<String?> trans = const Value.absent(),
    Value<String?> plusCase = const Value.absent(),
    Value<String?> derivative = const Value.absent(),
    Value<String?> meaning1 = const Value.absent(),
    Value<String?> meaningLit = const Value.absent(),
    Value<String?> meaning2 = const Value.absent(),
    Value<String?> rootKey = const Value.absent(),
    Value<String?> rootSign = const Value.absent(),
    Value<String?> rootBase = const Value.absent(),
    Value<String?> familyRoot = const Value.absent(),
    Value<String?> familyWord = const Value.absent(),
    Value<String?> familyCompound = const Value.absent(),
    Value<String?> familyIdioms = const Value.absent(),
    Value<String?> familySet = const Value.absent(),
    Value<String?> construction = const Value.absent(),
    Value<String?> compoundType = const Value.absent(),
    Value<String?> compoundConstruction = const Value.absent(),
    Value<String?> source1 = const Value.absent(),
    Value<String?> sutta1 = const Value.absent(),
    Value<String?> example1 = const Value.absent(),
    Value<String?> source2 = const Value.absent(),
    Value<String?> sutta2 = const Value.absent(),
    Value<String?> example2 = const Value.absent(),
    Value<String?> antonym = const Value.absent(),
    Value<String?> synonym = const Value.absent(),
    Value<String?> variant = const Value.absent(),
    Value<String?> stem = const Value.absent(),
    Value<String?> pattern = const Value.absent(),
    Value<String?> suffix = const Value.absent(),
    Value<String?> inflectionsHtml = const Value.absent(),
    Value<String?> freqHtml = const Value.absent(),
    Value<int?> ebtCount = const Value.absent(),
    Value<String?> nonIa = const Value.absent(),
    Value<String?> sanskrit = const Value.absent(),
    Value<String?> cognate = const Value.absent(),
    Value<String?> link = const Value.absent(),
    Value<String?> phonetic = const Value.absent(),
    Value<String?> varPhonetic = const Value.absent(),
    Value<String?> varText = const Value.absent(),
    Value<String?> origin = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> commentary = const Value.absent(),
  }) => DpdHeadword(
    id: id ?? this.id,
    lemma1: lemma1 ?? this.lemma1,
    lemma2: lemma2.present ? lemma2.value : this.lemma2,
    pos: pos.present ? pos.value : this.pos,
    grammar: grammar.present ? grammar.value : this.grammar,
    derivedFrom: derivedFrom.present ? derivedFrom.value : this.derivedFrom,
    neg: neg.present ? neg.value : this.neg,
    verb: verb.present ? verb.value : this.verb,
    trans: trans.present ? trans.value : this.trans,
    plusCase: plusCase.present ? plusCase.value : this.plusCase,
    derivative: derivative.present ? derivative.value : this.derivative,
    meaning1: meaning1.present ? meaning1.value : this.meaning1,
    meaningLit: meaningLit.present ? meaningLit.value : this.meaningLit,
    meaning2: meaning2.present ? meaning2.value : this.meaning2,
    rootKey: rootKey.present ? rootKey.value : this.rootKey,
    rootSign: rootSign.present ? rootSign.value : this.rootSign,
    rootBase: rootBase.present ? rootBase.value : this.rootBase,
    familyRoot: familyRoot.present ? familyRoot.value : this.familyRoot,
    familyWord: familyWord.present ? familyWord.value : this.familyWord,
    familyCompound: familyCompound.present
        ? familyCompound.value
        : this.familyCompound,
    familyIdioms: familyIdioms.present ? familyIdioms.value : this.familyIdioms,
    familySet: familySet.present ? familySet.value : this.familySet,
    construction: construction.present ? construction.value : this.construction,
    compoundType: compoundType.present ? compoundType.value : this.compoundType,
    compoundConstruction: compoundConstruction.present
        ? compoundConstruction.value
        : this.compoundConstruction,
    source1: source1.present ? source1.value : this.source1,
    sutta1: sutta1.present ? sutta1.value : this.sutta1,
    example1: example1.present ? example1.value : this.example1,
    source2: source2.present ? source2.value : this.source2,
    sutta2: sutta2.present ? sutta2.value : this.sutta2,
    example2: example2.present ? example2.value : this.example2,
    antonym: antonym.present ? antonym.value : this.antonym,
    synonym: synonym.present ? synonym.value : this.synonym,
    variant: variant.present ? variant.value : this.variant,
    stem: stem.present ? stem.value : this.stem,
    pattern: pattern.present ? pattern.value : this.pattern,
    suffix: suffix.present ? suffix.value : this.suffix,
    inflectionsHtml: inflectionsHtml.present
        ? inflectionsHtml.value
        : this.inflectionsHtml,
    freqHtml: freqHtml.present ? freqHtml.value : this.freqHtml,
    ebtCount: ebtCount.present ? ebtCount.value : this.ebtCount,
    nonIa: nonIa.present ? nonIa.value : this.nonIa,
    sanskrit: sanskrit.present ? sanskrit.value : this.sanskrit,
    cognate: cognate.present ? cognate.value : this.cognate,
    link: link.present ? link.value : this.link,
    phonetic: phonetic.present ? phonetic.value : this.phonetic,
    varPhonetic: varPhonetic.present ? varPhonetic.value : this.varPhonetic,
    varText: varText.present ? varText.value : this.varText,
    origin: origin.present ? origin.value : this.origin,
    notes: notes.present ? notes.value : this.notes,
    commentary: commentary.present ? commentary.value : this.commentary,
  );
  DpdHeadword copyWithCompanion(DpdHeadwordsCompanion data) {
    return DpdHeadword(
      id: data.id.present ? data.id.value : this.id,
      lemma1: data.lemma1.present ? data.lemma1.value : this.lemma1,
      lemma2: data.lemma2.present ? data.lemma2.value : this.lemma2,
      pos: data.pos.present ? data.pos.value : this.pos,
      grammar: data.grammar.present ? data.grammar.value : this.grammar,
      derivedFrom: data.derivedFrom.present
          ? data.derivedFrom.value
          : this.derivedFrom,
      neg: data.neg.present ? data.neg.value : this.neg,
      verb: data.verb.present ? data.verb.value : this.verb,
      trans: data.trans.present ? data.trans.value : this.trans,
      plusCase: data.plusCase.present ? data.plusCase.value : this.plusCase,
      derivative: data.derivative.present
          ? data.derivative.value
          : this.derivative,
      meaning1: data.meaning1.present ? data.meaning1.value : this.meaning1,
      meaningLit: data.meaningLit.present
          ? data.meaningLit.value
          : this.meaningLit,
      meaning2: data.meaning2.present ? data.meaning2.value : this.meaning2,
      rootKey: data.rootKey.present ? data.rootKey.value : this.rootKey,
      rootSign: data.rootSign.present ? data.rootSign.value : this.rootSign,
      rootBase: data.rootBase.present ? data.rootBase.value : this.rootBase,
      familyRoot: data.familyRoot.present
          ? data.familyRoot.value
          : this.familyRoot,
      familyWord: data.familyWord.present
          ? data.familyWord.value
          : this.familyWord,
      familyCompound: data.familyCompound.present
          ? data.familyCompound.value
          : this.familyCompound,
      familyIdioms: data.familyIdioms.present
          ? data.familyIdioms.value
          : this.familyIdioms,
      familySet: data.familySet.present ? data.familySet.value : this.familySet,
      construction: data.construction.present
          ? data.construction.value
          : this.construction,
      compoundType: data.compoundType.present
          ? data.compoundType.value
          : this.compoundType,
      compoundConstruction: data.compoundConstruction.present
          ? data.compoundConstruction.value
          : this.compoundConstruction,
      source1: data.source1.present ? data.source1.value : this.source1,
      sutta1: data.sutta1.present ? data.sutta1.value : this.sutta1,
      example1: data.example1.present ? data.example1.value : this.example1,
      source2: data.source2.present ? data.source2.value : this.source2,
      sutta2: data.sutta2.present ? data.sutta2.value : this.sutta2,
      example2: data.example2.present ? data.example2.value : this.example2,
      antonym: data.antonym.present ? data.antonym.value : this.antonym,
      synonym: data.synonym.present ? data.synonym.value : this.synonym,
      variant: data.variant.present ? data.variant.value : this.variant,
      stem: data.stem.present ? data.stem.value : this.stem,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      suffix: data.suffix.present ? data.suffix.value : this.suffix,
      inflectionsHtml: data.inflectionsHtml.present
          ? data.inflectionsHtml.value
          : this.inflectionsHtml,
      freqHtml: data.freqHtml.present ? data.freqHtml.value : this.freqHtml,
      ebtCount: data.ebtCount.present ? data.ebtCount.value : this.ebtCount,
      nonIa: data.nonIa.present ? data.nonIa.value : this.nonIa,
      sanskrit: data.sanskrit.present ? data.sanskrit.value : this.sanskrit,
      cognate: data.cognate.present ? data.cognate.value : this.cognate,
      link: data.link.present ? data.link.value : this.link,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      varPhonetic: data.varPhonetic.present
          ? data.varPhonetic.value
          : this.varPhonetic,
      varText: data.varText.present ? data.varText.value : this.varText,
      origin: data.origin.present ? data.origin.value : this.origin,
      notes: data.notes.present ? data.notes.value : this.notes,
      commentary: data.commentary.present
          ? data.commentary.value
          : this.commentary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DpdHeadword(')
          ..write('id: $id, ')
          ..write('lemma1: $lemma1, ')
          ..write('lemma2: $lemma2, ')
          ..write('pos: $pos, ')
          ..write('grammar: $grammar, ')
          ..write('derivedFrom: $derivedFrom, ')
          ..write('neg: $neg, ')
          ..write('verb: $verb, ')
          ..write('trans: $trans, ')
          ..write('plusCase: $plusCase, ')
          ..write('derivative: $derivative, ')
          ..write('meaning1: $meaning1, ')
          ..write('meaningLit: $meaningLit, ')
          ..write('meaning2: $meaning2, ')
          ..write('rootKey: $rootKey, ')
          ..write('rootSign: $rootSign, ')
          ..write('rootBase: $rootBase, ')
          ..write('familyRoot: $familyRoot, ')
          ..write('familyWord: $familyWord, ')
          ..write('familyCompound: $familyCompound, ')
          ..write('familyIdioms: $familyIdioms, ')
          ..write('familySet: $familySet, ')
          ..write('construction: $construction, ')
          ..write('compoundType: $compoundType, ')
          ..write('compoundConstruction: $compoundConstruction, ')
          ..write('source1: $source1, ')
          ..write('sutta1: $sutta1, ')
          ..write('example1: $example1, ')
          ..write('source2: $source2, ')
          ..write('sutta2: $sutta2, ')
          ..write('example2: $example2, ')
          ..write('antonym: $antonym, ')
          ..write('synonym: $synonym, ')
          ..write('variant: $variant, ')
          ..write('stem: $stem, ')
          ..write('pattern: $pattern, ')
          ..write('suffix: $suffix, ')
          ..write('inflectionsHtml: $inflectionsHtml, ')
          ..write('freqHtml: $freqHtml, ')
          ..write('ebtCount: $ebtCount, ')
          ..write('nonIa: $nonIa, ')
          ..write('sanskrit: $sanskrit, ')
          ..write('cognate: $cognate, ')
          ..write('link: $link, ')
          ..write('phonetic: $phonetic, ')
          ..write('varPhonetic: $varPhonetic, ')
          ..write('varText: $varText, ')
          ..write('origin: $origin, ')
          ..write('notes: $notes, ')
          ..write('commentary: $commentary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    lemma1,
    lemma2,
    pos,
    grammar,
    derivedFrom,
    neg,
    verb,
    trans,
    plusCase,
    derivative,
    meaning1,
    meaningLit,
    meaning2,
    rootKey,
    rootSign,
    rootBase,
    familyRoot,
    familyWord,
    familyCompound,
    familyIdioms,
    familySet,
    construction,
    compoundType,
    compoundConstruction,
    source1,
    sutta1,
    example1,
    source2,
    sutta2,
    example2,
    antonym,
    synonym,
    variant,
    stem,
    pattern,
    suffix,
    inflectionsHtml,
    freqHtml,
    ebtCount,
    nonIa,
    sanskrit,
    cognate,
    link,
    phonetic,
    varPhonetic,
    varText,
    origin,
    notes,
    commentary,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DpdHeadword &&
          other.id == this.id &&
          other.lemma1 == this.lemma1 &&
          other.lemma2 == this.lemma2 &&
          other.pos == this.pos &&
          other.grammar == this.grammar &&
          other.derivedFrom == this.derivedFrom &&
          other.neg == this.neg &&
          other.verb == this.verb &&
          other.trans == this.trans &&
          other.plusCase == this.plusCase &&
          other.derivative == this.derivative &&
          other.meaning1 == this.meaning1 &&
          other.meaningLit == this.meaningLit &&
          other.meaning2 == this.meaning2 &&
          other.rootKey == this.rootKey &&
          other.rootSign == this.rootSign &&
          other.rootBase == this.rootBase &&
          other.familyRoot == this.familyRoot &&
          other.familyWord == this.familyWord &&
          other.familyCompound == this.familyCompound &&
          other.familyIdioms == this.familyIdioms &&
          other.familySet == this.familySet &&
          other.construction == this.construction &&
          other.compoundType == this.compoundType &&
          other.compoundConstruction == this.compoundConstruction &&
          other.source1 == this.source1 &&
          other.sutta1 == this.sutta1 &&
          other.example1 == this.example1 &&
          other.source2 == this.source2 &&
          other.sutta2 == this.sutta2 &&
          other.example2 == this.example2 &&
          other.antonym == this.antonym &&
          other.synonym == this.synonym &&
          other.variant == this.variant &&
          other.stem == this.stem &&
          other.pattern == this.pattern &&
          other.suffix == this.suffix &&
          other.inflectionsHtml == this.inflectionsHtml &&
          other.freqHtml == this.freqHtml &&
          other.ebtCount == this.ebtCount &&
          other.nonIa == this.nonIa &&
          other.sanskrit == this.sanskrit &&
          other.cognate == this.cognate &&
          other.link == this.link &&
          other.phonetic == this.phonetic &&
          other.varPhonetic == this.varPhonetic &&
          other.varText == this.varText &&
          other.origin == this.origin &&
          other.notes == this.notes &&
          other.commentary == this.commentary);
}

class DpdHeadwordsCompanion extends UpdateCompanion<DpdHeadword> {
  final Value<int> id;
  final Value<String> lemma1;
  final Value<String?> lemma2;
  final Value<String?> pos;
  final Value<String?> grammar;
  final Value<String?> derivedFrom;
  final Value<String?> neg;
  final Value<String?> verb;
  final Value<String?> trans;
  final Value<String?> plusCase;
  final Value<String?> derivative;
  final Value<String?> meaning1;
  final Value<String?> meaningLit;
  final Value<String?> meaning2;
  final Value<String?> rootKey;
  final Value<String?> rootSign;
  final Value<String?> rootBase;
  final Value<String?> familyRoot;
  final Value<String?> familyWord;
  final Value<String?> familyCompound;
  final Value<String?> familyIdioms;
  final Value<String?> familySet;
  final Value<String?> construction;
  final Value<String?> compoundType;
  final Value<String?> compoundConstruction;
  final Value<String?> source1;
  final Value<String?> sutta1;
  final Value<String?> example1;
  final Value<String?> source2;
  final Value<String?> sutta2;
  final Value<String?> example2;
  final Value<String?> antonym;
  final Value<String?> synonym;
  final Value<String?> variant;
  final Value<String?> stem;
  final Value<String?> pattern;
  final Value<String?> suffix;
  final Value<String?> inflectionsHtml;
  final Value<String?> freqHtml;
  final Value<int?> ebtCount;
  final Value<String?> nonIa;
  final Value<String?> sanskrit;
  final Value<String?> cognate;
  final Value<String?> link;
  final Value<String?> phonetic;
  final Value<String?> varPhonetic;
  final Value<String?> varText;
  final Value<String?> origin;
  final Value<String?> notes;
  final Value<String?> commentary;
  const DpdHeadwordsCompanion({
    this.id = const Value.absent(),
    this.lemma1 = const Value.absent(),
    this.lemma2 = const Value.absent(),
    this.pos = const Value.absent(),
    this.grammar = const Value.absent(),
    this.derivedFrom = const Value.absent(),
    this.neg = const Value.absent(),
    this.verb = const Value.absent(),
    this.trans = const Value.absent(),
    this.plusCase = const Value.absent(),
    this.derivative = const Value.absent(),
    this.meaning1 = const Value.absent(),
    this.meaningLit = const Value.absent(),
    this.meaning2 = const Value.absent(),
    this.rootKey = const Value.absent(),
    this.rootSign = const Value.absent(),
    this.rootBase = const Value.absent(),
    this.familyRoot = const Value.absent(),
    this.familyWord = const Value.absent(),
    this.familyCompound = const Value.absent(),
    this.familyIdioms = const Value.absent(),
    this.familySet = const Value.absent(),
    this.construction = const Value.absent(),
    this.compoundType = const Value.absent(),
    this.compoundConstruction = const Value.absent(),
    this.source1 = const Value.absent(),
    this.sutta1 = const Value.absent(),
    this.example1 = const Value.absent(),
    this.source2 = const Value.absent(),
    this.sutta2 = const Value.absent(),
    this.example2 = const Value.absent(),
    this.antonym = const Value.absent(),
    this.synonym = const Value.absent(),
    this.variant = const Value.absent(),
    this.stem = const Value.absent(),
    this.pattern = const Value.absent(),
    this.suffix = const Value.absent(),
    this.inflectionsHtml = const Value.absent(),
    this.freqHtml = const Value.absent(),
    this.ebtCount = const Value.absent(),
    this.nonIa = const Value.absent(),
    this.sanskrit = const Value.absent(),
    this.cognate = const Value.absent(),
    this.link = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.varPhonetic = const Value.absent(),
    this.varText = const Value.absent(),
    this.origin = const Value.absent(),
    this.notes = const Value.absent(),
    this.commentary = const Value.absent(),
  });
  DpdHeadwordsCompanion.insert({
    this.id = const Value.absent(),
    required String lemma1,
    this.lemma2 = const Value.absent(),
    this.pos = const Value.absent(),
    this.grammar = const Value.absent(),
    this.derivedFrom = const Value.absent(),
    this.neg = const Value.absent(),
    this.verb = const Value.absent(),
    this.trans = const Value.absent(),
    this.plusCase = const Value.absent(),
    this.derivative = const Value.absent(),
    this.meaning1 = const Value.absent(),
    this.meaningLit = const Value.absent(),
    this.meaning2 = const Value.absent(),
    this.rootKey = const Value.absent(),
    this.rootSign = const Value.absent(),
    this.rootBase = const Value.absent(),
    this.familyRoot = const Value.absent(),
    this.familyWord = const Value.absent(),
    this.familyCompound = const Value.absent(),
    this.familyIdioms = const Value.absent(),
    this.familySet = const Value.absent(),
    this.construction = const Value.absent(),
    this.compoundType = const Value.absent(),
    this.compoundConstruction = const Value.absent(),
    this.source1 = const Value.absent(),
    this.sutta1 = const Value.absent(),
    this.example1 = const Value.absent(),
    this.source2 = const Value.absent(),
    this.sutta2 = const Value.absent(),
    this.example2 = const Value.absent(),
    this.antonym = const Value.absent(),
    this.synonym = const Value.absent(),
    this.variant = const Value.absent(),
    this.stem = const Value.absent(),
    this.pattern = const Value.absent(),
    this.suffix = const Value.absent(),
    this.inflectionsHtml = const Value.absent(),
    this.freqHtml = const Value.absent(),
    this.ebtCount = const Value.absent(),
    this.nonIa = const Value.absent(),
    this.sanskrit = const Value.absent(),
    this.cognate = const Value.absent(),
    this.link = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.varPhonetic = const Value.absent(),
    this.varText = const Value.absent(),
    this.origin = const Value.absent(),
    this.notes = const Value.absent(),
    this.commentary = const Value.absent(),
  }) : lemma1 = Value(lemma1);
  static Insertable<DpdHeadword> custom({
    Expression<int>? id,
    Expression<String>? lemma1,
    Expression<String>? lemma2,
    Expression<String>? pos,
    Expression<String>? grammar,
    Expression<String>? derivedFrom,
    Expression<String>? neg,
    Expression<String>? verb,
    Expression<String>? trans,
    Expression<String>? plusCase,
    Expression<String>? derivative,
    Expression<String>? meaning1,
    Expression<String>? meaningLit,
    Expression<String>? meaning2,
    Expression<String>? rootKey,
    Expression<String>? rootSign,
    Expression<String>? rootBase,
    Expression<String>? familyRoot,
    Expression<String>? familyWord,
    Expression<String>? familyCompound,
    Expression<String>? familyIdioms,
    Expression<String>? familySet,
    Expression<String>? construction,
    Expression<String>? compoundType,
    Expression<String>? compoundConstruction,
    Expression<String>? source1,
    Expression<String>? sutta1,
    Expression<String>? example1,
    Expression<String>? source2,
    Expression<String>? sutta2,
    Expression<String>? example2,
    Expression<String>? antonym,
    Expression<String>? synonym,
    Expression<String>? variant,
    Expression<String>? stem,
    Expression<String>? pattern,
    Expression<String>? suffix,
    Expression<String>? inflectionsHtml,
    Expression<String>? freqHtml,
    Expression<int>? ebtCount,
    Expression<String>? nonIa,
    Expression<String>? sanskrit,
    Expression<String>? cognate,
    Expression<String>? link,
    Expression<String>? phonetic,
    Expression<String>? varPhonetic,
    Expression<String>? varText,
    Expression<String>? origin,
    Expression<String>? notes,
    Expression<String>? commentary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lemma1 != null) 'lemma_1': lemma1,
      if (lemma2 != null) 'lemma_2': lemma2,
      if (pos != null) 'pos': pos,
      if (grammar != null) 'grammar': grammar,
      if (derivedFrom != null) 'derived_from': derivedFrom,
      if (neg != null) 'neg': neg,
      if (verb != null) 'verb': verb,
      if (trans != null) 'trans': trans,
      if (plusCase != null) 'plus_case': plusCase,
      if (derivative != null) 'derivative': derivative,
      if (meaning1 != null) 'meaning_1': meaning1,
      if (meaningLit != null) 'meaning_lit': meaningLit,
      if (meaning2 != null) 'meaning_2': meaning2,
      if (rootKey != null) 'root_key': rootKey,
      if (rootSign != null) 'root_sign': rootSign,
      if (rootBase != null) 'root_base': rootBase,
      if (familyRoot != null) 'family_root': familyRoot,
      if (familyWord != null) 'family_word': familyWord,
      if (familyCompound != null) 'family_compound': familyCompound,
      if (familyIdioms != null) 'family_idioms': familyIdioms,
      if (familySet != null) 'family_set': familySet,
      if (construction != null) 'construction': construction,
      if (compoundType != null) 'compound_type': compoundType,
      if (compoundConstruction != null)
        'compound_construction': compoundConstruction,
      if (source1 != null) 'source_1': source1,
      if (sutta1 != null) 'sutta_1': sutta1,
      if (example1 != null) 'example_1': example1,
      if (source2 != null) 'source_2': source2,
      if (sutta2 != null) 'sutta_2': sutta2,
      if (example2 != null) 'example_2': example2,
      if (antonym != null) 'antonym': antonym,
      if (synonym != null) 'synonym': synonym,
      if (variant != null) 'variant': variant,
      if (stem != null) 'stem': stem,
      if (pattern != null) 'pattern': pattern,
      if (suffix != null) 'suffix': suffix,
      if (inflectionsHtml != null) 'inflections_html': inflectionsHtml,
      if (freqHtml != null) 'freq_html': freqHtml,
      if (ebtCount != null) 'ebt_count': ebtCount,
      if (nonIa != null) 'non_ia': nonIa,
      if (sanskrit != null) 'sanskrit': sanskrit,
      if (cognate != null) 'cognate': cognate,
      if (link != null) 'link': link,
      if (phonetic != null) 'phonetic': phonetic,
      if (varPhonetic != null) 'var_phonetic': varPhonetic,
      if (varText != null) 'var_text': varText,
      if (origin != null) 'origin': origin,
      if (notes != null) 'notes': notes,
      if (commentary != null) 'commentary': commentary,
    });
  }

  DpdHeadwordsCompanion copyWith({
    Value<int>? id,
    Value<String>? lemma1,
    Value<String?>? lemma2,
    Value<String?>? pos,
    Value<String?>? grammar,
    Value<String?>? derivedFrom,
    Value<String?>? neg,
    Value<String?>? verb,
    Value<String?>? trans,
    Value<String?>? plusCase,
    Value<String?>? derivative,
    Value<String?>? meaning1,
    Value<String?>? meaningLit,
    Value<String?>? meaning2,
    Value<String?>? rootKey,
    Value<String?>? rootSign,
    Value<String?>? rootBase,
    Value<String?>? familyRoot,
    Value<String?>? familyWord,
    Value<String?>? familyCompound,
    Value<String?>? familyIdioms,
    Value<String?>? familySet,
    Value<String?>? construction,
    Value<String?>? compoundType,
    Value<String?>? compoundConstruction,
    Value<String?>? source1,
    Value<String?>? sutta1,
    Value<String?>? example1,
    Value<String?>? source2,
    Value<String?>? sutta2,
    Value<String?>? example2,
    Value<String?>? antonym,
    Value<String?>? synonym,
    Value<String?>? variant,
    Value<String?>? stem,
    Value<String?>? pattern,
    Value<String?>? suffix,
    Value<String?>? inflectionsHtml,
    Value<String?>? freqHtml,
    Value<int?>? ebtCount,
    Value<String?>? nonIa,
    Value<String?>? sanskrit,
    Value<String?>? cognate,
    Value<String?>? link,
    Value<String?>? phonetic,
    Value<String?>? varPhonetic,
    Value<String?>? varText,
    Value<String?>? origin,
    Value<String?>? notes,
    Value<String?>? commentary,
  }) {
    return DpdHeadwordsCompanion(
      id: id ?? this.id,
      lemma1: lemma1 ?? this.lemma1,
      lemma2: lemma2 ?? this.lemma2,
      pos: pos ?? this.pos,
      grammar: grammar ?? this.grammar,
      derivedFrom: derivedFrom ?? this.derivedFrom,
      neg: neg ?? this.neg,
      verb: verb ?? this.verb,
      trans: trans ?? this.trans,
      plusCase: plusCase ?? this.plusCase,
      derivative: derivative ?? this.derivative,
      meaning1: meaning1 ?? this.meaning1,
      meaningLit: meaningLit ?? this.meaningLit,
      meaning2: meaning2 ?? this.meaning2,
      rootKey: rootKey ?? this.rootKey,
      rootSign: rootSign ?? this.rootSign,
      rootBase: rootBase ?? this.rootBase,
      familyRoot: familyRoot ?? this.familyRoot,
      familyWord: familyWord ?? this.familyWord,
      familyCompound: familyCompound ?? this.familyCompound,
      familyIdioms: familyIdioms ?? this.familyIdioms,
      familySet: familySet ?? this.familySet,
      construction: construction ?? this.construction,
      compoundType: compoundType ?? this.compoundType,
      compoundConstruction: compoundConstruction ?? this.compoundConstruction,
      source1: source1 ?? this.source1,
      sutta1: sutta1 ?? this.sutta1,
      example1: example1 ?? this.example1,
      source2: source2 ?? this.source2,
      sutta2: sutta2 ?? this.sutta2,
      example2: example2 ?? this.example2,
      antonym: antonym ?? this.antonym,
      synonym: synonym ?? this.synonym,
      variant: variant ?? this.variant,
      stem: stem ?? this.stem,
      pattern: pattern ?? this.pattern,
      suffix: suffix ?? this.suffix,
      inflectionsHtml: inflectionsHtml ?? this.inflectionsHtml,
      freqHtml: freqHtml ?? this.freqHtml,
      ebtCount: ebtCount ?? this.ebtCount,
      nonIa: nonIa ?? this.nonIa,
      sanskrit: sanskrit ?? this.sanskrit,
      cognate: cognate ?? this.cognate,
      link: link ?? this.link,
      phonetic: phonetic ?? this.phonetic,
      varPhonetic: varPhonetic ?? this.varPhonetic,
      varText: varText ?? this.varText,
      origin: origin ?? this.origin,
      notes: notes ?? this.notes,
      commentary: commentary ?? this.commentary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lemma1.present) {
      map['lemma_1'] = Variable<String>(lemma1.value);
    }
    if (lemma2.present) {
      map['lemma_2'] = Variable<String>(lemma2.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (grammar.present) {
      map['grammar'] = Variable<String>(grammar.value);
    }
    if (derivedFrom.present) {
      map['derived_from'] = Variable<String>(derivedFrom.value);
    }
    if (neg.present) {
      map['neg'] = Variable<String>(neg.value);
    }
    if (verb.present) {
      map['verb'] = Variable<String>(verb.value);
    }
    if (trans.present) {
      map['trans'] = Variable<String>(trans.value);
    }
    if (plusCase.present) {
      map['plus_case'] = Variable<String>(plusCase.value);
    }
    if (derivative.present) {
      map['derivative'] = Variable<String>(derivative.value);
    }
    if (meaning1.present) {
      map['meaning_1'] = Variable<String>(meaning1.value);
    }
    if (meaningLit.present) {
      map['meaning_lit'] = Variable<String>(meaningLit.value);
    }
    if (meaning2.present) {
      map['meaning_2'] = Variable<String>(meaning2.value);
    }
    if (rootKey.present) {
      map['root_key'] = Variable<String>(rootKey.value);
    }
    if (rootSign.present) {
      map['root_sign'] = Variable<String>(rootSign.value);
    }
    if (rootBase.present) {
      map['root_base'] = Variable<String>(rootBase.value);
    }
    if (familyRoot.present) {
      map['family_root'] = Variable<String>(familyRoot.value);
    }
    if (familyWord.present) {
      map['family_word'] = Variable<String>(familyWord.value);
    }
    if (familyCompound.present) {
      map['family_compound'] = Variable<String>(familyCompound.value);
    }
    if (familyIdioms.present) {
      map['family_idioms'] = Variable<String>(familyIdioms.value);
    }
    if (familySet.present) {
      map['family_set'] = Variable<String>(familySet.value);
    }
    if (construction.present) {
      map['construction'] = Variable<String>(construction.value);
    }
    if (compoundType.present) {
      map['compound_type'] = Variable<String>(compoundType.value);
    }
    if (compoundConstruction.present) {
      map['compound_construction'] = Variable<String>(
        compoundConstruction.value,
      );
    }
    if (source1.present) {
      map['source_1'] = Variable<String>(source1.value);
    }
    if (sutta1.present) {
      map['sutta_1'] = Variable<String>(sutta1.value);
    }
    if (example1.present) {
      map['example_1'] = Variable<String>(example1.value);
    }
    if (source2.present) {
      map['source_2'] = Variable<String>(source2.value);
    }
    if (sutta2.present) {
      map['sutta_2'] = Variable<String>(sutta2.value);
    }
    if (example2.present) {
      map['example_2'] = Variable<String>(example2.value);
    }
    if (antonym.present) {
      map['antonym'] = Variable<String>(antonym.value);
    }
    if (synonym.present) {
      map['synonym'] = Variable<String>(synonym.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (suffix.present) {
      map['suffix'] = Variable<String>(suffix.value);
    }
    if (inflectionsHtml.present) {
      map['inflections_html'] = Variable<String>(inflectionsHtml.value);
    }
    if (freqHtml.present) {
      map['freq_html'] = Variable<String>(freqHtml.value);
    }
    if (ebtCount.present) {
      map['ebt_count'] = Variable<int>(ebtCount.value);
    }
    if (nonIa.present) {
      map['non_ia'] = Variable<String>(nonIa.value);
    }
    if (sanskrit.present) {
      map['sanskrit'] = Variable<String>(sanskrit.value);
    }
    if (cognate.present) {
      map['cognate'] = Variable<String>(cognate.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (varPhonetic.present) {
      map['var_phonetic'] = Variable<String>(varPhonetic.value);
    }
    if (varText.present) {
      map['var_text'] = Variable<String>(varText.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (commentary.present) {
      map['commentary'] = Variable<String>(commentary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DpdHeadwordsCompanion(')
          ..write('id: $id, ')
          ..write('lemma1: $lemma1, ')
          ..write('lemma2: $lemma2, ')
          ..write('pos: $pos, ')
          ..write('grammar: $grammar, ')
          ..write('derivedFrom: $derivedFrom, ')
          ..write('neg: $neg, ')
          ..write('verb: $verb, ')
          ..write('trans: $trans, ')
          ..write('plusCase: $plusCase, ')
          ..write('derivative: $derivative, ')
          ..write('meaning1: $meaning1, ')
          ..write('meaningLit: $meaningLit, ')
          ..write('meaning2: $meaning2, ')
          ..write('rootKey: $rootKey, ')
          ..write('rootSign: $rootSign, ')
          ..write('rootBase: $rootBase, ')
          ..write('familyRoot: $familyRoot, ')
          ..write('familyWord: $familyWord, ')
          ..write('familyCompound: $familyCompound, ')
          ..write('familyIdioms: $familyIdioms, ')
          ..write('familySet: $familySet, ')
          ..write('construction: $construction, ')
          ..write('compoundType: $compoundType, ')
          ..write('compoundConstruction: $compoundConstruction, ')
          ..write('source1: $source1, ')
          ..write('sutta1: $sutta1, ')
          ..write('example1: $example1, ')
          ..write('source2: $source2, ')
          ..write('sutta2: $sutta2, ')
          ..write('example2: $example2, ')
          ..write('antonym: $antonym, ')
          ..write('synonym: $synonym, ')
          ..write('variant: $variant, ')
          ..write('stem: $stem, ')
          ..write('pattern: $pattern, ')
          ..write('suffix: $suffix, ')
          ..write('inflectionsHtml: $inflectionsHtml, ')
          ..write('freqHtml: $freqHtml, ')
          ..write('ebtCount: $ebtCount, ')
          ..write('nonIa: $nonIa, ')
          ..write('sanskrit: $sanskrit, ')
          ..write('cognate: $cognate, ')
          ..write('link: $link, ')
          ..write('phonetic: $phonetic, ')
          ..write('varPhonetic: $varPhonetic, ')
          ..write('varText: $varText, ')
          ..write('origin: $origin, ')
          ..write('notes: $notes, ')
          ..write('commentary: $commentary')
          ..write(')'))
        .toString();
  }
}

class $LookupTable extends Lookup with TableInfo<$LookupTable, LookupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LookupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lookupKeyMeta = const VerificationMeta(
    'lookupKey',
  );
  @override
  late final GeneratedColumn<String> lookupKey = GeneratedColumn<String>(
    'lookup_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headwordsMeta = const VerificationMeta(
    'headwords',
  );
  @override
  late final GeneratedColumn<String> headwords = GeneratedColumn<String>(
    'headwords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rootsMeta = const VerificationMeta('roots');
  @override
  late final GeneratedColumn<String> roots = GeneratedColumn<String>(
    'roots',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seeMeta = const VerificationMeta('see');
  @override
  late final GeneratedColumn<String> see = GeneratedColumn<String>(
    'see',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spellingMeta = const VerificationMeta(
    'spelling',
  );
  @override
  late final GeneratedColumn<String> spelling = GeneratedColumn<String>(
    'spelling',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grammarMeta = const VerificationMeta(
    'grammar',
  );
  @override
  late final GeneratedColumn<String> grammar = GeneratedColumn<String>(
    'grammar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _helpMeta = const VerificationMeta('help');
  @override
  late final GeneratedColumn<String> help = GeneratedColumn<String>(
    'help',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _abbrevMeta = const VerificationMeta('abbrev');
  @override
  late final GeneratedColumn<String> abbrev = GeneratedColumn<String>(
    'abbrev',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lookupKey,
    headwords,
    roots,
    variant,
    see,
    spelling,
    grammar,
    help,
    abbrev,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lookup';
  @override
  VerificationContext validateIntegrity(
    Insertable<LookupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lookup_key')) {
      context.handle(
        _lookupKeyMeta,
        lookupKey.isAcceptableOrUnknown(data['lookup_key']!, _lookupKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_lookupKeyMeta);
    }
    if (data.containsKey('headwords')) {
      context.handle(
        _headwordsMeta,
        headwords.isAcceptableOrUnknown(data['headwords']!, _headwordsMeta),
      );
    }
    if (data.containsKey('roots')) {
      context.handle(
        _rootsMeta,
        roots.isAcceptableOrUnknown(data['roots']!, _rootsMeta),
      );
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('see')) {
      context.handle(
        _seeMeta,
        see.isAcceptableOrUnknown(data['see']!, _seeMeta),
      );
    }
    if (data.containsKey('spelling')) {
      context.handle(
        _spellingMeta,
        spelling.isAcceptableOrUnknown(data['spelling']!, _spellingMeta),
      );
    }
    if (data.containsKey('grammar')) {
      context.handle(
        _grammarMeta,
        grammar.isAcceptableOrUnknown(data['grammar']!, _grammarMeta),
      );
    }
    if (data.containsKey('help')) {
      context.handle(
        _helpMeta,
        help.isAcceptableOrUnknown(data['help']!, _helpMeta),
      );
    }
    if (data.containsKey('abbrev')) {
      context.handle(
        _abbrevMeta,
        abbrev.isAcceptableOrUnknown(data['abbrev']!, _abbrevMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lookupKey};
  @override
  LookupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LookupData(
      lookupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lookup_key'],
      )!,
      headwords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headwords'],
      ),
      roots: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}roots'],
      ),
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      see: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}see'],
      ),
      spelling: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spelling'],
      ),
      grammar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar'],
      ),
      help: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}help'],
      ),
      abbrev: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}abbrev'],
      ),
    );
  }

  @override
  $LookupTable createAlias(String alias) {
    return $LookupTable(attachedDatabase, alias);
  }
}

class LookupData extends DataClass implements Insertable<LookupData> {
  final String lookupKey;
  final String? headwords;
  final String? roots;
  final String? variant;
  final String? see;
  final String? spelling;
  final String? grammar;
  final String? help;
  final String? abbrev;
  const LookupData({
    required this.lookupKey,
    this.headwords,
    this.roots,
    this.variant,
    this.see,
    this.spelling,
    this.grammar,
    this.help,
    this.abbrev,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lookup_key'] = Variable<String>(lookupKey);
    if (!nullToAbsent || headwords != null) {
      map['headwords'] = Variable<String>(headwords);
    }
    if (!nullToAbsent || roots != null) {
      map['roots'] = Variable<String>(roots);
    }
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    if (!nullToAbsent || see != null) {
      map['see'] = Variable<String>(see);
    }
    if (!nullToAbsent || spelling != null) {
      map['spelling'] = Variable<String>(spelling);
    }
    if (!nullToAbsent || grammar != null) {
      map['grammar'] = Variable<String>(grammar);
    }
    if (!nullToAbsent || help != null) {
      map['help'] = Variable<String>(help);
    }
    if (!nullToAbsent || abbrev != null) {
      map['abbrev'] = Variable<String>(abbrev);
    }
    return map;
  }

  LookupCompanion toCompanion(bool nullToAbsent) {
    return LookupCompanion(
      lookupKey: Value(lookupKey),
      headwords: headwords == null && nullToAbsent
          ? const Value.absent()
          : Value(headwords),
      roots: roots == null && nullToAbsent
          ? const Value.absent()
          : Value(roots),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      see: see == null && nullToAbsent ? const Value.absent() : Value(see),
      spelling: spelling == null && nullToAbsent
          ? const Value.absent()
          : Value(spelling),
      grammar: grammar == null && nullToAbsent
          ? const Value.absent()
          : Value(grammar),
      help: help == null && nullToAbsent ? const Value.absent() : Value(help),
      abbrev: abbrev == null && nullToAbsent
          ? const Value.absent()
          : Value(abbrev),
    );
  }

  factory LookupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LookupData(
      lookupKey: serializer.fromJson<String>(json['lookupKey']),
      headwords: serializer.fromJson<String?>(json['headwords']),
      roots: serializer.fromJson<String?>(json['roots']),
      variant: serializer.fromJson<String?>(json['variant']),
      see: serializer.fromJson<String?>(json['see']),
      spelling: serializer.fromJson<String?>(json['spelling']),
      grammar: serializer.fromJson<String?>(json['grammar']),
      help: serializer.fromJson<String?>(json['help']),
      abbrev: serializer.fromJson<String?>(json['abbrev']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lookupKey': serializer.toJson<String>(lookupKey),
      'headwords': serializer.toJson<String?>(headwords),
      'roots': serializer.toJson<String?>(roots),
      'variant': serializer.toJson<String?>(variant),
      'see': serializer.toJson<String?>(see),
      'spelling': serializer.toJson<String?>(spelling),
      'grammar': serializer.toJson<String?>(grammar),
      'help': serializer.toJson<String?>(help),
      'abbrev': serializer.toJson<String?>(abbrev),
    };
  }

  LookupData copyWith({
    String? lookupKey,
    Value<String?> headwords = const Value.absent(),
    Value<String?> roots = const Value.absent(),
    Value<String?> variant = const Value.absent(),
    Value<String?> see = const Value.absent(),
    Value<String?> spelling = const Value.absent(),
    Value<String?> grammar = const Value.absent(),
    Value<String?> help = const Value.absent(),
    Value<String?> abbrev = const Value.absent(),
  }) => LookupData(
    lookupKey: lookupKey ?? this.lookupKey,
    headwords: headwords.present ? headwords.value : this.headwords,
    roots: roots.present ? roots.value : this.roots,
    variant: variant.present ? variant.value : this.variant,
    see: see.present ? see.value : this.see,
    spelling: spelling.present ? spelling.value : this.spelling,
    grammar: grammar.present ? grammar.value : this.grammar,
    help: help.present ? help.value : this.help,
    abbrev: abbrev.present ? abbrev.value : this.abbrev,
  );
  LookupData copyWithCompanion(LookupCompanion data) {
    return LookupData(
      lookupKey: data.lookupKey.present ? data.lookupKey.value : this.lookupKey,
      headwords: data.headwords.present ? data.headwords.value : this.headwords,
      roots: data.roots.present ? data.roots.value : this.roots,
      variant: data.variant.present ? data.variant.value : this.variant,
      see: data.see.present ? data.see.value : this.see,
      spelling: data.spelling.present ? data.spelling.value : this.spelling,
      grammar: data.grammar.present ? data.grammar.value : this.grammar,
      help: data.help.present ? data.help.value : this.help,
      abbrev: data.abbrev.present ? data.abbrev.value : this.abbrev,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LookupData(')
          ..write('lookupKey: $lookupKey, ')
          ..write('headwords: $headwords, ')
          ..write('roots: $roots, ')
          ..write('variant: $variant, ')
          ..write('see: $see, ')
          ..write('spelling: $spelling, ')
          ..write('grammar: $grammar, ')
          ..write('help: $help, ')
          ..write('abbrev: $abbrev')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lookupKey,
    headwords,
    roots,
    variant,
    see,
    spelling,
    grammar,
    help,
    abbrev,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookupData &&
          other.lookupKey == this.lookupKey &&
          other.headwords == this.headwords &&
          other.roots == this.roots &&
          other.variant == this.variant &&
          other.see == this.see &&
          other.spelling == this.spelling &&
          other.grammar == this.grammar &&
          other.help == this.help &&
          other.abbrev == this.abbrev);
}

class LookupCompanion extends UpdateCompanion<LookupData> {
  final Value<String> lookupKey;
  final Value<String?> headwords;
  final Value<String?> roots;
  final Value<String?> variant;
  final Value<String?> see;
  final Value<String?> spelling;
  final Value<String?> grammar;
  final Value<String?> help;
  final Value<String?> abbrev;
  final Value<int> rowid;
  const LookupCompanion({
    this.lookupKey = const Value.absent(),
    this.headwords = const Value.absent(),
    this.roots = const Value.absent(),
    this.variant = const Value.absent(),
    this.see = const Value.absent(),
    this.spelling = const Value.absent(),
    this.grammar = const Value.absent(),
    this.help = const Value.absent(),
    this.abbrev = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LookupCompanion.insert({
    required String lookupKey,
    this.headwords = const Value.absent(),
    this.roots = const Value.absent(),
    this.variant = const Value.absent(),
    this.see = const Value.absent(),
    this.spelling = const Value.absent(),
    this.grammar = const Value.absent(),
    this.help = const Value.absent(),
    this.abbrev = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : lookupKey = Value(lookupKey);
  static Insertable<LookupData> custom({
    Expression<String>? lookupKey,
    Expression<String>? headwords,
    Expression<String>? roots,
    Expression<String>? variant,
    Expression<String>? see,
    Expression<String>? spelling,
    Expression<String>? grammar,
    Expression<String>? help,
    Expression<String>? abbrev,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lookupKey != null) 'lookup_key': lookupKey,
      if (headwords != null) 'headwords': headwords,
      if (roots != null) 'roots': roots,
      if (variant != null) 'variant': variant,
      if (see != null) 'see': see,
      if (spelling != null) 'spelling': spelling,
      if (grammar != null) 'grammar': grammar,
      if (help != null) 'help': help,
      if (abbrev != null) 'abbrev': abbrev,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LookupCompanion copyWith({
    Value<String>? lookupKey,
    Value<String?>? headwords,
    Value<String?>? roots,
    Value<String?>? variant,
    Value<String?>? see,
    Value<String?>? spelling,
    Value<String?>? grammar,
    Value<String?>? help,
    Value<String?>? abbrev,
    Value<int>? rowid,
  }) {
    return LookupCompanion(
      lookupKey: lookupKey ?? this.lookupKey,
      headwords: headwords ?? this.headwords,
      roots: roots ?? this.roots,
      variant: variant ?? this.variant,
      see: see ?? this.see,
      spelling: spelling ?? this.spelling,
      grammar: grammar ?? this.grammar,
      help: help ?? this.help,
      abbrev: abbrev ?? this.abbrev,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lookupKey.present) {
      map['lookup_key'] = Variable<String>(lookupKey.value);
    }
    if (headwords.present) {
      map['headwords'] = Variable<String>(headwords.value);
    }
    if (roots.present) {
      map['roots'] = Variable<String>(roots.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (see.present) {
      map['see'] = Variable<String>(see.value);
    }
    if (spelling.present) {
      map['spelling'] = Variable<String>(spelling.value);
    }
    if (grammar.present) {
      map['grammar'] = Variable<String>(grammar.value);
    }
    if (help.present) {
      map['help'] = Variable<String>(help.value);
    }
    if (abbrev.present) {
      map['abbrev'] = Variable<String>(abbrev.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LookupCompanion(')
          ..write('lookupKey: $lookupKey, ')
          ..write('headwords: $headwords, ')
          ..write('roots: $roots, ')
          ..write('variant: $variant, ')
          ..write('see: $see, ')
          ..write('spelling: $spelling, ')
          ..write('grammar: $grammar, ')
          ..write('help: $help, ')
          ..write('abbrev: $abbrev, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DbInfoTable extends DbInfo with TableInfo<$DbInfoTable, DbInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DbInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'db_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DbInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbInfoData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $DbInfoTable createAlias(String alias) {
    return $DbInfoTable(attachedDatabase, alias);
  }
}

class DbInfoData extends DataClass implements Insertable<DbInfoData> {
  final String key;
  final String? value;
  const DbInfoData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  DbInfoCompanion toCompanion(bool nullToAbsent) {
    return DbInfoCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory DbInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbInfoData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  DbInfoData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => DbInfoData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  DbInfoData copyWithCompanion(DbInfoCompanion data) {
    return DbInfoData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbInfoData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbInfoData &&
          other.key == this.key &&
          other.value == this.value);
}

class DbInfoCompanion extends UpdateCompanion<DbInfoData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const DbInfoCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DbInfoCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<DbInfoData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DbInfoCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return DbInfoCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DbInfoCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InflectionTemplatesTable extends InflectionTemplates
    with TableInfo<$InflectionTemplatesTable, InflectionTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InflectionTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateLikeMeta = const VerificationMeta(
    'templateLike',
  );
  @override
  late final GeneratedColumn<String> templateLike = GeneratedColumn<String>(
    'like',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pattern, templateLike, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inflection_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<InflectionTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('like')) {
      context.handle(
        _templateLikeMeta,
        templateLike.isAcceptableOrUnknown(data['like']!, _templateLikeMeta),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pattern};
  @override
  InflectionTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InflectionTemplate(
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      templateLike: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}like'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $InflectionTemplatesTable createAlias(String alias) {
    return $InflectionTemplatesTable(attachedDatabase, alias);
  }
}

class InflectionTemplate extends DataClass
    implements Insertable<InflectionTemplate> {
  final String pattern;
  final String? templateLike;
  final String data;
  const InflectionTemplate({
    required this.pattern,
    this.templateLike,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pattern'] = Variable<String>(pattern);
    if (!nullToAbsent || templateLike != null) {
      map['like'] = Variable<String>(templateLike);
    }
    map['data'] = Variable<String>(data);
    return map;
  }

  InflectionTemplatesCompanion toCompanion(bool nullToAbsent) {
    return InflectionTemplatesCompanion(
      pattern: Value(pattern),
      templateLike: templateLike == null && nullToAbsent
          ? const Value.absent()
          : Value(templateLike),
      data: Value(data),
    );
  }

  factory InflectionTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InflectionTemplate(
      pattern: serializer.fromJson<String>(json['pattern']),
      templateLike: serializer.fromJson<String?>(json['templateLike']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pattern': serializer.toJson<String>(pattern),
      'templateLike': serializer.toJson<String?>(templateLike),
      'data': serializer.toJson<String>(data),
    };
  }

  InflectionTemplate copyWith({
    String? pattern,
    Value<String?> templateLike = const Value.absent(),
    String? data,
  }) => InflectionTemplate(
    pattern: pattern ?? this.pattern,
    templateLike: templateLike.present ? templateLike.value : this.templateLike,
    data: data ?? this.data,
  );
  InflectionTemplate copyWithCompanion(InflectionTemplatesCompanion data) {
    return InflectionTemplate(
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      templateLike: data.templateLike.present
          ? data.templateLike.value
          : this.templateLike,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InflectionTemplate(')
          ..write('pattern: $pattern, ')
          ..write('templateLike: $templateLike, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pattern, templateLike, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InflectionTemplate &&
          other.pattern == this.pattern &&
          other.templateLike == this.templateLike &&
          other.data == this.data);
}

class InflectionTemplatesCompanion extends UpdateCompanion<InflectionTemplate> {
  final Value<String> pattern;
  final Value<String?> templateLike;
  final Value<String> data;
  final Value<int> rowid;
  const InflectionTemplatesCompanion({
    this.pattern = const Value.absent(),
    this.templateLike = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InflectionTemplatesCompanion.insert({
    required String pattern,
    this.templateLike = const Value.absent(),
    required String data,
    this.rowid = const Value.absent(),
  }) : pattern = Value(pattern),
       data = Value(data);
  static Insertable<InflectionTemplate> custom({
    Expression<String>? pattern,
    Expression<String>? templateLike,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pattern != null) 'pattern': pattern,
      if (templateLike != null) 'like': templateLike,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InflectionTemplatesCompanion copyWith({
    Value<String>? pattern,
    Value<String?>? templateLike,
    Value<String>? data,
    Value<int>? rowid,
  }) {
    return InflectionTemplatesCompanion(
      pattern: pattern ?? this.pattern,
      templateLike: templateLike ?? this.templateLike,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (templateLike.present) {
      map['like'] = Variable<String>(templateLike.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InflectionTemplatesCompanion(')
          ..write('pattern: $pattern, ')
          ..write('templateLike: $templateLike, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyRootTable extends FamilyRoot
    with TableInfo<$FamilyRootTable, FamilyRootData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyRootTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rootFamilyKeyMeta = const VerificationMeta(
    'rootFamilyKey',
  );
  @override
  late final GeneratedColumn<String> rootFamilyKey = GeneratedColumn<String>(
    'root_family_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootKeyMeta = const VerificationMeta(
    'rootKey',
  );
  @override
  late final GeneratedColumn<String> rootKey = GeneratedColumn<String>(
    'root_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootFamilyMeta = const VerificationMeta(
    'rootFamily',
  );
  @override
  late final GeneratedColumn<String> rootFamily = GeneratedColumn<String>(
    'root_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootMeaningMeta = const VerificationMeta(
    'rootMeaning',
  );
  @override
  late final GeneratedColumn<String> rootMeaning = GeneratedColumn<String>(
    'root_meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rootFamilyKey,
    rootKey,
    rootFamily,
    rootMeaning,
    data,
    count,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_root';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyRootData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('root_family_key')) {
      context.handle(
        _rootFamilyKeyMeta,
        rootFamilyKey.isAcceptableOrUnknown(
          data['root_family_key']!,
          _rootFamilyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootFamilyKeyMeta);
    }
    if (data.containsKey('root_key')) {
      context.handle(
        _rootKeyMeta,
        rootKey.isAcceptableOrUnknown(data['root_key']!, _rootKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_rootKeyMeta);
    }
    if (data.containsKey('root_family')) {
      context.handle(
        _rootFamilyMeta,
        rootFamily.isAcceptableOrUnknown(data['root_family']!, _rootFamilyMeta),
      );
    } else if (isInserting) {
      context.missing(_rootFamilyMeta);
    }
    if (data.containsKey('root_meaning')) {
      context.handle(
        _rootMeaningMeta,
        rootMeaning.isAcceptableOrUnknown(
          data['root_meaning']!,
          _rootMeaningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rootMeaningMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rootFamilyKey};
  @override
  FamilyRootData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyRootData(
      rootFamilyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_family_key'],
      )!,
      rootKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_key'],
      )!,
      rootFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_family'],
      )!,
      rootMeaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}root_meaning'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $FamilyRootTable createAlias(String alias) {
    return $FamilyRootTable(attachedDatabase, alias);
  }
}

class FamilyRootData extends DataClass implements Insertable<FamilyRootData> {
  final String rootFamilyKey;
  final String rootKey;
  final String rootFamily;
  final String rootMeaning;
  final String data;
  final int count;
  const FamilyRootData({
    required this.rootFamilyKey,
    required this.rootKey,
    required this.rootFamily,
    required this.rootMeaning,
    required this.data,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['root_family_key'] = Variable<String>(rootFamilyKey);
    map['root_key'] = Variable<String>(rootKey);
    map['root_family'] = Variable<String>(rootFamily);
    map['root_meaning'] = Variable<String>(rootMeaning);
    map['data'] = Variable<String>(data);
    map['count'] = Variable<int>(count);
    return map;
  }

  FamilyRootCompanion toCompanion(bool nullToAbsent) {
    return FamilyRootCompanion(
      rootFamilyKey: Value(rootFamilyKey),
      rootKey: Value(rootKey),
      rootFamily: Value(rootFamily),
      rootMeaning: Value(rootMeaning),
      data: Value(data),
      count: Value(count),
    );
  }

  factory FamilyRootData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyRootData(
      rootFamilyKey: serializer.fromJson<String>(json['rootFamilyKey']),
      rootKey: serializer.fromJson<String>(json['rootKey']),
      rootFamily: serializer.fromJson<String>(json['rootFamily']),
      rootMeaning: serializer.fromJson<String>(json['rootMeaning']),
      data: serializer.fromJson<String>(json['data']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rootFamilyKey': serializer.toJson<String>(rootFamilyKey),
      'rootKey': serializer.toJson<String>(rootKey),
      'rootFamily': serializer.toJson<String>(rootFamily),
      'rootMeaning': serializer.toJson<String>(rootMeaning),
      'data': serializer.toJson<String>(data),
      'count': serializer.toJson<int>(count),
    };
  }

  FamilyRootData copyWith({
    String? rootFamilyKey,
    String? rootKey,
    String? rootFamily,
    String? rootMeaning,
    String? data,
    int? count,
  }) => FamilyRootData(
    rootFamilyKey: rootFamilyKey ?? this.rootFamilyKey,
    rootKey: rootKey ?? this.rootKey,
    rootFamily: rootFamily ?? this.rootFamily,
    rootMeaning: rootMeaning ?? this.rootMeaning,
    data: data ?? this.data,
    count: count ?? this.count,
  );
  FamilyRootData copyWithCompanion(FamilyRootCompanion data) {
    return FamilyRootData(
      rootFamilyKey: data.rootFamilyKey.present
          ? data.rootFamilyKey.value
          : this.rootFamilyKey,
      rootKey: data.rootKey.present ? data.rootKey.value : this.rootKey,
      rootFamily: data.rootFamily.present
          ? data.rootFamily.value
          : this.rootFamily,
      rootMeaning: data.rootMeaning.present
          ? data.rootMeaning.value
          : this.rootMeaning,
      data: data.data.present ? data.data.value : this.data,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyRootData(')
          ..write('rootFamilyKey: $rootFamilyKey, ')
          ..write('rootKey: $rootKey, ')
          ..write('rootFamily: $rootFamily, ')
          ..write('rootMeaning: $rootMeaning, ')
          ..write('data: $data, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(rootFamilyKey, rootKey, rootFamily, rootMeaning, data, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyRootData &&
          other.rootFamilyKey == this.rootFamilyKey &&
          other.rootKey == this.rootKey &&
          other.rootFamily == this.rootFamily &&
          other.rootMeaning == this.rootMeaning &&
          other.data == this.data &&
          other.count == this.count);
}

class FamilyRootCompanion extends UpdateCompanion<FamilyRootData> {
  final Value<String> rootFamilyKey;
  final Value<String> rootKey;
  final Value<String> rootFamily;
  final Value<String> rootMeaning;
  final Value<String> data;
  final Value<int> count;
  final Value<int> rowid;
  const FamilyRootCompanion({
    this.rootFamilyKey = const Value.absent(),
    this.rootKey = const Value.absent(),
    this.rootFamily = const Value.absent(),
    this.rootMeaning = const Value.absent(),
    this.data = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyRootCompanion.insert({
    required String rootFamilyKey,
    required String rootKey,
    required String rootFamily,
    required String rootMeaning,
    required String data,
    required int count,
    this.rowid = const Value.absent(),
  }) : rootFamilyKey = Value(rootFamilyKey),
       rootKey = Value(rootKey),
       rootFamily = Value(rootFamily),
       rootMeaning = Value(rootMeaning),
       data = Value(data),
       count = Value(count);
  static Insertable<FamilyRootData> custom({
    Expression<String>? rootFamilyKey,
    Expression<String>? rootKey,
    Expression<String>? rootFamily,
    Expression<String>? rootMeaning,
    Expression<String>? data,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rootFamilyKey != null) 'root_family_key': rootFamilyKey,
      if (rootKey != null) 'root_key': rootKey,
      if (rootFamily != null) 'root_family': rootFamily,
      if (rootMeaning != null) 'root_meaning': rootMeaning,
      if (data != null) 'data': data,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyRootCompanion copyWith({
    Value<String>? rootFamilyKey,
    Value<String>? rootKey,
    Value<String>? rootFamily,
    Value<String>? rootMeaning,
    Value<String>? data,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return FamilyRootCompanion(
      rootFamilyKey: rootFamilyKey ?? this.rootFamilyKey,
      rootKey: rootKey ?? this.rootKey,
      rootFamily: rootFamily ?? this.rootFamily,
      rootMeaning: rootMeaning ?? this.rootMeaning,
      data: data ?? this.data,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rootFamilyKey.present) {
      map['root_family_key'] = Variable<String>(rootFamilyKey.value);
    }
    if (rootKey.present) {
      map['root_key'] = Variable<String>(rootKey.value);
    }
    if (rootFamily.present) {
      map['root_family'] = Variable<String>(rootFamily.value);
    }
    if (rootMeaning.present) {
      map['root_meaning'] = Variable<String>(rootMeaning.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyRootCompanion(')
          ..write('rootFamilyKey: $rootFamilyKey, ')
          ..write('rootKey: $rootKey, ')
          ..write('rootFamily: $rootFamily, ')
          ..write('rootMeaning: $rootMeaning, ')
          ..write('data: $data, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyWordTable extends FamilyWord
    with TableInfo<$FamilyWordTable, FamilyWordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyWordTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordFamilyMeta = const VerificationMeta(
    'wordFamily',
  );
  @override
  late final GeneratedColumn<String> wordFamily = GeneratedColumn<String>(
    'word_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [wordFamily, data, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_word';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyWordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word_family')) {
      context.handle(
        _wordFamilyMeta,
        wordFamily.isAcceptableOrUnknown(data['word_family']!, _wordFamilyMeta),
      );
    } else if (isInserting) {
      context.missing(_wordFamilyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wordFamily};
  @override
  FamilyWordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyWordData(
      wordFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word_family'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $FamilyWordTable createAlias(String alias) {
    return $FamilyWordTable(attachedDatabase, alias);
  }
}

class FamilyWordData extends DataClass implements Insertable<FamilyWordData> {
  final String wordFamily;
  final String data;
  final int count;
  const FamilyWordData({
    required this.wordFamily,
    required this.data,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word_family'] = Variable<String>(wordFamily);
    map['data'] = Variable<String>(data);
    map['count'] = Variable<int>(count);
    return map;
  }

  FamilyWordCompanion toCompanion(bool nullToAbsent) {
    return FamilyWordCompanion(
      wordFamily: Value(wordFamily),
      data: Value(data),
      count: Value(count),
    );
  }

  factory FamilyWordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyWordData(
      wordFamily: serializer.fromJson<String>(json['wordFamily']),
      data: serializer.fromJson<String>(json['data']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wordFamily': serializer.toJson<String>(wordFamily),
      'data': serializer.toJson<String>(data),
      'count': serializer.toJson<int>(count),
    };
  }

  FamilyWordData copyWith({String? wordFamily, String? data, int? count}) =>
      FamilyWordData(
        wordFamily: wordFamily ?? this.wordFamily,
        data: data ?? this.data,
        count: count ?? this.count,
      );
  FamilyWordData copyWithCompanion(FamilyWordCompanion data) {
    return FamilyWordData(
      wordFamily: data.wordFamily.present
          ? data.wordFamily.value
          : this.wordFamily,
      data: data.data.present ? data.data.value : this.data,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyWordData(')
          ..write('wordFamily: $wordFamily, ')
          ..write('data: $data, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wordFamily, data, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyWordData &&
          other.wordFamily == this.wordFamily &&
          other.data == this.data &&
          other.count == this.count);
}

class FamilyWordCompanion extends UpdateCompanion<FamilyWordData> {
  final Value<String> wordFamily;
  final Value<String> data;
  final Value<int> count;
  final Value<int> rowid;
  const FamilyWordCompanion({
    this.wordFamily = const Value.absent(),
    this.data = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyWordCompanion.insert({
    required String wordFamily,
    required String data,
    required int count,
    this.rowid = const Value.absent(),
  }) : wordFamily = Value(wordFamily),
       data = Value(data),
       count = Value(count);
  static Insertable<FamilyWordData> custom({
    Expression<String>? wordFamily,
    Expression<String>? data,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (wordFamily != null) 'word_family': wordFamily,
      if (data != null) 'data': data,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyWordCompanion copyWith({
    Value<String>? wordFamily,
    Value<String>? data,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return FamilyWordCompanion(
      wordFamily: wordFamily ?? this.wordFamily,
      data: data ?? this.data,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wordFamily.present) {
      map['word_family'] = Variable<String>(wordFamily.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyWordCompanion(')
          ..write('wordFamily: $wordFamily, ')
          ..write('data: $data, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyCompoundTable extends FamilyCompound
    with TableInfo<$FamilyCompoundTable, FamilyCompoundData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyCompoundTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _compoundFamilyMeta = const VerificationMeta(
    'compoundFamily',
  );
  @override
  late final GeneratedColumn<String> compoundFamily = GeneratedColumn<String>(
    'compound_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [compoundFamily, data, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_compound';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyCompoundData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('compound_family')) {
      context.handle(
        _compoundFamilyMeta,
        compoundFamily.isAcceptableOrUnknown(
          data['compound_family']!,
          _compoundFamilyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compoundFamilyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {compoundFamily};
  @override
  FamilyCompoundData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyCompoundData(
      compoundFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compound_family'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $FamilyCompoundTable createAlias(String alias) {
    return $FamilyCompoundTable(attachedDatabase, alias);
  }
}

class FamilyCompoundData extends DataClass
    implements Insertable<FamilyCompoundData> {
  final String compoundFamily;
  final String data;
  final int count;
  const FamilyCompoundData({
    required this.compoundFamily,
    required this.data,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['compound_family'] = Variable<String>(compoundFamily);
    map['data'] = Variable<String>(data);
    map['count'] = Variable<int>(count);
    return map;
  }

  FamilyCompoundCompanion toCompanion(bool nullToAbsent) {
    return FamilyCompoundCompanion(
      compoundFamily: Value(compoundFamily),
      data: Value(data),
      count: Value(count),
    );
  }

  factory FamilyCompoundData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyCompoundData(
      compoundFamily: serializer.fromJson<String>(json['compoundFamily']),
      data: serializer.fromJson<String>(json['data']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'compoundFamily': serializer.toJson<String>(compoundFamily),
      'data': serializer.toJson<String>(data),
      'count': serializer.toJson<int>(count),
    };
  }

  FamilyCompoundData copyWith({
    String? compoundFamily,
    String? data,
    int? count,
  }) => FamilyCompoundData(
    compoundFamily: compoundFamily ?? this.compoundFamily,
    data: data ?? this.data,
    count: count ?? this.count,
  );
  FamilyCompoundData copyWithCompanion(FamilyCompoundCompanion data) {
    return FamilyCompoundData(
      compoundFamily: data.compoundFamily.present
          ? data.compoundFamily.value
          : this.compoundFamily,
      data: data.data.present ? data.data.value : this.data,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyCompoundData(')
          ..write('compoundFamily: $compoundFamily, ')
          ..write('data: $data, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(compoundFamily, data, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyCompoundData &&
          other.compoundFamily == this.compoundFamily &&
          other.data == this.data &&
          other.count == this.count);
}

class FamilyCompoundCompanion extends UpdateCompanion<FamilyCompoundData> {
  final Value<String> compoundFamily;
  final Value<String> data;
  final Value<int> count;
  final Value<int> rowid;
  const FamilyCompoundCompanion({
    this.compoundFamily = const Value.absent(),
    this.data = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyCompoundCompanion.insert({
    required String compoundFamily,
    required String data,
    required int count,
    this.rowid = const Value.absent(),
  }) : compoundFamily = Value(compoundFamily),
       data = Value(data),
       count = Value(count);
  static Insertable<FamilyCompoundData> custom({
    Expression<String>? compoundFamily,
    Expression<String>? data,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (compoundFamily != null) 'compound_family': compoundFamily,
      if (data != null) 'data': data,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyCompoundCompanion copyWith({
    Value<String>? compoundFamily,
    Value<String>? data,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return FamilyCompoundCompanion(
      compoundFamily: compoundFamily ?? this.compoundFamily,
      data: data ?? this.data,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (compoundFamily.present) {
      map['compound_family'] = Variable<String>(compoundFamily.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyCompoundCompanion(')
          ..write('compoundFamily: $compoundFamily, ')
          ..write('data: $data, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyIdiomTable extends FamilyIdiom
    with TableInfo<$FamilyIdiomTable, FamilyIdiomData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyIdiomTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idiomMeta = const VerificationMeta('idiom');
  @override
  late final GeneratedColumn<String> idiom = GeneratedColumn<String>(
    'idiom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [idiom, data, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_idiom';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyIdiomData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idiom')) {
      context.handle(
        _idiomMeta,
        idiom.isAcceptableOrUnknown(data['idiom']!, _idiomMeta),
      );
    } else if (isInserting) {
      context.missing(_idiomMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idiom};
  @override
  FamilyIdiomData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyIdiomData(
      idiom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idiom'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $FamilyIdiomTable createAlias(String alias) {
    return $FamilyIdiomTable(attachedDatabase, alias);
  }
}

class FamilyIdiomData extends DataClass implements Insertable<FamilyIdiomData> {
  final String idiom;
  final String data;
  final int count;
  const FamilyIdiomData({
    required this.idiom,
    required this.data,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idiom'] = Variable<String>(idiom);
    map['data'] = Variable<String>(data);
    map['count'] = Variable<int>(count);
    return map;
  }

  FamilyIdiomCompanion toCompanion(bool nullToAbsent) {
    return FamilyIdiomCompanion(
      idiom: Value(idiom),
      data: Value(data),
      count: Value(count),
    );
  }

  factory FamilyIdiomData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyIdiomData(
      idiom: serializer.fromJson<String>(json['idiom']),
      data: serializer.fromJson<String>(json['data']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idiom': serializer.toJson<String>(idiom),
      'data': serializer.toJson<String>(data),
      'count': serializer.toJson<int>(count),
    };
  }

  FamilyIdiomData copyWith({String? idiom, String? data, int? count}) =>
      FamilyIdiomData(
        idiom: idiom ?? this.idiom,
        data: data ?? this.data,
        count: count ?? this.count,
      );
  FamilyIdiomData copyWithCompanion(FamilyIdiomCompanion data) {
    return FamilyIdiomData(
      idiom: data.idiom.present ? data.idiom.value : this.idiom,
      data: data.data.present ? data.data.value : this.data,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyIdiomData(')
          ..write('idiom: $idiom, ')
          ..write('data: $data, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idiom, data, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyIdiomData &&
          other.idiom == this.idiom &&
          other.data == this.data &&
          other.count == this.count);
}

class FamilyIdiomCompanion extends UpdateCompanion<FamilyIdiomData> {
  final Value<String> idiom;
  final Value<String> data;
  final Value<int> count;
  final Value<int> rowid;
  const FamilyIdiomCompanion({
    this.idiom = const Value.absent(),
    this.data = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyIdiomCompanion.insert({
    required String idiom,
    required String data,
    required int count,
    this.rowid = const Value.absent(),
  }) : idiom = Value(idiom),
       data = Value(data),
       count = Value(count);
  static Insertable<FamilyIdiomData> custom({
    Expression<String>? idiom,
    Expression<String>? data,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idiom != null) 'idiom': idiom,
      if (data != null) 'data': data,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyIdiomCompanion copyWith({
    Value<String>? idiom,
    Value<String>? data,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return FamilyIdiomCompanion(
      idiom: idiom ?? this.idiom,
      data: data ?? this.data,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idiom.present) {
      map['idiom'] = Variable<String>(idiom.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyIdiomCompanion(')
          ..write('idiom: $idiom, ')
          ..write('data: $data, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilySetTable extends FamilySet
    with TableInfo<$FamilySetTable, FamilySetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilySetTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _set_Meta = const VerificationMeta('set_');
  @override
  late final GeneratedColumn<String> set_ = GeneratedColumn<String>(
    'set',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [set_, data, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_set';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilySetData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('set')) {
      context.handle(
        _set_Meta,
        set_.isAcceptableOrUnknown(data['set']!, _set_Meta),
      );
    } else if (isInserting) {
      context.missing(_set_Meta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {set_};
  @override
  FamilySetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilySetData(
      set_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $FamilySetTable createAlias(String alias) {
    return $FamilySetTable(attachedDatabase, alias);
  }
}

class FamilySetData extends DataClass implements Insertable<FamilySetData> {
  final String set_;
  final String data;
  final int count;
  const FamilySetData({
    required this.set_,
    required this.data,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['set'] = Variable<String>(set_);
    map['data'] = Variable<String>(data);
    map['count'] = Variable<int>(count);
    return map;
  }

  FamilySetCompanion toCompanion(bool nullToAbsent) {
    return FamilySetCompanion(
      set_: Value(set_),
      data: Value(data),
      count: Value(count),
    );
  }

  factory FamilySetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilySetData(
      set_: serializer.fromJson<String>(json['set_']),
      data: serializer.fromJson<String>(json['data']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'set_': serializer.toJson<String>(set_),
      'data': serializer.toJson<String>(data),
      'count': serializer.toJson<int>(count),
    };
  }

  FamilySetData copyWith({String? set_, String? data, int? count}) =>
      FamilySetData(
        set_: set_ ?? this.set_,
        data: data ?? this.data,
        count: count ?? this.count,
      );
  FamilySetData copyWithCompanion(FamilySetCompanion data) {
    return FamilySetData(
      set_: data.set_.present ? data.set_.value : this.set_,
      data: data.data.present ? data.data.value : this.data,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilySetData(')
          ..write('set_: $set_, ')
          ..write('data: $data, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(set_, data, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilySetData &&
          other.set_ == this.set_ &&
          other.data == this.data &&
          other.count == this.count);
}

class FamilySetCompanion extends UpdateCompanion<FamilySetData> {
  final Value<String> set_;
  final Value<String> data;
  final Value<int> count;
  final Value<int> rowid;
  const FamilySetCompanion({
    this.set_ = const Value.absent(),
    this.data = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilySetCompanion.insert({
    required String set_,
    required String data,
    required int count,
    this.rowid = const Value.absent(),
  }) : set_ = Value(set_),
       data = Value(data),
       count = Value(count);
  static Insertable<FamilySetData> custom({
    Expression<String>? set_,
    Expression<String>? data,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (set_ != null) 'set': set_,
      if (data != null) 'data': data,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilySetCompanion copyWith({
    Value<String>? set_,
    Value<String>? data,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return FamilySetCompanion(
      set_: set_ ?? this.set_,
      data: data ?? this.data,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (set_.present) {
      map['set'] = Variable<String>(set_.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilySetCompanion(')
          ..write('set_: $set_, ')
          ..write('data: $data, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DpdRootsTable dpdRoots = $DpdRootsTable(this);
  late final $DpdHeadwordsTable dpdHeadwords = $DpdHeadwordsTable(this);
  late final $LookupTable lookup = $LookupTable(this);
  late final $DbInfoTable dbInfo = $DbInfoTable(this);
  late final $InflectionTemplatesTable inflectionTemplates =
      $InflectionTemplatesTable(this);
  late final $FamilyRootTable familyRoot = $FamilyRootTable(this);
  late final $FamilyWordTable familyWord = $FamilyWordTable(this);
  late final $FamilyCompoundTable familyCompound = $FamilyCompoundTable(this);
  late final $FamilyIdiomTable familyIdiom = $FamilyIdiomTable(this);
  late final $FamilySetTable familySet = $FamilySetTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dpdRoots,
    dpdHeadwords,
    lookup,
    dbInfo,
    inflectionTemplates,
    familyRoot,
    familyWord,
    familyCompound,
    familyIdiom,
    familySet,
  ];
}

typedef $$DpdRootsTableCreateCompanionBuilder =
    DpdRootsCompanion Function({
      required String root,
      required String rootInComps,
      required String rootHasVerb,
      required int rootGroup,
      required String rootSign,
      required String rootMeaning,
      required String sanskritRoot,
      required String sanskritRootMeaning,
      required String sanskritRootClass,
      required String rootExample,
      required String rootInfo,
      Value<int> rowid,
    });
typedef $$DpdRootsTableUpdateCompanionBuilder =
    DpdRootsCompanion Function({
      Value<String> root,
      Value<String> rootInComps,
      Value<String> rootHasVerb,
      Value<int> rootGroup,
      Value<String> rootSign,
      Value<String> rootMeaning,
      Value<String> sanskritRoot,
      Value<String> sanskritRootMeaning,
      Value<String> sanskritRootClass,
      Value<String> rootExample,
      Value<String> rootInfo,
      Value<int> rowid,
    });

final class $$DpdRootsTableReferences
    extends BaseReferences<_$AppDatabase, $DpdRootsTable, DpdRoot> {
  $$DpdRootsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DpdHeadwordsTable, List<DpdHeadword>>
  _dpdHeadwordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.dpdHeadwords,
    aliasName: $_aliasNameGenerator(db.dpdRoots.root, db.dpdHeadwords.rootKey),
  );

  $$DpdHeadwordsTableProcessedTableManager get dpdHeadwordsRefs {
    final manager = $$DpdHeadwordsTableTableManager(
      $_db,
      $_db.dpdHeadwords,
    ).filter((f) => f.rootKey.root.sqlEquals($_itemColumn<String>('root')!));

    final cache = $_typedResult.readTableOrNull(_dpdHeadwordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DpdRootsTableFilterComposer
    extends Composer<_$AppDatabase, $DpdRootsTable> {
  $$DpdRootsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootInComps => $composableBuilder(
    column: $table.rootInComps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootHasVerb => $composableBuilder(
    column: $table.rootHasVerb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rootGroup => $composableBuilder(
    column: $table.rootGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootSign => $composableBuilder(
    column: $table.rootSign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanskritRoot => $composableBuilder(
    column: $table.sanskritRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanskritRootMeaning => $composableBuilder(
    column: $table.sanskritRootMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanskritRootClass => $composableBuilder(
    column: $table.sanskritRootClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootExample => $composableBuilder(
    column: $table.rootExample,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootInfo => $composableBuilder(
    column: $table.rootInfo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> dpdHeadwordsRefs(
    Expression<bool> Function($$DpdHeadwordsTableFilterComposer f) f,
  ) {
    final $$DpdHeadwordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.root,
      referencedTable: $db.dpdHeadwords,
      getReferencedColumn: (t) => t.rootKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DpdHeadwordsTableFilterComposer(
            $db: $db,
            $table: $db.dpdHeadwords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DpdRootsTableOrderingComposer
    extends Composer<_$AppDatabase, $DpdRootsTable> {
  $$DpdRootsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get root => $composableBuilder(
    column: $table.root,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootInComps => $composableBuilder(
    column: $table.rootInComps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootHasVerb => $composableBuilder(
    column: $table.rootHasVerb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rootGroup => $composableBuilder(
    column: $table.rootGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootSign => $composableBuilder(
    column: $table.rootSign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanskritRoot => $composableBuilder(
    column: $table.sanskritRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanskritRootMeaning => $composableBuilder(
    column: $table.sanskritRootMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanskritRootClass => $composableBuilder(
    column: $table.sanskritRootClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootExample => $composableBuilder(
    column: $table.rootExample,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootInfo => $composableBuilder(
    column: $table.rootInfo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DpdRootsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DpdRootsTable> {
  $$DpdRootsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get root =>
      $composableBuilder(column: $table.root, builder: (column) => column);

  GeneratedColumn<String> get rootInComps => $composableBuilder(
    column: $table.rootInComps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootHasVerb => $composableBuilder(
    column: $table.rootHasVerb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rootGroup =>
      $composableBuilder(column: $table.rootGroup, builder: (column) => column);

  GeneratedColumn<String> get rootSign =>
      $composableBuilder(column: $table.rootSign, builder: (column) => column);

  GeneratedColumn<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sanskritRoot => $composableBuilder(
    column: $table.sanskritRoot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sanskritRootMeaning => $composableBuilder(
    column: $table.sanskritRootMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sanskritRootClass => $composableBuilder(
    column: $table.sanskritRootClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootExample => $composableBuilder(
    column: $table.rootExample,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootInfo =>
      $composableBuilder(column: $table.rootInfo, builder: (column) => column);

  Expression<T> dpdHeadwordsRefs<T extends Object>(
    Expression<T> Function($$DpdHeadwordsTableAnnotationComposer a) f,
  ) {
    final $$DpdHeadwordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.root,
      referencedTable: $db.dpdHeadwords,
      getReferencedColumn: (t) => t.rootKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DpdHeadwordsTableAnnotationComposer(
            $db: $db,
            $table: $db.dpdHeadwords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DpdRootsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DpdRootsTable,
          DpdRoot,
          $$DpdRootsTableFilterComposer,
          $$DpdRootsTableOrderingComposer,
          $$DpdRootsTableAnnotationComposer,
          $$DpdRootsTableCreateCompanionBuilder,
          $$DpdRootsTableUpdateCompanionBuilder,
          (DpdRoot, $$DpdRootsTableReferences),
          DpdRoot,
          PrefetchHooks Function({bool dpdHeadwordsRefs})
        > {
  $$DpdRootsTableTableManager(_$AppDatabase db, $DpdRootsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DpdRootsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DpdRootsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DpdRootsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> root = const Value.absent(),
                Value<String> rootInComps = const Value.absent(),
                Value<String> rootHasVerb = const Value.absent(),
                Value<int> rootGroup = const Value.absent(),
                Value<String> rootSign = const Value.absent(),
                Value<String> rootMeaning = const Value.absent(),
                Value<String> sanskritRoot = const Value.absent(),
                Value<String> sanskritRootMeaning = const Value.absent(),
                Value<String> sanskritRootClass = const Value.absent(),
                Value<String> rootExample = const Value.absent(),
                Value<String> rootInfo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DpdRootsCompanion(
                root: root,
                rootInComps: rootInComps,
                rootHasVerb: rootHasVerb,
                rootGroup: rootGroup,
                rootSign: rootSign,
                rootMeaning: rootMeaning,
                sanskritRoot: sanskritRoot,
                sanskritRootMeaning: sanskritRootMeaning,
                sanskritRootClass: sanskritRootClass,
                rootExample: rootExample,
                rootInfo: rootInfo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String root,
                required String rootInComps,
                required String rootHasVerb,
                required int rootGroup,
                required String rootSign,
                required String rootMeaning,
                required String sanskritRoot,
                required String sanskritRootMeaning,
                required String sanskritRootClass,
                required String rootExample,
                required String rootInfo,
                Value<int> rowid = const Value.absent(),
              }) => DpdRootsCompanion.insert(
                root: root,
                rootInComps: rootInComps,
                rootHasVerb: rootHasVerb,
                rootGroup: rootGroup,
                rootSign: rootSign,
                rootMeaning: rootMeaning,
                sanskritRoot: sanskritRoot,
                sanskritRootMeaning: sanskritRootMeaning,
                sanskritRootClass: sanskritRootClass,
                rootExample: rootExample,
                rootInfo: rootInfo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DpdRootsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dpdHeadwordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (dpdHeadwordsRefs) db.dpdHeadwords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (dpdHeadwordsRefs)
                    await $_getPrefetchedData<
                      DpdRoot,
                      $DpdRootsTable,
                      DpdHeadword
                    >(
                      currentTable: table,
                      referencedTable: $$DpdRootsTableReferences
                          ._dpdHeadwordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DpdRootsTableReferences(
                        db,
                        table,
                        p0,
                      ).dpdHeadwordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.rootKey == item.root),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DpdRootsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DpdRootsTable,
      DpdRoot,
      $$DpdRootsTableFilterComposer,
      $$DpdRootsTableOrderingComposer,
      $$DpdRootsTableAnnotationComposer,
      $$DpdRootsTableCreateCompanionBuilder,
      $$DpdRootsTableUpdateCompanionBuilder,
      (DpdRoot, $$DpdRootsTableReferences),
      DpdRoot,
      PrefetchHooks Function({bool dpdHeadwordsRefs})
    >;
typedef $$DpdHeadwordsTableCreateCompanionBuilder =
    DpdHeadwordsCompanion Function({
      Value<int> id,
      required String lemma1,
      Value<String?> lemma2,
      Value<String?> pos,
      Value<String?> grammar,
      Value<String?> derivedFrom,
      Value<String?> neg,
      Value<String?> verb,
      Value<String?> trans,
      Value<String?> plusCase,
      Value<String?> derivative,
      Value<String?> meaning1,
      Value<String?> meaningLit,
      Value<String?> meaning2,
      Value<String?> rootKey,
      Value<String?> rootSign,
      Value<String?> rootBase,
      Value<String?> familyRoot,
      Value<String?> familyWord,
      Value<String?> familyCompound,
      Value<String?> familyIdioms,
      Value<String?> familySet,
      Value<String?> construction,
      Value<String?> compoundType,
      Value<String?> compoundConstruction,
      Value<String?> source1,
      Value<String?> sutta1,
      Value<String?> example1,
      Value<String?> source2,
      Value<String?> sutta2,
      Value<String?> example2,
      Value<String?> antonym,
      Value<String?> synonym,
      Value<String?> variant,
      Value<String?> stem,
      Value<String?> pattern,
      Value<String?> suffix,
      Value<String?> inflectionsHtml,
      Value<String?> freqHtml,
      Value<int?> ebtCount,
      Value<String?> nonIa,
      Value<String?> sanskrit,
      Value<String?> cognate,
      Value<String?> link,
      Value<String?> phonetic,
      Value<String?> varPhonetic,
      Value<String?> varText,
      Value<String?> origin,
      Value<String?> notes,
      Value<String?> commentary,
    });
typedef $$DpdHeadwordsTableUpdateCompanionBuilder =
    DpdHeadwordsCompanion Function({
      Value<int> id,
      Value<String> lemma1,
      Value<String?> lemma2,
      Value<String?> pos,
      Value<String?> grammar,
      Value<String?> derivedFrom,
      Value<String?> neg,
      Value<String?> verb,
      Value<String?> trans,
      Value<String?> plusCase,
      Value<String?> derivative,
      Value<String?> meaning1,
      Value<String?> meaningLit,
      Value<String?> meaning2,
      Value<String?> rootKey,
      Value<String?> rootSign,
      Value<String?> rootBase,
      Value<String?> familyRoot,
      Value<String?> familyWord,
      Value<String?> familyCompound,
      Value<String?> familyIdioms,
      Value<String?> familySet,
      Value<String?> construction,
      Value<String?> compoundType,
      Value<String?> compoundConstruction,
      Value<String?> source1,
      Value<String?> sutta1,
      Value<String?> example1,
      Value<String?> source2,
      Value<String?> sutta2,
      Value<String?> example2,
      Value<String?> antonym,
      Value<String?> synonym,
      Value<String?> variant,
      Value<String?> stem,
      Value<String?> pattern,
      Value<String?> suffix,
      Value<String?> inflectionsHtml,
      Value<String?> freqHtml,
      Value<int?> ebtCount,
      Value<String?> nonIa,
      Value<String?> sanskrit,
      Value<String?> cognate,
      Value<String?> link,
      Value<String?> phonetic,
      Value<String?> varPhonetic,
      Value<String?> varText,
      Value<String?> origin,
      Value<String?> notes,
      Value<String?> commentary,
    });

final class $$DpdHeadwordsTableReferences
    extends BaseReferences<_$AppDatabase, $DpdHeadwordsTable, DpdHeadword> {
  $$DpdHeadwordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DpdRootsTable _rootKeyTable(_$AppDatabase db) =>
      db.dpdRoots.createAlias(
        $_aliasNameGenerator(db.dpdHeadwords.rootKey, db.dpdRoots.root),
      );

  $$DpdRootsTableProcessedTableManager? get rootKey {
    final $_column = $_itemColumn<String>('root_key');
    if ($_column == null) return null;
    final manager = $$DpdRootsTableTableManager(
      $_db,
      $_db.dpdRoots,
    ).filter((f) => f.root.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rootKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DpdHeadwordsTableFilterComposer
    extends Composer<_$AppDatabase, $DpdHeadwordsTable> {
  $$DpdHeadwordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma1 => $composableBuilder(
    column: $table.lemma1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma2 => $composableBuilder(
    column: $table.lemma2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivedFrom => $composableBuilder(
    column: $table.derivedFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get neg => $composableBuilder(
    column: $table.neg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verb => $composableBuilder(
    column: $table.verb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trans => $composableBuilder(
    column: $table.trans,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plusCase => $composableBuilder(
    column: $table.plusCase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivative => $composableBuilder(
    column: $table.derivative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning1 => $composableBuilder(
    column: $table.meaning1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningLit => $composableBuilder(
    column: $table.meaningLit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning2 => $composableBuilder(
    column: $table.meaning2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootSign => $composableBuilder(
    column: $table.rootSign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootBase => $composableBuilder(
    column: $table.rootBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyRoot => $composableBuilder(
    column: $table.familyRoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyWord => $composableBuilder(
    column: $table.familyWord,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyCompound => $composableBuilder(
    column: $table.familyCompound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyIdioms => $composableBuilder(
    column: $table.familyIdioms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familySet => $composableBuilder(
    column: $table.familySet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get construction => $composableBuilder(
    column: $table.construction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundType => $composableBuilder(
    column: $table.compoundType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compoundConstruction => $composableBuilder(
    column: $table.compoundConstruction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source1 => $composableBuilder(
    column: $table.source1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sutta1 => $composableBuilder(
    column: $table.sutta1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example1 => $composableBuilder(
    column: $table.example1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source2 => $composableBuilder(
    column: $table.source2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sutta2 => $composableBuilder(
    column: $table.sutta2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example2 => $composableBuilder(
    column: $table.example2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get antonym => $composableBuilder(
    column: $table.antonym,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inflectionsHtml => $composableBuilder(
    column: $table.inflectionsHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freqHtml => $composableBuilder(
    column: $table.freqHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ebtCount => $composableBuilder(
    column: $table.ebtCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonIa => $composableBuilder(
    column: $table.nonIa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sanskrit => $composableBuilder(
    column: $table.sanskrit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cognate => $composableBuilder(
    column: $table.cognate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get varPhonetic => $composableBuilder(
    column: $table.varPhonetic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get varText => $composableBuilder(
    column: $table.varText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commentary => $composableBuilder(
    column: $table.commentary,
    builder: (column) => ColumnFilters(column),
  );

  $$DpdRootsTableFilterComposer get rootKey {
    final $$DpdRootsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootKey,
      referencedTable: $db.dpdRoots,
      getReferencedColumn: (t) => t.root,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DpdRootsTableFilterComposer(
            $db: $db,
            $table: $db.dpdRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DpdHeadwordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DpdHeadwordsTable> {
  $$DpdHeadwordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma1 => $composableBuilder(
    column: $table.lemma1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma2 => $composableBuilder(
    column: $table.lemma2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivedFrom => $composableBuilder(
    column: $table.derivedFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get neg => $composableBuilder(
    column: $table.neg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verb => $composableBuilder(
    column: $table.verb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trans => $composableBuilder(
    column: $table.trans,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plusCase => $composableBuilder(
    column: $table.plusCase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivative => $composableBuilder(
    column: $table.derivative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning1 => $composableBuilder(
    column: $table.meaning1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningLit => $composableBuilder(
    column: $table.meaningLit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning2 => $composableBuilder(
    column: $table.meaning2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootSign => $composableBuilder(
    column: $table.rootSign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootBase => $composableBuilder(
    column: $table.rootBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyRoot => $composableBuilder(
    column: $table.familyRoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyWord => $composableBuilder(
    column: $table.familyWord,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyCompound => $composableBuilder(
    column: $table.familyCompound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyIdioms => $composableBuilder(
    column: $table.familyIdioms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familySet => $composableBuilder(
    column: $table.familySet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get construction => $composableBuilder(
    column: $table.construction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundType => $composableBuilder(
    column: $table.compoundType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compoundConstruction => $composableBuilder(
    column: $table.compoundConstruction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source1 => $composableBuilder(
    column: $table.source1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sutta1 => $composableBuilder(
    column: $table.sutta1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example1 => $composableBuilder(
    column: $table.example1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source2 => $composableBuilder(
    column: $table.source2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sutta2 => $composableBuilder(
    column: $table.sutta2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example2 => $composableBuilder(
    column: $table.example2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get antonym => $composableBuilder(
    column: $table.antonym,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get synonym => $composableBuilder(
    column: $table.synonym,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suffix => $composableBuilder(
    column: $table.suffix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inflectionsHtml => $composableBuilder(
    column: $table.inflectionsHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freqHtml => $composableBuilder(
    column: $table.freqHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ebtCount => $composableBuilder(
    column: $table.ebtCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonIa => $composableBuilder(
    column: $table.nonIa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sanskrit => $composableBuilder(
    column: $table.sanskrit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cognate => $composableBuilder(
    column: $table.cognate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phonetic => $composableBuilder(
    column: $table.phonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get varPhonetic => $composableBuilder(
    column: $table.varPhonetic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get varText => $composableBuilder(
    column: $table.varText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commentary => $composableBuilder(
    column: $table.commentary,
    builder: (column) => ColumnOrderings(column),
  );

  $$DpdRootsTableOrderingComposer get rootKey {
    final $$DpdRootsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootKey,
      referencedTable: $db.dpdRoots,
      getReferencedColumn: (t) => t.root,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DpdRootsTableOrderingComposer(
            $db: $db,
            $table: $db.dpdRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DpdHeadwordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DpdHeadwordsTable> {
  $$DpdHeadwordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lemma1 =>
      $composableBuilder(column: $table.lemma1, builder: (column) => column);

  GeneratedColumn<String> get lemma2 =>
      $composableBuilder(column: $table.lemma2, builder: (column) => column);

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumn<String> get grammar =>
      $composableBuilder(column: $table.grammar, builder: (column) => column);

  GeneratedColumn<String> get derivedFrom => $composableBuilder(
    column: $table.derivedFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get neg =>
      $composableBuilder(column: $table.neg, builder: (column) => column);

  GeneratedColumn<String> get verb =>
      $composableBuilder(column: $table.verb, builder: (column) => column);

  GeneratedColumn<String> get trans =>
      $composableBuilder(column: $table.trans, builder: (column) => column);

  GeneratedColumn<String> get plusCase =>
      $composableBuilder(column: $table.plusCase, builder: (column) => column);

  GeneratedColumn<String> get derivative => $composableBuilder(
    column: $table.derivative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning1 =>
      $composableBuilder(column: $table.meaning1, builder: (column) => column);

  GeneratedColumn<String> get meaningLit => $composableBuilder(
    column: $table.meaningLit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning2 =>
      $composableBuilder(column: $table.meaning2, builder: (column) => column);

  GeneratedColumn<String> get rootSign =>
      $composableBuilder(column: $table.rootSign, builder: (column) => column);

  GeneratedColumn<String> get rootBase =>
      $composableBuilder(column: $table.rootBase, builder: (column) => column);

  GeneratedColumn<String> get familyRoot => $composableBuilder(
    column: $table.familyRoot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyWord => $composableBuilder(
    column: $table.familyWord,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyCompound => $composableBuilder(
    column: $table.familyCompound,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyIdioms => $composableBuilder(
    column: $table.familyIdioms,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familySet =>
      $composableBuilder(column: $table.familySet, builder: (column) => column);

  GeneratedColumn<String> get construction => $composableBuilder(
    column: $table.construction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundType => $composableBuilder(
    column: $table.compoundType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get compoundConstruction => $composableBuilder(
    column: $table.compoundConstruction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source1 =>
      $composableBuilder(column: $table.source1, builder: (column) => column);

  GeneratedColumn<String> get sutta1 =>
      $composableBuilder(column: $table.sutta1, builder: (column) => column);

  GeneratedColumn<String> get example1 =>
      $composableBuilder(column: $table.example1, builder: (column) => column);

  GeneratedColumn<String> get source2 =>
      $composableBuilder(column: $table.source2, builder: (column) => column);

  GeneratedColumn<String> get sutta2 =>
      $composableBuilder(column: $table.sutta2, builder: (column) => column);

  GeneratedColumn<String> get example2 =>
      $composableBuilder(column: $table.example2, builder: (column) => column);

  GeneratedColumn<String> get antonym =>
      $composableBuilder(column: $table.antonym, builder: (column) => column);

  GeneratedColumn<String> get synonym =>
      $composableBuilder(column: $table.synonym, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get suffix =>
      $composableBuilder(column: $table.suffix, builder: (column) => column);

  GeneratedColumn<String> get inflectionsHtml => $composableBuilder(
    column: $table.inflectionsHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freqHtml =>
      $composableBuilder(column: $table.freqHtml, builder: (column) => column);

  GeneratedColumn<int> get ebtCount =>
      $composableBuilder(column: $table.ebtCount, builder: (column) => column);

  GeneratedColumn<String> get nonIa =>
      $composableBuilder(column: $table.nonIa, builder: (column) => column);

  GeneratedColumn<String> get sanskrit =>
      $composableBuilder(column: $table.sanskrit, builder: (column) => column);

  GeneratedColumn<String> get cognate =>
      $composableBuilder(column: $table.cognate, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get varPhonetic => $composableBuilder(
    column: $table.varPhonetic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get varText =>
      $composableBuilder(column: $table.varText, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get commentary => $composableBuilder(
    column: $table.commentary,
    builder: (column) => column,
  );

  $$DpdRootsTableAnnotationComposer get rootKey {
    final $$DpdRootsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rootKey,
      referencedTable: $db.dpdRoots,
      getReferencedColumn: (t) => t.root,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DpdRootsTableAnnotationComposer(
            $db: $db,
            $table: $db.dpdRoots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DpdHeadwordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DpdHeadwordsTable,
          DpdHeadword,
          $$DpdHeadwordsTableFilterComposer,
          $$DpdHeadwordsTableOrderingComposer,
          $$DpdHeadwordsTableAnnotationComposer,
          $$DpdHeadwordsTableCreateCompanionBuilder,
          $$DpdHeadwordsTableUpdateCompanionBuilder,
          (DpdHeadword, $$DpdHeadwordsTableReferences),
          DpdHeadword,
          PrefetchHooks Function({bool rootKey})
        > {
  $$DpdHeadwordsTableTableManager(_$AppDatabase db, $DpdHeadwordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DpdHeadwordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DpdHeadwordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DpdHeadwordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> lemma1 = const Value.absent(),
                Value<String?> lemma2 = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> derivedFrom = const Value.absent(),
                Value<String?> neg = const Value.absent(),
                Value<String?> verb = const Value.absent(),
                Value<String?> trans = const Value.absent(),
                Value<String?> plusCase = const Value.absent(),
                Value<String?> derivative = const Value.absent(),
                Value<String?> meaning1 = const Value.absent(),
                Value<String?> meaningLit = const Value.absent(),
                Value<String?> meaning2 = const Value.absent(),
                Value<String?> rootKey = const Value.absent(),
                Value<String?> rootSign = const Value.absent(),
                Value<String?> rootBase = const Value.absent(),
                Value<String?> familyRoot = const Value.absent(),
                Value<String?> familyWord = const Value.absent(),
                Value<String?> familyCompound = const Value.absent(),
                Value<String?> familyIdioms = const Value.absent(),
                Value<String?> familySet = const Value.absent(),
                Value<String?> construction = const Value.absent(),
                Value<String?> compoundType = const Value.absent(),
                Value<String?> compoundConstruction = const Value.absent(),
                Value<String?> source1 = const Value.absent(),
                Value<String?> sutta1 = const Value.absent(),
                Value<String?> example1 = const Value.absent(),
                Value<String?> source2 = const Value.absent(),
                Value<String?> sutta2 = const Value.absent(),
                Value<String?> example2 = const Value.absent(),
                Value<String?> antonym = const Value.absent(),
                Value<String?> synonym = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<String?> stem = const Value.absent(),
                Value<String?> pattern = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> inflectionsHtml = const Value.absent(),
                Value<String?> freqHtml = const Value.absent(),
                Value<int?> ebtCount = const Value.absent(),
                Value<String?> nonIa = const Value.absent(),
                Value<String?> sanskrit = const Value.absent(),
                Value<String?> cognate = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> varPhonetic = const Value.absent(),
                Value<String?> varText = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> commentary = const Value.absent(),
              }) => DpdHeadwordsCompanion(
                id: id,
                lemma1: lemma1,
                lemma2: lemma2,
                pos: pos,
                grammar: grammar,
                derivedFrom: derivedFrom,
                neg: neg,
                verb: verb,
                trans: trans,
                plusCase: plusCase,
                derivative: derivative,
                meaning1: meaning1,
                meaningLit: meaningLit,
                meaning2: meaning2,
                rootKey: rootKey,
                rootSign: rootSign,
                rootBase: rootBase,
                familyRoot: familyRoot,
                familyWord: familyWord,
                familyCompound: familyCompound,
                familyIdioms: familyIdioms,
                familySet: familySet,
                construction: construction,
                compoundType: compoundType,
                compoundConstruction: compoundConstruction,
                source1: source1,
                sutta1: sutta1,
                example1: example1,
                source2: source2,
                sutta2: sutta2,
                example2: example2,
                antonym: antonym,
                synonym: synonym,
                variant: variant,
                stem: stem,
                pattern: pattern,
                suffix: suffix,
                inflectionsHtml: inflectionsHtml,
                freqHtml: freqHtml,
                ebtCount: ebtCount,
                nonIa: nonIa,
                sanskrit: sanskrit,
                cognate: cognate,
                link: link,
                phonetic: phonetic,
                varPhonetic: varPhonetic,
                varText: varText,
                origin: origin,
                notes: notes,
                commentary: commentary,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String lemma1,
                Value<String?> lemma2 = const Value.absent(),
                Value<String?> pos = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> derivedFrom = const Value.absent(),
                Value<String?> neg = const Value.absent(),
                Value<String?> verb = const Value.absent(),
                Value<String?> trans = const Value.absent(),
                Value<String?> plusCase = const Value.absent(),
                Value<String?> derivative = const Value.absent(),
                Value<String?> meaning1 = const Value.absent(),
                Value<String?> meaningLit = const Value.absent(),
                Value<String?> meaning2 = const Value.absent(),
                Value<String?> rootKey = const Value.absent(),
                Value<String?> rootSign = const Value.absent(),
                Value<String?> rootBase = const Value.absent(),
                Value<String?> familyRoot = const Value.absent(),
                Value<String?> familyWord = const Value.absent(),
                Value<String?> familyCompound = const Value.absent(),
                Value<String?> familyIdioms = const Value.absent(),
                Value<String?> familySet = const Value.absent(),
                Value<String?> construction = const Value.absent(),
                Value<String?> compoundType = const Value.absent(),
                Value<String?> compoundConstruction = const Value.absent(),
                Value<String?> source1 = const Value.absent(),
                Value<String?> sutta1 = const Value.absent(),
                Value<String?> example1 = const Value.absent(),
                Value<String?> source2 = const Value.absent(),
                Value<String?> sutta2 = const Value.absent(),
                Value<String?> example2 = const Value.absent(),
                Value<String?> antonym = const Value.absent(),
                Value<String?> synonym = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<String?> stem = const Value.absent(),
                Value<String?> pattern = const Value.absent(),
                Value<String?> suffix = const Value.absent(),
                Value<String?> inflectionsHtml = const Value.absent(),
                Value<String?> freqHtml = const Value.absent(),
                Value<int?> ebtCount = const Value.absent(),
                Value<String?> nonIa = const Value.absent(),
                Value<String?> sanskrit = const Value.absent(),
                Value<String?> cognate = const Value.absent(),
                Value<String?> link = const Value.absent(),
                Value<String?> phonetic = const Value.absent(),
                Value<String?> varPhonetic = const Value.absent(),
                Value<String?> varText = const Value.absent(),
                Value<String?> origin = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> commentary = const Value.absent(),
              }) => DpdHeadwordsCompanion.insert(
                id: id,
                lemma1: lemma1,
                lemma2: lemma2,
                pos: pos,
                grammar: grammar,
                derivedFrom: derivedFrom,
                neg: neg,
                verb: verb,
                trans: trans,
                plusCase: plusCase,
                derivative: derivative,
                meaning1: meaning1,
                meaningLit: meaningLit,
                meaning2: meaning2,
                rootKey: rootKey,
                rootSign: rootSign,
                rootBase: rootBase,
                familyRoot: familyRoot,
                familyWord: familyWord,
                familyCompound: familyCompound,
                familyIdioms: familyIdioms,
                familySet: familySet,
                construction: construction,
                compoundType: compoundType,
                compoundConstruction: compoundConstruction,
                source1: source1,
                sutta1: sutta1,
                example1: example1,
                source2: source2,
                sutta2: sutta2,
                example2: example2,
                antonym: antonym,
                synonym: synonym,
                variant: variant,
                stem: stem,
                pattern: pattern,
                suffix: suffix,
                inflectionsHtml: inflectionsHtml,
                freqHtml: freqHtml,
                ebtCount: ebtCount,
                nonIa: nonIa,
                sanskrit: sanskrit,
                cognate: cognate,
                link: link,
                phonetic: phonetic,
                varPhonetic: varPhonetic,
                varText: varText,
                origin: origin,
                notes: notes,
                commentary: commentary,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DpdHeadwordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rootKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rootKey) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rootKey,
                                referencedTable: $$DpdHeadwordsTableReferences
                                    ._rootKeyTable(db),
                                referencedColumn: $$DpdHeadwordsTableReferences
                                    ._rootKeyTable(db)
                                    .root,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DpdHeadwordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DpdHeadwordsTable,
      DpdHeadword,
      $$DpdHeadwordsTableFilterComposer,
      $$DpdHeadwordsTableOrderingComposer,
      $$DpdHeadwordsTableAnnotationComposer,
      $$DpdHeadwordsTableCreateCompanionBuilder,
      $$DpdHeadwordsTableUpdateCompanionBuilder,
      (DpdHeadword, $$DpdHeadwordsTableReferences),
      DpdHeadword,
      PrefetchHooks Function({bool rootKey})
    >;
typedef $$LookupTableCreateCompanionBuilder =
    LookupCompanion Function({
      required String lookupKey,
      Value<String?> headwords,
      Value<String?> roots,
      Value<String?> variant,
      Value<String?> see,
      Value<String?> spelling,
      Value<String?> grammar,
      Value<String?> help,
      Value<String?> abbrev,
      Value<int> rowid,
    });
typedef $$LookupTableUpdateCompanionBuilder =
    LookupCompanion Function({
      Value<String> lookupKey,
      Value<String?> headwords,
      Value<String?> roots,
      Value<String?> variant,
      Value<String?> see,
      Value<String?> spelling,
      Value<String?> grammar,
      Value<String?> help,
      Value<String?> abbrev,
      Value<int> rowid,
    });

class $$LookupTableFilterComposer
    extends Composer<_$AppDatabase, $LookupTable> {
  $$LookupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lookupKey => $composableBuilder(
    column: $table.lookupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headwords => $composableBuilder(
    column: $table.headwords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roots => $composableBuilder(
    column: $table.roots,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get see => $composableBuilder(
    column: $table.see,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spelling => $composableBuilder(
    column: $table.spelling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get help => $composableBuilder(
    column: $table.help,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get abbrev => $composableBuilder(
    column: $table.abbrev,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LookupTableOrderingComposer
    extends Composer<_$AppDatabase, $LookupTable> {
  $$LookupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lookupKey => $composableBuilder(
    column: $table.lookupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headwords => $composableBuilder(
    column: $table.headwords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roots => $composableBuilder(
    column: $table.roots,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get see => $composableBuilder(
    column: $table.see,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spelling => $composableBuilder(
    column: $table.spelling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grammar => $composableBuilder(
    column: $table.grammar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get help => $composableBuilder(
    column: $table.help,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abbrev => $composableBuilder(
    column: $table.abbrev,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LookupTableAnnotationComposer
    extends Composer<_$AppDatabase, $LookupTable> {
  $$LookupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lookupKey =>
      $composableBuilder(column: $table.lookupKey, builder: (column) => column);

  GeneratedColumn<String> get headwords =>
      $composableBuilder(column: $table.headwords, builder: (column) => column);

  GeneratedColumn<String> get roots =>
      $composableBuilder(column: $table.roots, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get see =>
      $composableBuilder(column: $table.see, builder: (column) => column);

  GeneratedColumn<String> get spelling =>
      $composableBuilder(column: $table.spelling, builder: (column) => column);

  GeneratedColumn<String> get grammar =>
      $composableBuilder(column: $table.grammar, builder: (column) => column);

  GeneratedColumn<String> get help =>
      $composableBuilder(column: $table.help, builder: (column) => column);

  GeneratedColumn<String> get abbrev =>
      $composableBuilder(column: $table.abbrev, builder: (column) => column);
}

class $$LookupTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LookupTable,
          LookupData,
          $$LookupTableFilterComposer,
          $$LookupTableOrderingComposer,
          $$LookupTableAnnotationComposer,
          $$LookupTableCreateCompanionBuilder,
          $$LookupTableUpdateCompanionBuilder,
          (LookupData, BaseReferences<_$AppDatabase, $LookupTable, LookupData>),
          LookupData,
          PrefetchHooks Function()
        > {
  $$LookupTableTableManager(_$AppDatabase db, $LookupTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LookupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LookupTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LookupTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> lookupKey = const Value.absent(),
                Value<String?> headwords = const Value.absent(),
                Value<String?> roots = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<String?> see = const Value.absent(),
                Value<String?> spelling = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> help = const Value.absent(),
                Value<String?> abbrev = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LookupCompanion(
                lookupKey: lookupKey,
                headwords: headwords,
                roots: roots,
                variant: variant,
                see: see,
                spelling: spelling,
                grammar: grammar,
                help: help,
                abbrev: abbrev,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lookupKey,
                Value<String?> headwords = const Value.absent(),
                Value<String?> roots = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<String?> see = const Value.absent(),
                Value<String?> spelling = const Value.absent(),
                Value<String?> grammar = const Value.absent(),
                Value<String?> help = const Value.absent(),
                Value<String?> abbrev = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LookupCompanion.insert(
                lookupKey: lookupKey,
                headwords: headwords,
                roots: roots,
                variant: variant,
                see: see,
                spelling: spelling,
                grammar: grammar,
                help: help,
                abbrev: abbrev,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LookupTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LookupTable,
      LookupData,
      $$LookupTableFilterComposer,
      $$LookupTableOrderingComposer,
      $$LookupTableAnnotationComposer,
      $$LookupTableCreateCompanionBuilder,
      $$LookupTableUpdateCompanionBuilder,
      (LookupData, BaseReferences<_$AppDatabase, $LookupTable, LookupData>),
      LookupData,
      PrefetchHooks Function()
    >;
typedef $$DbInfoTableCreateCompanionBuilder =
    DbInfoCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$DbInfoTableUpdateCompanionBuilder =
    DbInfoCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$DbInfoTableFilterComposer
    extends Composer<_$AppDatabase, $DbInfoTable> {
  $$DbInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DbInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $DbInfoTable> {
  $$DbInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DbInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $DbInfoTable> {
  $$DbInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DbInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DbInfoTable,
          DbInfoData,
          $$DbInfoTableFilterComposer,
          $$DbInfoTableOrderingComposer,
          $$DbInfoTableAnnotationComposer,
          $$DbInfoTableCreateCompanionBuilder,
          $$DbInfoTableUpdateCompanionBuilder,
          (DbInfoData, BaseReferences<_$AppDatabase, $DbInfoTable, DbInfoData>),
          DbInfoData,
          PrefetchHooks Function()
        > {
  $$DbInfoTableTableManager(_$AppDatabase db, $DbInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DbInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DbInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DbInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DbInfoCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  DbInfoCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DbInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DbInfoTable,
      DbInfoData,
      $$DbInfoTableFilterComposer,
      $$DbInfoTableOrderingComposer,
      $$DbInfoTableAnnotationComposer,
      $$DbInfoTableCreateCompanionBuilder,
      $$DbInfoTableUpdateCompanionBuilder,
      (DbInfoData, BaseReferences<_$AppDatabase, $DbInfoTable, DbInfoData>),
      DbInfoData,
      PrefetchHooks Function()
    >;
typedef $$InflectionTemplatesTableCreateCompanionBuilder =
    InflectionTemplatesCompanion Function({
      required String pattern,
      Value<String?> templateLike,
      required String data,
      Value<int> rowid,
    });
typedef $$InflectionTemplatesTableUpdateCompanionBuilder =
    InflectionTemplatesCompanion Function({
      Value<String> pattern,
      Value<String?> templateLike,
      Value<String> data,
      Value<int> rowid,
    });

class $$InflectionTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $InflectionTemplatesTable> {
  $$InflectionTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateLike => $composableBuilder(
    column: $table.templateLike,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InflectionTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $InflectionTemplatesTable> {
  $$InflectionTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateLike => $composableBuilder(
    column: $table.templateLike,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InflectionTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InflectionTemplatesTable> {
  $$InflectionTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get templateLike => $composableBuilder(
    column: $table.templateLike,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$InflectionTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InflectionTemplatesTable,
          InflectionTemplate,
          $$InflectionTemplatesTableFilterComposer,
          $$InflectionTemplatesTableOrderingComposer,
          $$InflectionTemplatesTableAnnotationComposer,
          $$InflectionTemplatesTableCreateCompanionBuilder,
          $$InflectionTemplatesTableUpdateCompanionBuilder,
          (
            InflectionTemplate,
            BaseReferences<
              _$AppDatabase,
              $InflectionTemplatesTable,
              InflectionTemplate
            >,
          ),
          InflectionTemplate,
          PrefetchHooks Function()
        > {
  $$InflectionTemplatesTableTableManager(
    _$AppDatabase db,
    $InflectionTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InflectionTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InflectionTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InflectionTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> pattern = const Value.absent(),
                Value<String?> templateLike = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InflectionTemplatesCompanion(
                pattern: pattern,
                templateLike: templateLike,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pattern,
                Value<String?> templateLike = const Value.absent(),
                required String data,
                Value<int> rowid = const Value.absent(),
              }) => InflectionTemplatesCompanion.insert(
                pattern: pattern,
                templateLike: templateLike,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InflectionTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InflectionTemplatesTable,
      InflectionTemplate,
      $$InflectionTemplatesTableFilterComposer,
      $$InflectionTemplatesTableOrderingComposer,
      $$InflectionTemplatesTableAnnotationComposer,
      $$InflectionTemplatesTableCreateCompanionBuilder,
      $$InflectionTemplatesTableUpdateCompanionBuilder,
      (
        InflectionTemplate,
        BaseReferences<
          _$AppDatabase,
          $InflectionTemplatesTable,
          InflectionTemplate
        >,
      ),
      InflectionTemplate,
      PrefetchHooks Function()
    >;
typedef $$FamilyRootTableCreateCompanionBuilder =
    FamilyRootCompanion Function({
      required String rootFamilyKey,
      required String rootKey,
      required String rootFamily,
      required String rootMeaning,
      required String data,
      required int count,
      Value<int> rowid,
    });
typedef $$FamilyRootTableUpdateCompanionBuilder =
    FamilyRootCompanion Function({
      Value<String> rootFamilyKey,
      Value<String> rootKey,
      Value<String> rootFamily,
      Value<String> rootMeaning,
      Value<String> data,
      Value<int> count,
      Value<int> rowid,
    });

class $$FamilyRootTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyRootTable> {
  $$FamilyRootTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get rootFamilyKey => $composableBuilder(
    column: $table.rootFamilyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootKey => $composableBuilder(
    column: $table.rootKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootFamily => $composableBuilder(
    column: $table.rootFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyRootTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyRootTable> {
  $$FamilyRootTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get rootFamilyKey => $composableBuilder(
    column: $table.rootFamilyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootKey => $composableBuilder(
    column: $table.rootKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootFamily => $composableBuilder(
    column: $table.rootFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyRootTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyRootTable> {
  $$FamilyRootTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get rootFamilyKey => $composableBuilder(
    column: $table.rootFamilyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootKey =>
      $composableBuilder(column: $table.rootKey, builder: (column) => column);

  GeneratedColumn<String> get rootFamily => $composableBuilder(
    column: $table.rootFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rootMeaning => $composableBuilder(
    column: $table.rootMeaning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$FamilyRootTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyRootTable,
          FamilyRootData,
          $$FamilyRootTableFilterComposer,
          $$FamilyRootTableOrderingComposer,
          $$FamilyRootTableAnnotationComposer,
          $$FamilyRootTableCreateCompanionBuilder,
          $$FamilyRootTableUpdateCompanionBuilder,
          (
            FamilyRootData,
            BaseReferences<_$AppDatabase, $FamilyRootTable, FamilyRootData>,
          ),
          FamilyRootData,
          PrefetchHooks Function()
        > {
  $$FamilyRootTableTableManager(_$AppDatabase db, $FamilyRootTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyRootTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyRootTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyRootTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> rootFamilyKey = const Value.absent(),
                Value<String> rootKey = const Value.absent(),
                Value<String> rootFamily = const Value.absent(),
                Value<String> rootMeaning = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyRootCompanion(
                rootFamilyKey: rootFamilyKey,
                rootKey: rootKey,
                rootFamily: rootFamily,
                rootMeaning: rootMeaning,
                data: data,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String rootFamilyKey,
                required String rootKey,
                required String rootFamily,
                required String rootMeaning,
                required String data,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => FamilyRootCompanion.insert(
                rootFamilyKey: rootFamilyKey,
                rootKey: rootKey,
                rootFamily: rootFamily,
                rootMeaning: rootMeaning,
                data: data,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyRootTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyRootTable,
      FamilyRootData,
      $$FamilyRootTableFilterComposer,
      $$FamilyRootTableOrderingComposer,
      $$FamilyRootTableAnnotationComposer,
      $$FamilyRootTableCreateCompanionBuilder,
      $$FamilyRootTableUpdateCompanionBuilder,
      (
        FamilyRootData,
        BaseReferences<_$AppDatabase, $FamilyRootTable, FamilyRootData>,
      ),
      FamilyRootData,
      PrefetchHooks Function()
    >;
typedef $$FamilyWordTableCreateCompanionBuilder =
    FamilyWordCompanion Function({
      required String wordFamily,
      required String data,
      required int count,
      Value<int> rowid,
    });
typedef $$FamilyWordTableUpdateCompanionBuilder =
    FamilyWordCompanion Function({
      Value<String> wordFamily,
      Value<String> data,
      Value<int> count,
      Value<int> rowid,
    });

class $$FamilyWordTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyWordTable> {
  $$FamilyWordTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get wordFamily => $composableBuilder(
    column: $table.wordFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyWordTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyWordTable> {
  $$FamilyWordTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get wordFamily => $composableBuilder(
    column: $table.wordFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyWordTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyWordTable> {
  $$FamilyWordTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get wordFamily => $composableBuilder(
    column: $table.wordFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$FamilyWordTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyWordTable,
          FamilyWordData,
          $$FamilyWordTableFilterComposer,
          $$FamilyWordTableOrderingComposer,
          $$FamilyWordTableAnnotationComposer,
          $$FamilyWordTableCreateCompanionBuilder,
          $$FamilyWordTableUpdateCompanionBuilder,
          (
            FamilyWordData,
            BaseReferences<_$AppDatabase, $FamilyWordTable, FamilyWordData>,
          ),
          FamilyWordData,
          PrefetchHooks Function()
        > {
  $$FamilyWordTableTableManager(_$AppDatabase db, $FamilyWordTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyWordTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyWordTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyWordTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> wordFamily = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyWordCompanion(
                wordFamily: wordFamily,
                data: data,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String wordFamily,
                required String data,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => FamilyWordCompanion.insert(
                wordFamily: wordFamily,
                data: data,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyWordTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyWordTable,
      FamilyWordData,
      $$FamilyWordTableFilterComposer,
      $$FamilyWordTableOrderingComposer,
      $$FamilyWordTableAnnotationComposer,
      $$FamilyWordTableCreateCompanionBuilder,
      $$FamilyWordTableUpdateCompanionBuilder,
      (
        FamilyWordData,
        BaseReferences<_$AppDatabase, $FamilyWordTable, FamilyWordData>,
      ),
      FamilyWordData,
      PrefetchHooks Function()
    >;
typedef $$FamilyCompoundTableCreateCompanionBuilder =
    FamilyCompoundCompanion Function({
      required String compoundFamily,
      required String data,
      required int count,
      Value<int> rowid,
    });
typedef $$FamilyCompoundTableUpdateCompanionBuilder =
    FamilyCompoundCompanion Function({
      Value<String> compoundFamily,
      Value<String> data,
      Value<int> count,
      Value<int> rowid,
    });

class $$FamilyCompoundTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyCompoundTable> {
  $$FamilyCompoundTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get compoundFamily => $composableBuilder(
    column: $table.compoundFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyCompoundTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyCompoundTable> {
  $$FamilyCompoundTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get compoundFamily => $composableBuilder(
    column: $table.compoundFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyCompoundTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyCompoundTable> {
  $$FamilyCompoundTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get compoundFamily => $composableBuilder(
    column: $table.compoundFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$FamilyCompoundTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyCompoundTable,
          FamilyCompoundData,
          $$FamilyCompoundTableFilterComposer,
          $$FamilyCompoundTableOrderingComposer,
          $$FamilyCompoundTableAnnotationComposer,
          $$FamilyCompoundTableCreateCompanionBuilder,
          $$FamilyCompoundTableUpdateCompanionBuilder,
          (
            FamilyCompoundData,
            BaseReferences<
              _$AppDatabase,
              $FamilyCompoundTable,
              FamilyCompoundData
            >,
          ),
          FamilyCompoundData,
          PrefetchHooks Function()
        > {
  $$FamilyCompoundTableTableManager(
    _$AppDatabase db,
    $FamilyCompoundTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyCompoundTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyCompoundTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyCompoundTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> compoundFamily = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyCompoundCompanion(
                compoundFamily: compoundFamily,
                data: data,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String compoundFamily,
                required String data,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => FamilyCompoundCompanion.insert(
                compoundFamily: compoundFamily,
                data: data,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyCompoundTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyCompoundTable,
      FamilyCompoundData,
      $$FamilyCompoundTableFilterComposer,
      $$FamilyCompoundTableOrderingComposer,
      $$FamilyCompoundTableAnnotationComposer,
      $$FamilyCompoundTableCreateCompanionBuilder,
      $$FamilyCompoundTableUpdateCompanionBuilder,
      (
        FamilyCompoundData,
        BaseReferences<_$AppDatabase, $FamilyCompoundTable, FamilyCompoundData>,
      ),
      FamilyCompoundData,
      PrefetchHooks Function()
    >;
typedef $$FamilyIdiomTableCreateCompanionBuilder =
    FamilyIdiomCompanion Function({
      required String idiom,
      required String data,
      required int count,
      Value<int> rowid,
    });
typedef $$FamilyIdiomTableUpdateCompanionBuilder =
    FamilyIdiomCompanion Function({
      Value<String> idiom,
      Value<String> data,
      Value<int> count,
      Value<int> rowid,
    });

class $$FamilyIdiomTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyIdiomTable> {
  $$FamilyIdiomTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idiom => $composableBuilder(
    column: $table.idiom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyIdiomTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyIdiomTable> {
  $$FamilyIdiomTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idiom => $composableBuilder(
    column: $table.idiom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyIdiomTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyIdiomTable> {
  $$FamilyIdiomTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idiom =>
      $composableBuilder(column: $table.idiom, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$FamilyIdiomTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyIdiomTable,
          FamilyIdiomData,
          $$FamilyIdiomTableFilterComposer,
          $$FamilyIdiomTableOrderingComposer,
          $$FamilyIdiomTableAnnotationComposer,
          $$FamilyIdiomTableCreateCompanionBuilder,
          $$FamilyIdiomTableUpdateCompanionBuilder,
          (
            FamilyIdiomData,
            BaseReferences<_$AppDatabase, $FamilyIdiomTable, FamilyIdiomData>,
          ),
          FamilyIdiomData,
          PrefetchHooks Function()
        > {
  $$FamilyIdiomTableTableManager(_$AppDatabase db, $FamilyIdiomTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyIdiomTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyIdiomTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyIdiomTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idiom = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyIdiomCompanion(
                idiom: idiom,
                data: data,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idiom,
                required String data,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => FamilyIdiomCompanion.insert(
                idiom: idiom,
                data: data,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyIdiomTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyIdiomTable,
      FamilyIdiomData,
      $$FamilyIdiomTableFilterComposer,
      $$FamilyIdiomTableOrderingComposer,
      $$FamilyIdiomTableAnnotationComposer,
      $$FamilyIdiomTableCreateCompanionBuilder,
      $$FamilyIdiomTableUpdateCompanionBuilder,
      (
        FamilyIdiomData,
        BaseReferences<_$AppDatabase, $FamilyIdiomTable, FamilyIdiomData>,
      ),
      FamilyIdiomData,
      PrefetchHooks Function()
    >;
typedef $$FamilySetTableCreateCompanionBuilder =
    FamilySetCompanion Function({
      required String set_,
      required String data,
      required int count,
      Value<int> rowid,
    });
typedef $$FamilySetTableUpdateCompanionBuilder =
    FamilySetCompanion Function({
      Value<String> set_,
      Value<String> data,
      Value<int> count,
      Value<int> rowid,
    });

class $$FamilySetTableFilterComposer
    extends Composer<_$AppDatabase, $FamilySetTable> {
  $$FamilySetTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get set_ => $composableBuilder(
    column: $table.set_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilySetTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilySetTable> {
  $$FamilySetTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get set_ => $composableBuilder(
    column: $table.set_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilySetTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilySetTable> {
  $$FamilySetTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get set_ =>
      $composableBuilder(column: $table.set_, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);
}

class $$FamilySetTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilySetTable,
          FamilySetData,
          $$FamilySetTableFilterComposer,
          $$FamilySetTableOrderingComposer,
          $$FamilySetTableAnnotationComposer,
          $$FamilySetTableCreateCompanionBuilder,
          $$FamilySetTableUpdateCompanionBuilder,
          (
            FamilySetData,
            BaseReferences<_$AppDatabase, $FamilySetTable, FamilySetData>,
          ),
          FamilySetData,
          PrefetchHooks Function()
        > {
  $$FamilySetTableTableManager(_$AppDatabase db, $FamilySetTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilySetTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilySetTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilySetTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> set_ = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilySetCompanion(
                set_: set_,
                data: data,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String set_,
                required String data,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => FamilySetCompanion.insert(
                set_: set_,
                data: data,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilySetTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilySetTable,
      FamilySetData,
      $$FamilySetTableFilterComposer,
      $$FamilySetTableOrderingComposer,
      $$FamilySetTableAnnotationComposer,
      $$FamilySetTableCreateCompanionBuilder,
      $$FamilySetTableUpdateCompanionBuilder,
      (
        FamilySetData,
        BaseReferences<_$AppDatabase, $FamilySetTable, FamilySetData>,
      ),
      FamilySetData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DpdRootsTableTableManager get dpdRoots =>
      $$DpdRootsTableTableManager(_db, _db.dpdRoots);
  $$DpdHeadwordsTableTableManager get dpdHeadwords =>
      $$DpdHeadwordsTableTableManager(_db, _db.dpdHeadwords);
  $$LookupTableTableManager get lookup =>
      $$LookupTableTableManager(_db, _db.lookup);
  $$DbInfoTableTableManager get dbInfo =>
      $$DbInfoTableTableManager(_db, _db.dbInfo);
  $$InflectionTemplatesTableTableManager get inflectionTemplates =>
      $$InflectionTemplatesTableTableManager(_db, _db.inflectionTemplates);
  $$FamilyRootTableTableManager get familyRoot =>
      $$FamilyRootTableTableManager(_db, _db.familyRoot);
  $$FamilyWordTableTableManager get familyWord =>
      $$FamilyWordTableTableManager(_db, _db.familyWord);
  $$FamilyCompoundTableTableManager get familyCompound =>
      $$FamilyCompoundTableTableManager(_db, _db.familyCompound);
  $$FamilyIdiomTableTableManager get familyIdiom =>
      $$FamilyIdiomTableTableManager(_db, _db.familyIdiom);
  $$FamilySetTableTableManager get familySet =>
      $$FamilySetTableTableManager(_db, _db.familySet);
}
