// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExerciseType>($ExercisesTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<CardioActivity?, String>
  cardioActivity = GeneratedColumn<String>(
    'cardio_activity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CardioActivity?>($ExercisesTable.$convertercardioActivityn);
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
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
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameKey,
    type,
    cardioActivity,
    muscleGroup,
    equipment,
    notes,
    isCustom,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nameKey},
  ];
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      type: $ExercisesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      cardioActivity: $ExercisesTable.$convertercardioActivityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cardio_activity'],
        ),
      ),
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExerciseType, String, String> $convertertype =
      const EnumNameConverter<ExerciseType>(ExerciseType.values);
  static JsonTypeConverter2<CardioActivity, String, String>
  $convertercardioActivity = const EnumNameConverter<CardioActivity>(
    CardioActivity.values,
  );
  static JsonTypeConverter2<CardioActivity?, String?, String?>
  $convertercardioActivityn = JsonTypeConverter2.asNullable(
    $convertercardioActivity,
  );
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final int id;
  final String name;

  /// Lower-cased, whitespace-collapsed [name]. Plan files reference exercises by
  /// name, so imports must match "Barbell Bench Press" to "barbell bench press"
  /// without creating a duplicate. SQLite's default TEXT comparison is
  /// case-sensitive, hence an explicit normalized column rather than a collation.
  final String nameKey;
  final ExerciseType type;

  /// Only meaningful when [type] is cardio; drives which fields the log screen
  /// prompts for (a swim has no incline).
  final CardioActivity? cardioActivity;
  final String? muscleGroup;
  final String? equipment;
  final String? notes;

  /// False for the seeded starter catalog, true for anything the user or an
  /// import created.
  final bool isCustom;

  /// Archived exercises stay in history but are hidden from pickers. Exercises
  /// are never hard-deleted while sessions reference them.
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExerciseRow({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.type,
    this.cardioActivity,
    this.muscleGroup,
    this.equipment,
    this.notes,
    required this.isCustom,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    {
      map['type'] = Variable<String>(
        $ExercisesTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || cardioActivity != null) {
      map['cardio_activity'] = Variable<String>(
        $ExercisesTable.$convertercardioActivityn.toSql(cardioActivity),
      );
    }
    if (!nullToAbsent || muscleGroup != null) {
      map['muscle_group'] = Variable<String>(muscleGroup);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      type: Value(type),
      cardioActivity: cardioActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(cardioActivity),
      muscleGroup: muscleGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroup),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isCustom: Value(isCustom),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      type: $ExercisesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      cardioActivity: $ExercisesTable.$convertercardioActivityn.fromJson(
        serializer.fromJson<String?>(json['cardioActivity']),
      ),
      muscleGroup: serializer.fromJson<String?>(json['muscleGroup']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      notes: serializer.fromJson<String?>(json['notes']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'type': serializer.toJson<String>(
        $ExercisesTable.$convertertype.toJson(type),
      ),
      'cardioActivity': serializer.toJson<String?>(
        $ExercisesTable.$convertercardioActivityn.toJson(cardioActivity),
      ),
      'muscleGroup': serializer.toJson<String?>(muscleGroup),
      'equipment': serializer.toJson<String?>(equipment),
      'notes': serializer.toJson<String?>(notes),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExerciseRow copyWith({
    int? id,
    String? name,
    String? nameKey,
    ExerciseType? type,
    Value<CardioActivity?> cardioActivity = const Value.absent(),
    Value<String?> muscleGroup = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isCustom,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    type: type ?? this.type,
    cardioActivity: cardioActivity.present
        ? cardioActivity.value
        : this.cardioActivity,
    muscleGroup: muscleGroup.present ? muscleGroup.value : this.muscleGroup,
    equipment: equipment.present ? equipment.value : this.equipment,
    notes: notes.present ? notes.value : this.notes,
    isCustom: isCustom ?? this.isCustom,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      type: data.type.present ? data.type.value : this.type,
      cardioActivity: data.cardioActivity.present
          ? data.cardioActivity.value
          : this.cardioActivity,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      notes: data.notes.present ? data.notes.value : this.notes,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('type: $type, ')
          ..write('cardioActivity: $cardioActivity, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('equipment: $equipment, ')
          ..write('notes: $notes, ')
          ..write('isCustom: $isCustom, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameKey,
    type,
    cardioActivity,
    muscleGroup,
    equipment,
    notes,
    isCustom,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.type == this.type &&
          other.cardioActivity == this.cardioActivity &&
          other.muscleGroup == this.muscleGroup &&
          other.equipment == this.equipment &&
          other.notes == this.notes &&
          other.isCustom == this.isCustom &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<ExerciseType> type;
  final Value<CardioActivity?> cardioActivity;
  final Value<String?> muscleGroup;
  final Value<String?> equipment;
  final Value<String?> notes;
  final Value<bool> isCustom;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.type = const Value.absent(),
    this.cardioActivity = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.equipment = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
    required ExerciseType type,
    this.cardioActivity = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.equipment = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       nameKey = Value(nameKey),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExerciseRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? type,
    Expression<String>? cardioActivity,
    Expression<String>? muscleGroup,
    Expression<String>? equipment,
    Expression<String>? notes,
    Expression<bool>? isCustom,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (type != null) 'type': type,
      if (cardioActivity != null) 'cardio_activity': cardioActivity,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (equipment != null) 'equipment': equipment,
      if (notes != null) 'notes': notes,
      if (isCustom != null) 'is_custom': isCustom,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<ExerciseType>? type,
    Value<CardioActivity?>? cardioActivity,
    Value<String?>? muscleGroup,
    Value<String?>? equipment,
    Value<String?>? notes,
    Value<bool>? isCustom,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      type: type ?? this.type,
      cardioActivity: cardioActivity ?? this.cardioActivity,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      notes: notes ?? this.notes,
      isCustom: isCustom ?? this.isCustom,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ExercisesTable.$convertertype.toSql(type.value),
      );
    }
    if (cardioActivity.present) {
      map['cardio_activity'] = Variable<String>(
        $ExercisesTable.$convertercardioActivityn.toSql(cardioActivity.value),
      );
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('type: $type, ')
          ..write('cardioActivity: $cardioActivity, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('equipment: $equipment, ')
          ..write('notes: $notes, ')
          ..write('isCustom: $isCustom, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlanMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanMode>($PlansTable.$convertermode);
  @override
  late final GeneratedColumnWithTypeConverter<ScheduleType, String>
  scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ScheduleType>($PlansTable.$converterscheduleType);
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationWeeksMeta = const VerificationMeta(
    'durationWeeks',
  );
  @override
  late final GeneratedColumn<int> durationWeeks = GeneratedColumn<int>(
    'duration_weeks',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlanSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanSource>($PlansTable.$convertersource);
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<String> schemaVersion = GeneratedColumn<String>(
    'schema_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    mode,
    scheduleType,
    startDate,
    durationWeeks,
    isActive,
    source,
    schemaVersion,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('duration_weeks')) {
      context.handle(
        _durationWeeksMeta,
        durationWeeks.isAcceptableOrUnknown(
          data['duration_weeks']!,
          _durationWeeksMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      mode: $PlansTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      scheduleType: $PlansTable.$converterscheduleType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}schedule_type'],
        )!,
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      durationWeeks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_weeks'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      source: $PlansTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema_version'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlanMode, String, String> $convertermode =
      const EnumNameConverter<PlanMode>(PlanMode.values);
  static JsonTypeConverter2<ScheduleType, String, String>
  $converterscheduleType = const EnumNameConverter<ScheduleType>(
    ScheduleType.values,
  );
  static JsonTypeConverter2<PlanSource, String, String> $convertersource =
      const EnumNameConverter<PlanSource>(PlanSource.values);
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final int id;
  final String name;
  final String? description;
  final PlanMode mode;
  final ScheduleType scheduleType;

  /// Periodized plans only.
  final DateTime? startDate;

  /// Periodized plans only.
  final int? durationWeeks;
  final bool isActive;
  final PlanSource source;

  /// The `schemaVersion` of the plan file this was imported from, for
  /// diagnosing files produced against an older format.
  final String? schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanRow({
    required this.id,
    required this.name,
    this.description,
    required this.mode,
    required this.scheduleType,
    this.startDate,
    this.durationWeeks,
    required this.isActive,
    required this.source,
    this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['mode'] = Variable<String>($PlansTable.$convertermode.toSql(mode));
    }
    {
      map['schedule_type'] = Variable<String>(
        $PlansTable.$converterscheduleType.toSql(scheduleType),
      );
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || durationWeeks != null) {
      map['duration_weeks'] = Variable<int>(durationWeeks);
    }
    map['is_active'] = Variable<bool>(isActive);
    {
      map['source'] = Variable<String>(
        $PlansTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || schemaVersion != null) {
      map['schema_version'] = Variable<String>(schemaVersion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      mode: Value(mode),
      scheduleType: Value(scheduleType),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      durationWeeks: durationWeeks == null && nullToAbsent
          ? const Value.absent()
          : Value(durationWeeks),
      isActive: Value(isActive),
      source: Value(source),
      schemaVersion: schemaVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(schemaVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      mode: $PlansTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      scheduleType: $PlansTable.$converterscheduleType.fromJson(
        serializer.fromJson<String>(json['scheduleType']),
      ),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      durationWeeks: serializer.fromJson<int?>(json['durationWeeks']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      source: $PlansTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      schemaVersion: serializer.fromJson<String?>(json['schemaVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'mode': serializer.toJson<String>(
        $PlansTable.$convertermode.toJson(mode),
      ),
      'scheduleType': serializer.toJson<String>(
        $PlansTable.$converterscheduleType.toJson(scheduleType),
      ),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'durationWeeks': serializer.toJson<int?>(durationWeeks),
      'isActive': serializer.toJson<bool>(isActive),
      'source': serializer.toJson<String>(
        $PlansTable.$convertersource.toJson(source),
      ),
      'schemaVersion': serializer.toJson<String?>(schemaVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanRow copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    PlanMode? mode,
    ScheduleType? scheduleType,
    Value<DateTime?> startDate = const Value.absent(),
    Value<int?> durationWeeks = const Value.absent(),
    bool? isActive,
    PlanSource? source,
    Value<String?> schemaVersion = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlanRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    mode: mode ?? this.mode,
    scheduleType: scheduleType ?? this.scheduleType,
    startDate: startDate.present ? startDate.value : this.startDate,
    durationWeeks: durationWeeks.present
        ? durationWeeks.value
        : this.durationWeeks,
    isActive: isActive ?? this.isActive,
    source: source ?? this.source,
    schemaVersion: schemaVersion.present
        ? schemaVersion.value
        : this.schemaVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      mode: data.mode.present ? data.mode.value : this.mode,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      durationWeeks: data.durationWeeks.present
          ? data.durationWeeks.value
          : this.durationWeeks,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      source: data.source.present ? data.source.value : this.source,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('mode: $mode, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('isActive: $isActive, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    mode,
    scheduleType,
    startDate,
    durationWeeks,
    isActive,
    source,
    schemaVersion,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.mode == this.mode &&
          other.scheduleType == this.scheduleType &&
          other.startDate == this.startDate &&
          other.durationWeeks == this.durationWeeks &&
          other.isActive == this.isActive &&
          other.source == this.source &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<PlanMode> mode;
  final Value<ScheduleType> scheduleType;
  final Value<DateTime?> startDate;
  final Value<int?> durationWeeks;
  final Value<bool> isActive;
  final Value<PlanSource> source;
  final Value<String?> schemaVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.mode = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.isActive = const Value.absent(),
    this.source = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required PlanMode mode,
    required ScheduleType scheduleType,
    this.startDate = const Value.absent(),
    this.durationWeeks = const Value.absent(),
    this.isActive = const Value.absent(),
    required PlanSource source,
    this.schemaVersion = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       mode = Value(mode),
       scheduleType = Value(scheduleType),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PlanRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? mode,
    Expression<String>? scheduleType,
    Expression<DateTime>? startDate,
    Expression<int>? durationWeeks,
    Expression<bool>? isActive,
    Expression<String>? source,
    Expression<String>? schemaVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (mode != null) 'mode': mode,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (startDate != null) 'start_date': startDate,
      if (durationWeeks != null) 'duration_weeks': durationWeeks,
      if (isActive != null) 'is_active': isActive,
      if (source != null) 'source': source,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<PlanMode>? mode,
    Value<ScheduleType>? scheduleType,
    Value<DateTime?>? startDate,
    Value<int?>? durationWeeks,
    Value<bool>? isActive,
    Value<PlanSource>? source,
    Value<String?>? schemaVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mode: mode ?? this.mode,
      scheduleType: scheduleType ?? this.scheduleType,
      startDate: startDate ?? this.startDate,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      isActive: isActive ?? this.isActive,
      source: source ?? this.source,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $PlansTable.$convertermode.toSql(mode.value),
      );
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(
        $PlansTable.$converterscheduleType.toSql(scheduleType.value),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (durationWeeks.present) {
      map['duration_weeks'] = Variable<int>(durationWeeks.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $PlansTable.$convertersource.toSql(source.value),
      );
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<String>(schemaVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('mode: $mode, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('startDate: $startDate, ')
          ..write('durationWeeks: $durationWeeks, ')
          ..write('isActive: $isActive, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlanDaysTable extends PlanDays
    with TableInfo<$PlanDaysTable, PlanDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekNumberMeta = const VerificationMeta(
    'weekNumber',
  );
  @override
  late final GeneratedColumn<int> weekNumber = GeneratedColumn<int>(
    'week_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weekday?, String> dayOfWeek =
      GeneratedColumn<String>(
        'day_of_week',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Weekday?>($PlanDaysTable.$converterdayOfWeekn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    orderIndex,
    label,
    weekNumber,
    dayOfWeek,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('week_number')) {
      context.handle(
        _weekNumberMeta,
        weekNumber.isAcceptableOrUnknown(data['week_number']!, _weekNumberMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      weekNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_number'],
      ),
      dayOfWeek: $PlanDaysTable.$converterdayOfWeekn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day_of_week'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PlanDaysTable createAlias(String alias) {
    return $PlanDaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weekday, String, String> $converterdayOfWeek =
      const EnumNameConverter<Weekday>(Weekday.values);
  static JsonTypeConverter2<Weekday?, String?, String?> $converterdayOfWeekn =
      JsonTypeConverter2.asNullable($converterdayOfWeek);
}

class PlanDayRow extends DataClass implements Insertable<PlanDayRow> {
  final int id;
  final int planId;
  final int orderIndex;
  final String label;

  /// Periodized plans place each day in a specific week.
  final int? weekNumber;

  /// Set only when the plan's schedule type is weekly.
  final Weekday? dayOfWeek;
  final String? notes;
  const PlanDayRow({
    required this.id,
    required this.planId,
    required this.orderIndex,
    required this.label,
    this.weekNumber,
    this.dayOfWeek,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['order_index'] = Variable<int>(orderIndex);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || weekNumber != null) {
      map['week_number'] = Variable<int>(weekNumber);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<String>(
        $PlanDaysTable.$converterdayOfWeekn.toSql(dayOfWeek),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PlanDaysCompanion toCompanion(bool nullToAbsent) {
    return PlanDaysCompanion(
      id: Value(id),
      planId: Value(planId),
      orderIndex: Value(orderIndex),
      label: Value(label),
      weekNumber: weekNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(weekNumber),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PlanDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanDayRow(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      label: serializer.fromJson<String>(json['label']),
      weekNumber: serializer.fromJson<int?>(json['weekNumber']),
      dayOfWeek: $PlanDaysTable.$converterdayOfWeekn.fromJson(
        serializer.fromJson<String?>(json['dayOfWeek']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'label': serializer.toJson<String>(label),
      'weekNumber': serializer.toJson<int?>(weekNumber),
      'dayOfWeek': serializer.toJson<String?>(
        $PlanDaysTable.$converterdayOfWeekn.toJson(dayOfWeek),
      ),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PlanDayRow copyWith({
    int? id,
    int? planId,
    int? orderIndex,
    String? label,
    Value<int?> weekNumber = const Value.absent(),
    Value<Weekday?> dayOfWeek = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => PlanDayRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    orderIndex: orderIndex ?? this.orderIndex,
    label: label ?? this.label,
    weekNumber: weekNumber.present ? weekNumber.value : this.weekNumber,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    notes: notes.present ? notes.value : this.notes,
  );
  PlanDayRow copyWithCompanion(PlanDaysCompanion data) {
    return PlanDayRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      label: data.label.present ? data.label.value : this.label,
      weekNumber: data.weekNumber.present
          ? data.weekNumber.value
          : this.weekNumber,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanDayRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('label: $label, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, orderIndex, label, weekNumber, dayOfWeek, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanDayRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.orderIndex == this.orderIndex &&
          other.label == this.label &&
          other.weekNumber == this.weekNumber &&
          other.dayOfWeek == this.dayOfWeek &&
          other.notes == this.notes);
}

class PlanDaysCompanion extends UpdateCompanion<PlanDayRow> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> orderIndex;
  final Value<String> label;
  final Value<int?> weekNumber;
  final Value<Weekday?> dayOfWeek;
  final Value<String?> notes;
  const PlanDaysCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.weekNumber = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PlanDaysCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int orderIndex,
    required String label,
    this.weekNumber = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.notes = const Value.absent(),
  }) : planId = Value(planId),
       orderIndex = Value(orderIndex),
       label = Value(label);
  static Insertable<PlanDayRow> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? orderIndex,
    Expression<String>? label,
    Expression<int>? weekNumber,
    Expression<String>? dayOfWeek,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (label != null) 'label': label,
      if (weekNumber != null) 'week_number': weekNumber,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (notes != null) 'notes': notes,
    });
  }

  PlanDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int>? orderIndex,
    Value<String>? label,
    Value<int?>? weekNumber,
    Value<Weekday?>? dayOfWeek,
    Value<String?>? notes,
  }) {
    return PlanDaysCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      orderIndex: orderIndex ?? this.orderIndex,
      label: label ?? this.label,
      weekNumber: weekNumber ?? this.weekNumber,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (weekNumber.present) {
      map['week_number'] = Variable<int>(weekNumber.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<String>(
        $PlanDaysTable.$converterdayOfWeekn.toSql(dayOfWeek.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanDaysCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('label: $label, ')
          ..write('weekNumber: $weekNumber, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PlanBlocksTable extends PlanBlocks
    with TableInfo<$PlanBlocksTable, PlanBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planDayIdMeta = const VerificationMeta(
    'planDayId',
  );
  @override
  late final GeneratedColumn<int> planDayId = GeneratedColumn<int>(
    'plan_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlockKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BlockKind>($PlanBlocksTable.$converterkind);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundsMeta = const VerificationMeta('rounds');
  @override
  late final GeneratedColumn<int> rounds = GeneratedColumn<int>(
    'rounds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _restBetweenExercisesSecondsMeta =
      const VerificationMeta('restBetweenExercisesSeconds');
  @override
  late final GeneratedColumn<int> restBetweenExercisesSeconds =
      GeneratedColumn<int>(
        'rest_between_exercises_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _restAfterRoundSecondsMeta =
      const VerificationMeta('restAfterRoundSeconds');
  @override
  late final GeneratedColumn<int> restAfterRoundSeconds = GeneratedColumn<int>(
    'rest_after_round_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(90),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planDayId,
    orderIndex,
    kind,
    label,
    rounds,
    restBetweenExercisesSeconds,
    restAfterRoundSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_day_id')) {
      context.handle(
        _planDayIdMeta,
        planDayId.isAcceptableOrUnknown(data['plan_day_id']!, _planDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planDayIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('rounds')) {
      context.handle(
        _roundsMeta,
        rounds.isAcceptableOrUnknown(data['rounds']!, _roundsMeta),
      );
    }
    if (data.containsKey('rest_between_exercises_seconds')) {
      context.handle(
        _restBetweenExercisesSecondsMeta,
        restBetweenExercisesSeconds.isAcceptableOrUnknown(
          data['rest_between_exercises_seconds']!,
          _restBetweenExercisesSecondsMeta,
        ),
      );
    }
    if (data.containsKey('rest_after_round_seconds')) {
      context.handle(
        _restAfterRoundSecondsMeta,
        restAfterRoundSeconds.isAcceptableOrUnknown(
          data['rest_after_round_seconds']!,
          _restAfterRoundSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_day_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      kind: $PlanBlocksTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      rounds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds'],
      )!,
      restBetweenExercisesSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_between_exercises_seconds'],
      )!,
      restAfterRoundSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_after_round_seconds'],
      )!,
    );
  }

  @override
  $PlanBlocksTable createAlias(String alias) {
    return $PlanBlocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlockKind, String, String> $converterkind =
      const EnumNameConverter<BlockKind>(BlockKind.values);
}

class PlanBlockRow extends DataClass implements Insertable<PlanBlockRow> {
  final int id;
  final int planDayId;
  final int orderIndex;
  final BlockKind kind;
  final String? label;
  final int rounds;

  /// Rest between the exercises *inside* a superset. Usually zero — moving
  /// straight to the next movement is the point of a superset.
  final int restBetweenExercisesSeconds;

  /// Rest after finishing a full round of the block.
  final int restAfterRoundSeconds;
  const PlanBlockRow({
    required this.id,
    required this.planDayId,
    required this.orderIndex,
    required this.kind,
    this.label,
    required this.rounds,
    required this.restBetweenExercisesSeconds,
    required this.restAfterRoundSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_day_id'] = Variable<int>(planDayId);
    map['order_index'] = Variable<int>(orderIndex);
    {
      map['kind'] = Variable<String>(
        $PlanBlocksTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['rounds'] = Variable<int>(rounds);
    map['rest_between_exercises_seconds'] = Variable<int>(
      restBetweenExercisesSeconds,
    );
    map['rest_after_round_seconds'] = Variable<int>(restAfterRoundSeconds);
    return map;
  }

  PlanBlocksCompanion toCompanion(bool nullToAbsent) {
    return PlanBlocksCompanion(
      id: Value(id),
      planDayId: Value(planDayId),
      orderIndex: Value(orderIndex),
      kind: Value(kind),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      rounds: Value(rounds),
      restBetweenExercisesSeconds: Value(restBetweenExercisesSeconds),
      restAfterRoundSeconds: Value(restAfterRoundSeconds),
    );
  }

  factory PlanBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanBlockRow(
      id: serializer.fromJson<int>(json['id']),
      planDayId: serializer.fromJson<int>(json['planDayId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      kind: $PlanBlocksTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      label: serializer.fromJson<String?>(json['label']),
      rounds: serializer.fromJson<int>(json['rounds']),
      restBetweenExercisesSeconds: serializer.fromJson<int>(
        json['restBetweenExercisesSeconds'],
      ),
      restAfterRoundSeconds: serializer.fromJson<int>(
        json['restAfterRoundSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planDayId': serializer.toJson<int>(planDayId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'kind': serializer.toJson<String>(
        $PlanBlocksTable.$converterkind.toJson(kind),
      ),
      'label': serializer.toJson<String?>(label),
      'rounds': serializer.toJson<int>(rounds),
      'restBetweenExercisesSeconds': serializer.toJson<int>(
        restBetweenExercisesSeconds,
      ),
      'restAfterRoundSeconds': serializer.toJson<int>(restAfterRoundSeconds),
    };
  }

  PlanBlockRow copyWith({
    int? id,
    int? planDayId,
    int? orderIndex,
    BlockKind? kind,
    Value<String?> label = const Value.absent(),
    int? rounds,
    int? restBetweenExercisesSeconds,
    int? restAfterRoundSeconds,
  }) => PlanBlockRow(
    id: id ?? this.id,
    planDayId: planDayId ?? this.planDayId,
    orderIndex: orderIndex ?? this.orderIndex,
    kind: kind ?? this.kind,
    label: label.present ? label.value : this.label,
    rounds: rounds ?? this.rounds,
    restBetweenExercisesSeconds:
        restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
    restAfterRoundSeconds: restAfterRoundSeconds ?? this.restAfterRoundSeconds,
  );
  PlanBlockRow copyWithCompanion(PlanBlocksCompanion data) {
    return PlanBlockRow(
      id: data.id.present ? data.id.value : this.id,
      planDayId: data.planDayId.present ? data.planDayId.value : this.planDayId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      rounds: data.rounds.present ? data.rounds.value : this.rounds,
      restBetweenExercisesSeconds: data.restBetweenExercisesSeconds.present
          ? data.restBetweenExercisesSeconds.value
          : this.restBetweenExercisesSeconds,
      restAfterRoundSeconds: data.restAfterRoundSeconds.present
          ? data.restAfterRoundSeconds.value
          : this.restAfterRoundSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanBlockRow(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('rounds: $rounds, ')
          ..write('restBetweenExercisesSeconds: $restBetweenExercisesSeconds, ')
          ..write('restAfterRoundSeconds: $restAfterRoundSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planDayId,
    orderIndex,
    kind,
    label,
    rounds,
    restBetweenExercisesSeconds,
    restAfterRoundSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanBlockRow &&
          other.id == this.id &&
          other.planDayId == this.planDayId &&
          other.orderIndex == this.orderIndex &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.rounds == this.rounds &&
          other.restBetweenExercisesSeconds ==
              this.restBetweenExercisesSeconds &&
          other.restAfterRoundSeconds == this.restAfterRoundSeconds);
}

class PlanBlocksCompanion extends UpdateCompanion<PlanBlockRow> {
  final Value<int> id;
  final Value<int> planDayId;
  final Value<int> orderIndex;
  final Value<BlockKind> kind;
  final Value<String?> label;
  final Value<int> rounds;
  final Value<int> restBetweenExercisesSeconds;
  final Value<int> restAfterRoundSeconds;
  const PlanBlocksCompanion({
    this.id = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.rounds = const Value.absent(),
    this.restBetweenExercisesSeconds = const Value.absent(),
    this.restAfterRoundSeconds = const Value.absent(),
  });
  PlanBlocksCompanion.insert({
    this.id = const Value.absent(),
    required int planDayId,
    required int orderIndex,
    required BlockKind kind,
    this.label = const Value.absent(),
    this.rounds = const Value.absent(),
    this.restBetweenExercisesSeconds = const Value.absent(),
    this.restAfterRoundSeconds = const Value.absent(),
  }) : planDayId = Value(planDayId),
       orderIndex = Value(orderIndex),
       kind = Value(kind);
  static Insertable<PlanBlockRow> custom({
    Expression<int>? id,
    Expression<int>? planDayId,
    Expression<int>? orderIndex,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<int>? rounds,
    Expression<int>? restBetweenExercisesSeconds,
    Expression<int>? restAfterRoundSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planDayId != null) 'plan_day_id': planDayId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (rounds != null) 'rounds': rounds,
      if (restBetweenExercisesSeconds != null)
        'rest_between_exercises_seconds': restBetweenExercisesSeconds,
      if (restAfterRoundSeconds != null)
        'rest_after_round_seconds': restAfterRoundSeconds,
    });
  }

  PlanBlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? planDayId,
    Value<int>? orderIndex,
    Value<BlockKind>? kind,
    Value<String?>? label,
    Value<int>? rounds,
    Value<int>? restBetweenExercisesSeconds,
    Value<int>? restAfterRoundSeconds,
  }) {
    return PlanBlocksCompanion(
      id: id ?? this.id,
      planDayId: planDayId ?? this.planDayId,
      orderIndex: orderIndex ?? this.orderIndex,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      rounds: rounds ?? this.rounds,
      restBetweenExercisesSeconds:
          restBetweenExercisesSeconds ?? this.restBetweenExercisesSeconds,
      restAfterRoundSeconds:
          restAfterRoundSeconds ?? this.restAfterRoundSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planDayId.present) {
      map['plan_day_id'] = Variable<int>(planDayId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PlanBlocksTable.$converterkind.toSql(kind.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rounds.present) {
      map['rounds'] = Variable<int>(rounds.value);
    }
    if (restBetweenExercisesSeconds.present) {
      map['rest_between_exercises_seconds'] = Variable<int>(
        restBetweenExercisesSeconds.value,
      );
    }
    if (restAfterRoundSeconds.present) {
      map['rest_after_round_seconds'] = Variable<int>(
        restAfterRoundSeconds.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanBlocksCompanion(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('rounds: $rounds, ')
          ..write('restBetweenExercisesSeconds: $restBetweenExercisesSeconds, ')
          ..write('restAfterRoundSeconds: $restAfterRoundSeconds')
          ..write(')'))
        .toString();
  }
}

class $PlanItemsTable extends PlanItems
    with TableInfo<$PlanItemsTable, PlanItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planBlockIdMeta = const VerificationMeta(
    'planBlockId',
  );
  @override
  late final GeneratedColumn<int> planBlockId = GeneratedColumn<int>(
    'plan_block_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_blocks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightMode?, String> weightMode =
      GeneratedColumn<String>(
        'weight_mode',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<WeightMode?>($PlanItemsTable.$converterweightModen);
  static const VerificationMeta _weightOffsetKgMeta = const VerificationMeta(
    'weightOffsetKg',
  );
  @override
  late final GeneratedColumn<double> weightOffsetKg = GeneratedColumn<double>(
    'weight_offset_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightPercentMeta = const VerificationMeta(
    'weightPercent',
  );
  @override
  late final GeneratedColumn<double> weightPercent = GeneratedColumn<double>(
    'weight_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<String> tempo = GeneratedColumn<String>(
    'tempo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toFailureMeta = const VerificationMeta(
    'toFailure',
  );
  @override
  late final GeneratedColumn<bool> toFailure = GeneratedColumn<bool>(
    'to_failure',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("to_failure" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetDurationSecondsMeta =
      const VerificationMeta('targetDurationSeconds');
  @override
  late final GeneratedColumn<int> targetDurationSeconds = GeneratedColumn<int>(
    'target_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDistanceMetersMeta =
      const VerificationMeta('targetDistanceMeters');
  @override
  late final GeneratedColumn<double> targetDistanceMeters =
      GeneratedColumn<double>(
        'target_distance_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _targetPaceSecPerKmMeta =
      const VerificationMeta('targetPaceSecPerKm');
  @override
  late final GeneratedColumn<double> targetPaceSecPerKm =
      GeneratedColumn<double>(
        'target_pace_sec_per_km',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _targetInclinePercentMeta =
      const VerificationMeta('targetInclinePercent');
  @override
  late final GeneratedColumn<double> targetInclinePercent =
      GeneratedColumn<double>(
        'target_incline_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _targetResistanceLevelMeta =
      const VerificationMeta('targetResistanceLevel');
  @override
  late final GeneratedColumn<int> targetResistanceLevel = GeneratedColumn<int>(
    'target_resistance_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalsJsonMeta = const VerificationMeta(
    'intervalsJson',
  );
  @override
  late final GeneratedColumn<String> intervalsJson = GeneratedColumn<String>(
    'intervals_json',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planBlockId,
    exerciseId,
    orderIndex,
    targetReps,
    targetWeightKg,
    weightMode,
    weightOffsetKg,
    weightPercent,
    rpe,
    tempo,
    toFailure,
    targetDurationSeconds,
    targetDistanceMeters,
    targetPaceSecPerKm,
    targetInclinePercent,
    targetResistanceLevel,
    intervalsJson,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_block_id')) {
      context.handle(
        _planBlockIdMeta,
        planBlockId.isAcceptableOrUnknown(
          data['plan_block_id']!,
          _planBlockIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_planBlockIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('weight_offset_kg')) {
      context.handle(
        _weightOffsetKgMeta,
        weightOffsetKg.isAcceptableOrUnknown(
          data['weight_offset_kg']!,
          _weightOffsetKgMeta,
        ),
      );
    }
    if (data.containsKey('weight_percent')) {
      context.handle(
        _weightPercentMeta,
        weightPercent.isAcceptableOrUnknown(
          data['weight_percent']!,
          _weightPercentMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('tempo')) {
      context.handle(
        _tempoMeta,
        tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta),
      );
    }
    if (data.containsKey('to_failure')) {
      context.handle(
        _toFailureMeta,
        toFailure.isAcceptableOrUnknown(data['to_failure']!, _toFailureMeta),
      );
    }
    if (data.containsKey('target_duration_seconds')) {
      context.handle(
        _targetDurationSecondsMeta,
        targetDurationSeconds.isAcceptableOrUnknown(
          data['target_duration_seconds']!,
          _targetDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('target_distance_meters')) {
      context.handle(
        _targetDistanceMetersMeta,
        targetDistanceMeters.isAcceptableOrUnknown(
          data['target_distance_meters']!,
          _targetDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('target_pace_sec_per_km')) {
      context.handle(
        _targetPaceSecPerKmMeta,
        targetPaceSecPerKm.isAcceptableOrUnknown(
          data['target_pace_sec_per_km']!,
          _targetPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('target_incline_percent')) {
      context.handle(
        _targetInclinePercentMeta,
        targetInclinePercent.isAcceptableOrUnknown(
          data['target_incline_percent']!,
          _targetInclinePercentMeta,
        ),
      );
    }
    if (data.containsKey('target_resistance_level')) {
      context.handle(
        _targetResistanceLevelMeta,
        targetResistanceLevel.isAcceptableOrUnknown(
          data['target_resistance_level']!,
          _targetResistanceLevelMeta,
        ),
      );
    }
    if (data.containsKey('intervals_json')) {
      context.handle(
        _intervalsJsonMeta,
        intervalsJson.isAcceptableOrUnknown(
          data['intervals_json']!,
          _intervalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planBlockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_block_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      ),
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      weightMode: $PlanItemsTable.$converterweightModen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_mode'],
        ),
      ),
      weightOffsetKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_offset_kg'],
      ),
      weightPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_percent'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tempo'],
      ),
      toFailure: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}to_failure'],
      )!,
      targetDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_duration_seconds'],
      ),
      targetDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_meters'],
      ),
      targetPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_pace_sec_per_km'],
      ),
      targetInclinePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_incline_percent'],
      ),
      targetResistanceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_resistance_level'],
      ),
      intervalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervals_json'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PlanItemsTable createAlias(String alias) {
    return $PlanItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightMode, String, String> $converterweightMode =
      const EnumNameConverter<WeightMode>(WeightMode.values);
  static JsonTypeConverter2<WeightMode?, String?, String?>
  $converterweightModen = JsonTypeConverter2.asNullable($converterweightMode);
}

class PlanItemRow extends DataClass implements Insertable<PlanItemRow> {
  final int id;
  final int planBlockId;
  final int exerciseId;
  final int orderIndex;
  final int? targetReps;

  /// The literal prescribed weight. For [WeightMode.absolute] this is what gets
  /// used; for baseline modes it seeds the baseline on first import.
  final double? targetWeightKg;
  final WeightMode? weightMode;

  /// Increment for [WeightMode.baselinePlus].
  final double? weightOffsetKg;

  /// Percentage for [WeightMode.baselinePercent], where 85 means 85%.
  final double? weightPercent;
  final double? rpe;

  /// Free-form tempo notation such as `3-1-1`.
  final String? tempo;
  final bool toFailure;
  final int? targetDurationSeconds;
  final double? targetDistanceMeters;
  final double? targetPaceSecPerKm;
  final double? targetInclinePercent;
  final int? targetResistanceLevel;

  /// Interval prescription, stored as the JSON array from the plan file.
  /// Opaque to SQL and only ever read as a whole.
  final String? intervalsJson;
  final String? notes;
  const PlanItemRow({
    required this.id,
    required this.planBlockId,
    required this.exerciseId,
    required this.orderIndex,
    this.targetReps,
    this.targetWeightKg,
    this.weightMode,
    this.weightOffsetKg,
    this.weightPercent,
    this.rpe,
    this.tempo,
    required this.toFailure,
    this.targetDurationSeconds,
    this.targetDistanceMeters,
    this.targetPaceSecPerKm,
    this.targetInclinePercent,
    this.targetResistanceLevel,
    this.intervalsJson,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_block_id'] = Variable<int>(planBlockId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || weightMode != null) {
      map['weight_mode'] = Variable<String>(
        $PlanItemsTable.$converterweightModen.toSql(weightMode),
      );
    }
    if (!nullToAbsent || weightOffsetKg != null) {
      map['weight_offset_kg'] = Variable<double>(weightOffsetKg);
    }
    if (!nullToAbsent || weightPercent != null) {
      map['weight_percent'] = Variable<double>(weightPercent);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<String>(tempo);
    }
    map['to_failure'] = Variable<bool>(toFailure);
    if (!nullToAbsent || targetDurationSeconds != null) {
      map['target_duration_seconds'] = Variable<int>(targetDurationSeconds);
    }
    if (!nullToAbsent || targetDistanceMeters != null) {
      map['target_distance_meters'] = Variable<double>(targetDistanceMeters);
    }
    if (!nullToAbsent || targetPaceSecPerKm != null) {
      map['target_pace_sec_per_km'] = Variable<double>(targetPaceSecPerKm);
    }
    if (!nullToAbsent || targetInclinePercent != null) {
      map['target_incline_percent'] = Variable<double>(targetInclinePercent);
    }
    if (!nullToAbsent || targetResistanceLevel != null) {
      map['target_resistance_level'] = Variable<int>(targetResistanceLevel);
    }
    if (!nullToAbsent || intervalsJson != null) {
      map['intervals_json'] = Variable<String>(intervalsJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PlanItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanItemsCompanion(
      id: Value(id),
      planBlockId: Value(planBlockId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      weightMode: weightMode == null && nullToAbsent
          ? const Value.absent()
          : Value(weightMode),
      weightOffsetKg: weightOffsetKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightOffsetKg),
      weightPercent: weightPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(weightPercent),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      tempo: tempo == null && nullToAbsent
          ? const Value.absent()
          : Value(tempo),
      toFailure: Value(toFailure),
      targetDurationSeconds: targetDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDurationSeconds),
      targetDistanceMeters: targetDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDistanceMeters),
      targetPaceSecPerKm: targetPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPaceSecPerKm),
      targetInclinePercent: targetInclinePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(targetInclinePercent),
      targetResistanceLevel: targetResistanceLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(targetResistanceLevel),
      intervalsJson: intervalsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalsJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PlanItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanItemRow(
      id: serializer.fromJson<int>(json['id']),
      planBlockId: serializer.fromJson<int>(json['planBlockId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      weightMode: $PlanItemsTable.$converterweightModen.fromJson(
        serializer.fromJson<String?>(json['weightMode']),
      ),
      weightOffsetKg: serializer.fromJson<double?>(json['weightOffsetKg']),
      weightPercent: serializer.fromJson<double?>(json['weightPercent']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      tempo: serializer.fromJson<String?>(json['tempo']),
      toFailure: serializer.fromJson<bool>(json['toFailure']),
      targetDurationSeconds: serializer.fromJson<int?>(
        json['targetDurationSeconds'],
      ),
      targetDistanceMeters: serializer.fromJson<double?>(
        json['targetDistanceMeters'],
      ),
      targetPaceSecPerKm: serializer.fromJson<double?>(
        json['targetPaceSecPerKm'],
      ),
      targetInclinePercent: serializer.fromJson<double?>(
        json['targetInclinePercent'],
      ),
      targetResistanceLevel: serializer.fromJson<int?>(
        json['targetResistanceLevel'],
      ),
      intervalsJson: serializer.fromJson<String?>(json['intervalsJson']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planBlockId': serializer.toJson<int>(planBlockId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'targetReps': serializer.toJson<int?>(targetReps),
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'weightMode': serializer.toJson<String?>(
        $PlanItemsTable.$converterweightModen.toJson(weightMode),
      ),
      'weightOffsetKg': serializer.toJson<double?>(weightOffsetKg),
      'weightPercent': serializer.toJson<double?>(weightPercent),
      'rpe': serializer.toJson<double?>(rpe),
      'tempo': serializer.toJson<String?>(tempo),
      'toFailure': serializer.toJson<bool>(toFailure),
      'targetDurationSeconds': serializer.toJson<int?>(targetDurationSeconds),
      'targetDistanceMeters': serializer.toJson<double?>(targetDistanceMeters),
      'targetPaceSecPerKm': serializer.toJson<double?>(targetPaceSecPerKm),
      'targetInclinePercent': serializer.toJson<double?>(targetInclinePercent),
      'targetResistanceLevel': serializer.toJson<int?>(targetResistanceLevel),
      'intervalsJson': serializer.toJson<String?>(intervalsJson),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PlanItemRow copyWith({
    int? id,
    int? planBlockId,
    int? exerciseId,
    int? orderIndex,
    Value<int?> targetReps = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    Value<WeightMode?> weightMode = const Value.absent(),
    Value<double?> weightOffsetKg = const Value.absent(),
    Value<double?> weightPercent = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    Value<String?> tempo = const Value.absent(),
    bool? toFailure,
    Value<int?> targetDurationSeconds = const Value.absent(),
    Value<double?> targetDistanceMeters = const Value.absent(),
    Value<double?> targetPaceSecPerKm = const Value.absent(),
    Value<double?> targetInclinePercent = const Value.absent(),
    Value<int?> targetResistanceLevel = const Value.absent(),
    Value<String?> intervalsJson = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => PlanItemRow(
    id: id ?? this.id,
    planBlockId: planBlockId ?? this.planBlockId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    weightMode: weightMode.present ? weightMode.value : this.weightMode,
    weightOffsetKg: weightOffsetKg.present
        ? weightOffsetKg.value
        : this.weightOffsetKg,
    weightPercent: weightPercent.present
        ? weightPercent.value
        : this.weightPercent,
    rpe: rpe.present ? rpe.value : this.rpe,
    tempo: tempo.present ? tempo.value : this.tempo,
    toFailure: toFailure ?? this.toFailure,
    targetDurationSeconds: targetDurationSeconds.present
        ? targetDurationSeconds.value
        : this.targetDurationSeconds,
    targetDistanceMeters: targetDistanceMeters.present
        ? targetDistanceMeters.value
        : this.targetDistanceMeters,
    targetPaceSecPerKm: targetPaceSecPerKm.present
        ? targetPaceSecPerKm.value
        : this.targetPaceSecPerKm,
    targetInclinePercent: targetInclinePercent.present
        ? targetInclinePercent.value
        : this.targetInclinePercent,
    targetResistanceLevel: targetResistanceLevel.present
        ? targetResistanceLevel.value
        : this.targetResistanceLevel,
    intervalsJson: intervalsJson.present
        ? intervalsJson.value
        : this.intervalsJson,
    notes: notes.present ? notes.value : this.notes,
  );
  PlanItemRow copyWithCompanion(PlanItemsCompanion data) {
    return PlanItemRow(
      id: data.id.present ? data.id.value : this.id,
      planBlockId: data.planBlockId.present
          ? data.planBlockId.value
          : this.planBlockId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      weightMode: data.weightMode.present
          ? data.weightMode.value
          : this.weightMode,
      weightOffsetKg: data.weightOffsetKg.present
          ? data.weightOffsetKg.value
          : this.weightOffsetKg,
      weightPercent: data.weightPercent.present
          ? data.weightPercent.value
          : this.weightPercent,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      toFailure: data.toFailure.present ? data.toFailure.value : this.toFailure,
      targetDurationSeconds: data.targetDurationSeconds.present
          ? data.targetDurationSeconds.value
          : this.targetDurationSeconds,
      targetDistanceMeters: data.targetDistanceMeters.present
          ? data.targetDistanceMeters.value
          : this.targetDistanceMeters,
      targetPaceSecPerKm: data.targetPaceSecPerKm.present
          ? data.targetPaceSecPerKm.value
          : this.targetPaceSecPerKm,
      targetInclinePercent: data.targetInclinePercent.present
          ? data.targetInclinePercent.value
          : this.targetInclinePercent,
      targetResistanceLevel: data.targetResistanceLevel.present
          ? data.targetResistanceLevel.value
          : this.targetResistanceLevel,
      intervalsJson: data.intervalsJson.present
          ? data.intervalsJson.value
          : this.intervalsJson,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemRow(')
          ..write('id: $id, ')
          ..write('planBlockId: $planBlockId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('weightMode: $weightMode, ')
          ..write('weightOffsetKg: $weightOffsetKg, ')
          ..write('weightPercent: $weightPercent, ')
          ..write('rpe: $rpe, ')
          ..write('tempo: $tempo, ')
          ..write('toFailure: $toFailure, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('targetDistanceMeters: $targetDistanceMeters, ')
          ..write('targetPaceSecPerKm: $targetPaceSecPerKm, ')
          ..write('targetInclinePercent: $targetInclinePercent, ')
          ..write('targetResistanceLevel: $targetResistanceLevel, ')
          ..write('intervalsJson: $intervalsJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planBlockId,
    exerciseId,
    orderIndex,
    targetReps,
    targetWeightKg,
    weightMode,
    weightOffsetKg,
    weightPercent,
    rpe,
    tempo,
    toFailure,
    targetDurationSeconds,
    targetDistanceMeters,
    targetPaceSecPerKm,
    targetInclinePercent,
    targetResistanceLevel,
    intervalsJson,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanItemRow &&
          other.id == this.id &&
          other.planBlockId == this.planBlockId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.targetReps == this.targetReps &&
          other.targetWeightKg == this.targetWeightKg &&
          other.weightMode == this.weightMode &&
          other.weightOffsetKg == this.weightOffsetKg &&
          other.weightPercent == this.weightPercent &&
          other.rpe == this.rpe &&
          other.tempo == this.tempo &&
          other.toFailure == this.toFailure &&
          other.targetDurationSeconds == this.targetDurationSeconds &&
          other.targetDistanceMeters == this.targetDistanceMeters &&
          other.targetPaceSecPerKm == this.targetPaceSecPerKm &&
          other.targetInclinePercent == this.targetInclinePercent &&
          other.targetResistanceLevel == this.targetResistanceLevel &&
          other.intervalsJson == this.intervalsJson &&
          other.notes == this.notes);
}

class PlanItemsCompanion extends UpdateCompanion<PlanItemRow> {
  final Value<int> id;
  final Value<int> planBlockId;
  final Value<int> exerciseId;
  final Value<int> orderIndex;
  final Value<int?> targetReps;
  final Value<double?> targetWeightKg;
  final Value<WeightMode?> weightMode;
  final Value<double?> weightOffsetKg;
  final Value<double?> weightPercent;
  final Value<double?> rpe;
  final Value<String?> tempo;
  final Value<bool> toFailure;
  final Value<int?> targetDurationSeconds;
  final Value<double?> targetDistanceMeters;
  final Value<double?> targetPaceSecPerKm;
  final Value<double?> targetInclinePercent;
  final Value<int?> targetResistanceLevel;
  final Value<String?> intervalsJson;
  final Value<String?> notes;
  const PlanItemsCompanion({
    this.id = const Value.absent(),
    this.planBlockId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.weightMode = const Value.absent(),
    this.weightOffsetKg = const Value.absent(),
    this.weightPercent = const Value.absent(),
    this.rpe = const Value.absent(),
    this.tempo = const Value.absent(),
    this.toFailure = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.targetDistanceMeters = const Value.absent(),
    this.targetPaceSecPerKm = const Value.absent(),
    this.targetInclinePercent = const Value.absent(),
    this.targetResistanceLevel = const Value.absent(),
    this.intervalsJson = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PlanItemsCompanion.insert({
    this.id = const Value.absent(),
    required int planBlockId,
    required int exerciseId,
    required int orderIndex,
    this.targetReps = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.weightMode = const Value.absent(),
    this.weightOffsetKg = const Value.absent(),
    this.weightPercent = const Value.absent(),
    this.rpe = const Value.absent(),
    this.tempo = const Value.absent(),
    this.toFailure = const Value.absent(),
    this.targetDurationSeconds = const Value.absent(),
    this.targetDistanceMeters = const Value.absent(),
    this.targetPaceSecPerKm = const Value.absent(),
    this.targetInclinePercent = const Value.absent(),
    this.targetResistanceLevel = const Value.absent(),
    this.intervalsJson = const Value.absent(),
    this.notes = const Value.absent(),
  }) : planBlockId = Value(planBlockId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex);
  static Insertable<PlanItemRow> custom({
    Expression<int>? id,
    Expression<int>? planBlockId,
    Expression<int>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? targetReps,
    Expression<double>? targetWeightKg,
    Expression<String>? weightMode,
    Expression<double>? weightOffsetKg,
    Expression<double>? weightPercent,
    Expression<double>? rpe,
    Expression<String>? tempo,
    Expression<bool>? toFailure,
    Expression<int>? targetDurationSeconds,
    Expression<double>? targetDistanceMeters,
    Expression<double>? targetPaceSecPerKm,
    Expression<double>? targetInclinePercent,
    Expression<int>? targetResistanceLevel,
    Expression<String>? intervalsJson,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planBlockId != null) 'plan_block_id': planBlockId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (targetReps != null) 'target_reps': targetReps,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (weightMode != null) 'weight_mode': weightMode,
      if (weightOffsetKg != null) 'weight_offset_kg': weightOffsetKg,
      if (weightPercent != null) 'weight_percent': weightPercent,
      if (rpe != null) 'rpe': rpe,
      if (tempo != null) 'tempo': tempo,
      if (toFailure != null) 'to_failure': toFailure,
      if (targetDurationSeconds != null)
        'target_duration_seconds': targetDurationSeconds,
      if (targetDistanceMeters != null)
        'target_distance_meters': targetDistanceMeters,
      if (targetPaceSecPerKm != null)
        'target_pace_sec_per_km': targetPaceSecPerKm,
      if (targetInclinePercent != null)
        'target_incline_percent': targetInclinePercent,
      if (targetResistanceLevel != null)
        'target_resistance_level': targetResistanceLevel,
      if (intervalsJson != null) 'intervals_json': intervalsJson,
      if (notes != null) 'notes': notes,
    });
  }

  PlanItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? planBlockId,
    Value<int>? exerciseId,
    Value<int>? orderIndex,
    Value<int?>? targetReps,
    Value<double?>? targetWeightKg,
    Value<WeightMode?>? weightMode,
    Value<double?>? weightOffsetKg,
    Value<double?>? weightPercent,
    Value<double?>? rpe,
    Value<String?>? tempo,
    Value<bool>? toFailure,
    Value<int?>? targetDurationSeconds,
    Value<double?>? targetDistanceMeters,
    Value<double?>? targetPaceSecPerKm,
    Value<double?>? targetInclinePercent,
    Value<int?>? targetResistanceLevel,
    Value<String?>? intervalsJson,
    Value<String?>? notes,
  }) {
    return PlanItemsCompanion(
      id: id ?? this.id,
      planBlockId: planBlockId ?? this.planBlockId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetReps: targetReps ?? this.targetReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      weightMode: weightMode ?? this.weightMode,
      weightOffsetKg: weightOffsetKg ?? this.weightOffsetKg,
      weightPercent: weightPercent ?? this.weightPercent,
      rpe: rpe ?? this.rpe,
      tempo: tempo ?? this.tempo,
      toFailure: toFailure ?? this.toFailure,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      targetDistanceMeters: targetDistanceMeters ?? this.targetDistanceMeters,
      targetPaceSecPerKm: targetPaceSecPerKm ?? this.targetPaceSecPerKm,
      targetInclinePercent: targetInclinePercent ?? this.targetInclinePercent,
      targetResistanceLevel:
          targetResistanceLevel ?? this.targetResistanceLevel,
      intervalsJson: intervalsJson ?? this.intervalsJson,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planBlockId.present) {
      map['plan_block_id'] = Variable<int>(planBlockId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (weightMode.present) {
      map['weight_mode'] = Variable<String>(
        $PlanItemsTable.$converterweightModen.toSql(weightMode.value),
      );
    }
    if (weightOffsetKg.present) {
      map['weight_offset_kg'] = Variable<double>(weightOffsetKg.value);
    }
    if (weightPercent.present) {
      map['weight_percent'] = Variable<double>(weightPercent.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (tempo.present) {
      map['tempo'] = Variable<String>(tempo.value);
    }
    if (toFailure.present) {
      map['to_failure'] = Variable<bool>(toFailure.value);
    }
    if (targetDurationSeconds.present) {
      map['target_duration_seconds'] = Variable<int>(
        targetDurationSeconds.value,
      );
    }
    if (targetDistanceMeters.present) {
      map['target_distance_meters'] = Variable<double>(
        targetDistanceMeters.value,
      );
    }
    if (targetPaceSecPerKm.present) {
      map['target_pace_sec_per_km'] = Variable<double>(
        targetPaceSecPerKm.value,
      );
    }
    if (targetInclinePercent.present) {
      map['target_incline_percent'] = Variable<double>(
        targetInclinePercent.value,
      );
    }
    if (targetResistanceLevel.present) {
      map['target_resistance_level'] = Variable<int>(
        targetResistanceLevel.value,
      );
    }
    if (intervalsJson.present) {
      map['intervals_json'] = Variable<String>(intervalsJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('planBlockId: $planBlockId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('weightMode: $weightMode, ')
          ..write('weightOffsetKg: $weightOffsetKg, ')
          ..write('weightPercent: $weightPercent, ')
          ..write('rpe: $rpe, ')
          ..write('tempo: $tempo, ')
          ..write('toFailure: $toFailure, ')
          ..write('targetDurationSeconds: $targetDurationSeconds, ')
          ..write('targetDistanceMeters: $targetDistanceMeters, ')
          ..write('targetPaceSecPerKm: $targetPaceSecPerKm, ')
          ..write('targetInclinePercent: $targetInclinePercent, ')
          ..write('targetResistanceLevel: $targetResistanceLevel, ')
          ..write('intervalsJson: $intervalsJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _planDayIdMeta = const VerificationMeta(
    'planDayId',
  );
  @override
  late final GeneratedColumn<int> planDayId = GeneratedColumn<int>(
    'plan_day_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_days (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($SessionsTable.$converterstatus);
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    planDayId,
    title,
    startedAt,
    endedAt,
    status,
    durationSeconds,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('plan_day_id')) {
      context.handle(
        _planDayIdMeta,
        planDayId.isAcceptableOrUnknown(data['plan_day_id']!, _planDayIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      ),
      planDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_day_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: $SessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final int id;
  final int? planId;
  final int? planDayId;
  final String? title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;

  /// Elapsed working time, which can be less than `endedAt - startedAt` if the
  /// session sat open. Stored rather than derived so history stays truthful.
  final int? durationSeconds;
  final String? notes;
  const SessionRow({
    required this.id,
    this.planId,
    this.planDayId,
    this.title,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.durationSeconds,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<int>(planId);
    }
    if (!nullToAbsent || planDayId != null) {
      map['plan_day_id'] = Variable<int>(planDayId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      planDayId: planDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(planDayId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int?>(json['planId']),
      planDayId: serializer.fromJson<int?>(json['planDayId']),
      title: serializer.fromJson<String?>(json['title']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: $SessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int?>(planId),
      'planDayId': serializer.toJson<int?>(planDayId),
      'title': serializer.toJson<String?>(title),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(
        $SessionsTable.$converterstatus.toJson(status),
      ),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SessionRow copyWith({
    int? id,
    Value<int?> planId = const Value.absent(),
    Value<int?> planDayId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    SessionStatus? status,
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    planId: planId.present ? planId.value : this.planId,
    planDayId: planDayId.present ? planDayId.value : this.planDayId,
    title: title.present ? title.value : this.title,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    notes: notes.present ? notes.value : this.notes,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      planDayId: data.planDayId.present ? data.planDayId.value : this.planDayId,
      title: data.title.present ? data.title.value : this.title,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('planDayId: $planDayId, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    planDayId,
    title,
    startedAt,
    endedAt,
    status,
    durationSeconds,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.planDayId == this.planDayId &&
          other.title == this.title &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.durationSeconds == this.durationSeconds &&
          other.notes == this.notes);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<int?> planId;
  final Value<int?> planDayId;
  final Value<String?> title;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<SessionStatus> status;
  final Value<int?> durationSeconds;
  final Value<String?> notes;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.title = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required SessionStatus status,
    this.durationSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  }) : startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? planDayId,
    Expression<String>? title,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<int>? durationSeconds,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (planDayId != null) 'plan_day_id': planDayId,
      if (title != null) 'title': title,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (notes != null) 'notes': notes,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? planId,
    Value<int?>? planDayId,
    Value<String?>? title,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<SessionStatus>? status,
    Value<int?>? durationSeconds,
    Value<String?>? notes,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      planDayId: planDayId ?? this.planDayId,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (planDayId.present) {
      map['plan_day_id'] = Variable<int>(planDayId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('planDayId: $planDayId, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $StrengthSetsTable extends StrengthSets
    with TableInfo<$StrengthSetsTable, StrengthSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrengthSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _planItemIdMeta = const VerificationMeta(
    'planItemId',
  );
  @override
  late final GeneratedColumn<int> planItemId = GeneratedColumn<int>(
    'plan_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_items (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _groupIndexMeta = const VerificationMeta(
    'groupIndex',
  );
  @override
  late final GeneratedColumn<int> groupIndex = GeneratedColumn<int>(
    'group_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlockKind, String> groupKind =
      GeneratedColumn<String>(
        'group_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BlockKind>($StrengthSetsTable.$convertergroupKind);
  static const VerificationMeta _groupLabelMeta = const VerificationMeta(
    'groupLabel',
  );
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<int> itemIndex = GeneratedColumn<int>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedRepsMeta = const VerificationMeta(
    'plannedReps',
  );
  @override
  late final GeneratedColumn<int> plannedReps = GeneratedColumn<int>(
    'planned_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedWeightKgMeta = const VerificationMeta(
    'plannedWeightKg',
  );
  @override
  late final GeneratedColumn<double> plannedWeightKg = GeneratedColumn<double>(
    'planned_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRepsMeta = const VerificationMeta(
    'actualReps',
  );
  @override
  late final GeneratedColumn<int> actualReps = GeneratedColumn<int>(
    'actual_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualWeightKgMeta = const VerificationMeta(
    'actualWeightKg',
  );
  @override
  late final GeneratedColumn<double> actualWeightKg = GeneratedColumn<double>(
    'actual_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntryStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EntryStatus>($StrengthSetsTable.$converterstatus);
  static const VerificationMeta _restTakenSecondsMeta = const VerificationMeta(
    'restTakenSeconds',
  );
  @override
  late final GeneratedColumn<int> restTakenSeconds = GeneratedColumn<int>(
    'rest_taken_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    planItemId,
    groupIndex,
    groupKind,
    groupLabel,
    roundIndex,
    itemIndex,
    plannedReps,
    plannedWeightKg,
    actualReps,
    actualWeightKg,
    rpe,
    isWarmup,
    status,
    restTakenSeconds,
    performedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strength_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<StrengthSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('plan_item_id')) {
      context.handle(
        _planItemIdMeta,
        planItemId.isAcceptableOrUnknown(
          data['plan_item_id']!,
          _planItemIdMeta,
        ),
      );
    }
    if (data.containsKey('group_index')) {
      context.handle(
        _groupIndexMeta,
        groupIndex.isAcceptableOrUnknown(data['group_index']!, _groupIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIndexMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('planned_reps')) {
      context.handle(
        _plannedRepsMeta,
        plannedReps.isAcceptableOrUnknown(
          data['planned_reps']!,
          _plannedRepsMeta,
        ),
      );
    }
    if (data.containsKey('planned_weight_kg')) {
      context.handle(
        _plannedWeightKgMeta,
        plannedWeightKg.isAcceptableOrUnknown(
          data['planned_weight_kg']!,
          _plannedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('actual_reps')) {
      context.handle(
        _actualRepsMeta,
        actualReps.isAcceptableOrUnknown(data['actual_reps']!, _actualRepsMeta),
      );
    }
    if (data.containsKey('actual_weight_kg')) {
      context.handle(
        _actualWeightKgMeta,
        actualWeightKg.isAcceptableOrUnknown(
          data['actual_weight_kg']!,
          _actualWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('rest_taken_seconds')) {
      context.handle(
        _restTakenSecondsMeta,
        restTakenSeconds.isAcceptableOrUnknown(
          data['rest_taken_seconds']!,
          _restTakenSecondsMeta,
        ),
      );
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StrengthSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StrengthSetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      planItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_item_id'],
      ),
      groupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_index'],
      )!,
      groupKind: $StrengthSetsTable.$convertergroupKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}group_kind'],
        )!,
      ),
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_index'],
      )!,
      plannedReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_reps'],
      ),
      plannedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_weight_kg'],
      ),
      actualReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_reps'],
      ),
      actualWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_weight_kg'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      status: $StrengthSetsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      restTakenSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_taken_seconds'],
      ),
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $StrengthSetsTable createAlias(String alias) {
    return $StrengthSetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlockKind, String, String> $convertergroupKind =
      const EnumNameConverter<BlockKind>(BlockKind.values);
  static JsonTypeConverter2<EntryStatus, String, String> $converterstatus =
      const EnumNameConverter<EntryStatus>(EntryStatus.values);
}

class StrengthSetRow extends DataClass implements Insertable<StrengthSetRow> {
  final int id;
  final int sessionId;
  final int exerciseId;
  final int? planItemId;

  /// Which block within the session, preserving superset grouping in history
  /// even after the originating plan changes.
  final int groupIndex;
  final BlockKind groupKind;
  final String? groupLabel;

  /// Which time through the block (0-based).
  final int roundIndex;

  /// Position within the block (0-based).
  final int itemIndex;
  final int? plannedReps;
  final double? plannedWeightKg;
  final int? actualReps;
  final double? actualWeightKg;
  final double? rpe;

  /// Warm-up sets are excluded from baseline promotion and personal records.
  final bool isWarmup;
  final EntryStatus status;
  final int? restTakenSeconds;
  final DateTime? performedAt;
  final String? notes;
  const StrengthSetRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    this.planItemId,
    required this.groupIndex,
    required this.groupKind,
    this.groupLabel,
    required this.roundIndex,
    required this.itemIndex,
    this.plannedReps,
    this.plannedWeightKg,
    this.actualReps,
    this.actualWeightKg,
    this.rpe,
    required this.isWarmup,
    required this.status,
    this.restTakenSeconds,
    this.performedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || planItemId != null) {
      map['plan_item_id'] = Variable<int>(planItemId);
    }
    map['group_index'] = Variable<int>(groupIndex);
    {
      map['group_kind'] = Variable<String>(
        $StrengthSetsTable.$convertergroupKind.toSql(groupKind),
      );
    }
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    map['round_index'] = Variable<int>(roundIndex);
    map['item_index'] = Variable<int>(itemIndex);
    if (!nullToAbsent || plannedReps != null) {
      map['planned_reps'] = Variable<int>(plannedReps);
    }
    if (!nullToAbsent || plannedWeightKg != null) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg);
    }
    if (!nullToAbsent || actualReps != null) {
      map['actual_reps'] = Variable<int>(actualReps);
    }
    if (!nullToAbsent || actualWeightKg != null) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    map['is_warmup'] = Variable<bool>(isWarmup);
    {
      map['status'] = Variable<String>(
        $StrengthSetsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || restTakenSeconds != null) {
      map['rest_taken_seconds'] = Variable<int>(restTakenSeconds);
    }
    if (!nullToAbsent || performedAt != null) {
      map['performed_at'] = Variable<DateTime>(performedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  StrengthSetsCompanion toCompanion(bool nullToAbsent) {
    return StrengthSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      planItemId: planItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(planItemId),
      groupIndex: Value(groupIndex),
      groupKind: Value(groupKind),
      groupLabel: groupLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(groupLabel),
      roundIndex: Value(roundIndex),
      itemIndex: Value(itemIndex),
      plannedReps: plannedReps == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedReps),
      plannedWeightKg: plannedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedWeightKg),
      actualReps: actualReps == null && nullToAbsent
          ? const Value.absent()
          : Value(actualReps),
      actualWeightKg: actualWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(actualWeightKg),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      isWarmup: Value(isWarmup),
      status: Value(status),
      restTakenSeconds: restTakenSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restTakenSeconds),
      performedAt: performedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(performedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory StrengthSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StrengthSetRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      planItemId: serializer.fromJson<int?>(json['planItemId']),
      groupIndex: serializer.fromJson<int>(json['groupIndex']),
      groupKind: $StrengthSetsTable.$convertergroupKind.fromJson(
        serializer.fromJson<String>(json['groupKind']),
      ),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      itemIndex: serializer.fromJson<int>(json['itemIndex']),
      plannedReps: serializer.fromJson<int?>(json['plannedReps']),
      plannedWeightKg: serializer.fromJson<double?>(json['plannedWeightKg']),
      actualReps: serializer.fromJson<int?>(json['actualReps']),
      actualWeightKg: serializer.fromJson<double?>(json['actualWeightKg']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      status: $StrengthSetsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      restTakenSeconds: serializer.fromJson<int?>(json['restTakenSeconds']),
      performedAt: serializer.fromJson<DateTime?>(json['performedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'planItemId': serializer.toJson<int?>(planItemId),
      'groupIndex': serializer.toJson<int>(groupIndex),
      'groupKind': serializer.toJson<String>(
        $StrengthSetsTable.$convertergroupKind.toJson(groupKind),
      ),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'itemIndex': serializer.toJson<int>(itemIndex),
      'plannedReps': serializer.toJson<int?>(plannedReps),
      'plannedWeightKg': serializer.toJson<double?>(plannedWeightKg),
      'actualReps': serializer.toJson<int?>(actualReps),
      'actualWeightKg': serializer.toJson<double?>(actualWeightKg),
      'rpe': serializer.toJson<double?>(rpe),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'status': serializer.toJson<String>(
        $StrengthSetsTable.$converterstatus.toJson(status),
      ),
      'restTakenSeconds': serializer.toJson<int?>(restTakenSeconds),
      'performedAt': serializer.toJson<DateTime?>(performedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  StrengthSetRow copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    Value<int?> planItemId = const Value.absent(),
    int? groupIndex,
    BlockKind? groupKind,
    Value<String?> groupLabel = const Value.absent(),
    int? roundIndex,
    int? itemIndex,
    Value<int?> plannedReps = const Value.absent(),
    Value<double?> plannedWeightKg = const Value.absent(),
    Value<int?> actualReps = const Value.absent(),
    Value<double?> actualWeightKg = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    bool? isWarmup,
    EntryStatus? status,
    Value<int?> restTakenSeconds = const Value.absent(),
    Value<DateTime?> performedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => StrengthSetRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    planItemId: planItemId.present ? planItemId.value : this.planItemId,
    groupIndex: groupIndex ?? this.groupIndex,
    groupKind: groupKind ?? this.groupKind,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    roundIndex: roundIndex ?? this.roundIndex,
    itemIndex: itemIndex ?? this.itemIndex,
    plannedReps: plannedReps.present ? plannedReps.value : this.plannedReps,
    plannedWeightKg: plannedWeightKg.present
        ? plannedWeightKg.value
        : this.plannedWeightKg,
    actualReps: actualReps.present ? actualReps.value : this.actualReps,
    actualWeightKg: actualWeightKg.present
        ? actualWeightKg.value
        : this.actualWeightKg,
    rpe: rpe.present ? rpe.value : this.rpe,
    isWarmup: isWarmup ?? this.isWarmup,
    status: status ?? this.status,
    restTakenSeconds: restTakenSeconds.present
        ? restTakenSeconds.value
        : this.restTakenSeconds,
    performedAt: performedAt.present ? performedAt.value : this.performedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  StrengthSetRow copyWithCompanion(StrengthSetsCompanion data) {
    return StrengthSetRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      planItemId: data.planItemId.present
          ? data.planItemId.value
          : this.planItemId,
      groupIndex: data.groupIndex.present
          ? data.groupIndex.value
          : this.groupIndex,
      groupKind: data.groupKind.present ? data.groupKind.value : this.groupKind,
      groupLabel: data.groupLabel.present
          ? data.groupLabel.value
          : this.groupLabel,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      plannedReps: data.plannedReps.present
          ? data.plannedReps.value
          : this.plannedReps,
      plannedWeightKg: data.plannedWeightKg.present
          ? data.plannedWeightKg.value
          : this.plannedWeightKg,
      actualReps: data.actualReps.present
          ? data.actualReps.value
          : this.actualReps,
      actualWeightKg: data.actualWeightKg.present
          ? data.actualWeightKg.value
          : this.actualWeightKg,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      status: data.status.present ? data.status.value : this.status,
      restTakenSeconds: data.restTakenSeconds.present
          ? data.restTakenSeconds.value
          : this.restTakenSeconds,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StrengthSetRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planItemId: $planItemId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('groupKind: $groupKind, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('actualReps: $actualReps, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('rpe: $rpe, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('status: $status, ')
          ..write('restTakenSeconds: $restTakenSeconds, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseId,
    planItemId,
    groupIndex,
    groupKind,
    groupLabel,
    roundIndex,
    itemIndex,
    plannedReps,
    plannedWeightKg,
    actualReps,
    actualWeightKg,
    rpe,
    isWarmup,
    status,
    restTakenSeconds,
    performedAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StrengthSetRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.planItemId == this.planItemId &&
          other.groupIndex == this.groupIndex &&
          other.groupKind == this.groupKind &&
          other.groupLabel == this.groupLabel &&
          other.roundIndex == this.roundIndex &&
          other.itemIndex == this.itemIndex &&
          other.plannedReps == this.plannedReps &&
          other.plannedWeightKg == this.plannedWeightKg &&
          other.actualReps == this.actualReps &&
          other.actualWeightKg == this.actualWeightKg &&
          other.rpe == this.rpe &&
          other.isWarmup == this.isWarmup &&
          other.status == this.status &&
          other.restTakenSeconds == this.restTakenSeconds &&
          other.performedAt == this.performedAt &&
          other.notes == this.notes);
}

class StrengthSetsCompanion extends UpdateCompanion<StrengthSetRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int?> planItemId;
  final Value<int> groupIndex;
  final Value<BlockKind> groupKind;
  final Value<String?> groupLabel;
  final Value<int> roundIndex;
  final Value<int> itemIndex;
  final Value<int?> plannedReps;
  final Value<double?> plannedWeightKg;
  final Value<int?> actualReps;
  final Value<double?> actualWeightKg;
  final Value<double?> rpe;
  final Value<bool> isWarmup;
  final Value<EntryStatus> status;
  final Value<int?> restTakenSeconds;
  final Value<DateTime?> performedAt;
  final Value<String?> notes;
  const StrengthSetsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.planItemId = const Value.absent(),
    this.groupIndex = const Value.absent(),
    this.groupKind = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.plannedReps = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.rpe = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.status = const Value.absent(),
    this.restTakenSeconds = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  StrengthSetsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    this.planItemId = const Value.absent(),
    required int groupIndex,
    required BlockKind groupKind,
    this.groupLabel = const Value.absent(),
    required int roundIndex,
    required int itemIndex,
    this.plannedReps = const Value.absent(),
    this.plannedWeightKg = const Value.absent(),
    this.actualReps = const Value.absent(),
    this.actualWeightKg = const Value.absent(),
    this.rpe = const Value.absent(),
    this.isWarmup = const Value.absent(),
    required EntryStatus status,
    this.restTakenSeconds = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       groupIndex = Value(groupIndex),
       groupKind = Value(groupKind),
       roundIndex = Value(roundIndex),
       itemIndex = Value(itemIndex),
       status = Value(status);
  static Insertable<StrengthSetRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? planItemId,
    Expression<int>? groupIndex,
    Expression<String>? groupKind,
    Expression<String>? groupLabel,
    Expression<int>? roundIndex,
    Expression<int>? itemIndex,
    Expression<int>? plannedReps,
    Expression<double>? plannedWeightKg,
    Expression<int>? actualReps,
    Expression<double>? actualWeightKg,
    Expression<double>? rpe,
    Expression<bool>? isWarmup,
    Expression<String>? status,
    Expression<int>? restTakenSeconds,
    Expression<DateTime>? performedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (planItemId != null) 'plan_item_id': planItemId,
      if (groupIndex != null) 'group_index': groupIndex,
      if (groupKind != null) 'group_kind': groupKind,
      if (groupLabel != null) 'group_label': groupLabel,
      if (roundIndex != null) 'round_index': roundIndex,
      if (itemIndex != null) 'item_index': itemIndex,
      if (plannedReps != null) 'planned_reps': plannedReps,
      if (plannedWeightKg != null) 'planned_weight_kg': plannedWeightKg,
      if (actualReps != null) 'actual_reps': actualReps,
      if (actualWeightKg != null) 'actual_weight_kg': actualWeightKg,
      if (rpe != null) 'rpe': rpe,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (status != null) 'status': status,
      if (restTakenSeconds != null) 'rest_taken_seconds': restTakenSeconds,
      if (performedAt != null) 'performed_at': performedAt,
      if (notes != null) 'notes': notes,
    });
  }

  StrengthSetsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int?>? planItemId,
    Value<int>? groupIndex,
    Value<BlockKind>? groupKind,
    Value<String?>? groupLabel,
    Value<int>? roundIndex,
    Value<int>? itemIndex,
    Value<int?>? plannedReps,
    Value<double?>? plannedWeightKg,
    Value<int?>? actualReps,
    Value<double?>? actualWeightKg,
    Value<double?>? rpe,
    Value<bool>? isWarmup,
    Value<EntryStatus>? status,
    Value<int?>? restTakenSeconds,
    Value<DateTime?>? performedAt,
    Value<String?>? notes,
  }) {
    return StrengthSetsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      planItemId: planItemId ?? this.planItemId,
      groupIndex: groupIndex ?? this.groupIndex,
      groupKind: groupKind ?? this.groupKind,
      groupLabel: groupLabel ?? this.groupLabel,
      roundIndex: roundIndex ?? this.roundIndex,
      itemIndex: itemIndex ?? this.itemIndex,
      plannedReps: plannedReps ?? this.plannedReps,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      actualReps: actualReps ?? this.actualReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      status: status ?? this.status,
      restTakenSeconds: restTakenSeconds ?? this.restTakenSeconds,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (planItemId.present) {
      map['plan_item_id'] = Variable<int>(planItemId.value);
    }
    if (groupIndex.present) {
      map['group_index'] = Variable<int>(groupIndex.value);
    }
    if (groupKind.present) {
      map['group_kind'] = Variable<String>(
        $StrengthSetsTable.$convertergroupKind.toSql(groupKind.value),
      );
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<int>(itemIndex.value);
    }
    if (plannedReps.present) {
      map['planned_reps'] = Variable<int>(plannedReps.value);
    }
    if (plannedWeightKg.present) {
      map['planned_weight_kg'] = Variable<double>(plannedWeightKg.value);
    }
    if (actualReps.present) {
      map['actual_reps'] = Variable<int>(actualReps.value);
    }
    if (actualWeightKg.present) {
      map['actual_weight_kg'] = Variable<double>(actualWeightKg.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $StrengthSetsTable.$converterstatus.toSql(status.value),
      );
    }
    if (restTakenSeconds.present) {
      map['rest_taken_seconds'] = Variable<int>(restTakenSeconds.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrengthSetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planItemId: $planItemId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('groupKind: $groupKind, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('plannedReps: $plannedReps, ')
          ..write('plannedWeightKg: $plannedWeightKg, ')
          ..write('actualReps: $actualReps, ')
          ..write('actualWeightKg: $actualWeightKg, ')
          ..write('rpe: $rpe, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('status: $status, ')
          ..write('restTakenSeconds: $restTakenSeconds, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CardioEntriesTable extends CardioEntries
    with TableInfo<$CardioEntriesTable, CardioEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _planItemIdMeta = const VerificationMeta(
    'planItemId',
  );
  @override
  late final GeneratedColumn<int> planItemId = GeneratedColumn<int>(
    'plan_item_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_items (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _groupIndexMeta = const VerificationMeta(
    'groupIndex',
  );
  @override
  late final GeneratedColumn<int> groupIndex = GeneratedColumn<int>(
    'group_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BlockKind, String> groupKind =
      GeneratedColumn<String>(
        'group_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BlockKind>($CardioEntriesTable.$convertergroupKind);
  static const VerificationMeta _groupLabelMeta = const VerificationMeta(
    'groupLabel',
  );
  @override
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>(
    'group_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundIndexMeta = const VerificationMeta(
    'roundIndex',
  );
  @override
  late final GeneratedColumn<int> roundIndex = GeneratedColumn<int>(
    'round_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIndexMeta = const VerificationMeta(
    'itemIndex',
  );
  @override
  late final GeneratedColumn<int> itemIndex = GeneratedColumn<int>(
    'item_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedDurationSecondsMeta =
      const VerificationMeta('plannedDurationSeconds');
  @override
  late final GeneratedColumn<int> plannedDurationSeconds = GeneratedColumn<int>(
    'planned_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDistanceMetersMeta =
      const VerificationMeta('plannedDistanceMeters');
  @override
  late final GeneratedColumn<double> plannedDistanceMeters =
      GeneratedColumn<double>(
        'planned_distance_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _plannedPaceSecPerKmMeta =
      const VerificationMeta('plannedPaceSecPerKm');
  @override
  late final GeneratedColumn<double> plannedPaceSecPerKm =
      GeneratedColumn<double>(
        'planned_pace_sec_per_km',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualDurationSecondsMeta =
      const VerificationMeta('actualDurationSeconds');
  @override
  late final GeneratedColumn<int> actualDurationSeconds = GeneratedColumn<int>(
    'actual_duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualDistanceMetersMeta =
      const VerificationMeta('actualDistanceMeters');
  @override
  late final GeneratedColumn<double> actualDistanceMeters =
      GeneratedColumn<double>(
        'actual_distance_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualPaceSecPerKmMeta =
      const VerificationMeta('actualPaceSecPerKm');
  @override
  late final GeneratedColumn<double> actualPaceSecPerKm =
      GeneratedColumn<double>(
        'actual_pace_sec_per_km',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _inclinePercentMeta = const VerificationMeta(
    'inclinePercent',
  );
  @override
  late final GeneratedColumn<double> inclinePercent = GeneratedColumn<double>(
    'incline_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resistanceLevelMeta = const VerificationMeta(
    'resistanceLevel',
  );
  @override
  late final GeneratedColumn<int> resistanceLevel = GeneratedColumn<int>(
    'resistance_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avgHeartRateMeta = const VerificationMeta(
    'avgHeartRate',
  );
  @override
  late final GeneratedColumn<int> avgHeartRate = GeneratedColumn<int>(
    'avg_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<int> maxHeartRate = GeneratedColumn<int>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<EntryStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EntryStatus>($CardioEntriesTable.$converterstatus);
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    planItemId,
    groupIndex,
    groupKind,
    groupLabel,
    roundIndex,
    itemIndex,
    plannedDurationSeconds,
    plannedDistanceMeters,
    plannedPaceSecPerKm,
    actualDurationSeconds,
    actualDistanceMeters,
    actualPaceSecPerKm,
    inclinePercent,
    resistanceLevel,
    avgHeartRate,
    maxHeartRate,
    calories,
    elevationGainMeters,
    status,
    performedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('plan_item_id')) {
      context.handle(
        _planItemIdMeta,
        planItemId.isAcceptableOrUnknown(
          data['plan_item_id']!,
          _planItemIdMeta,
        ),
      );
    }
    if (data.containsKey('group_index')) {
      context.handle(
        _groupIndexMeta,
        groupIndex.isAcceptableOrUnknown(data['group_index']!, _groupIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIndexMeta);
    }
    if (data.containsKey('group_label')) {
      context.handle(
        _groupLabelMeta,
        groupLabel.isAcceptableOrUnknown(data['group_label']!, _groupLabelMeta),
      );
    }
    if (data.containsKey('round_index')) {
      context.handle(
        _roundIndexMeta,
        roundIndex.isAcceptableOrUnknown(data['round_index']!, _roundIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIndexMeta);
    }
    if (data.containsKey('item_index')) {
      context.handle(
        _itemIndexMeta,
        itemIndex.isAcceptableOrUnknown(data['item_index']!, _itemIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIndexMeta);
    }
    if (data.containsKey('planned_duration_seconds')) {
      context.handle(
        _plannedDurationSecondsMeta,
        plannedDurationSeconds.isAcceptableOrUnknown(
          data['planned_duration_seconds']!,
          _plannedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('planned_distance_meters')) {
      context.handle(
        _plannedDistanceMetersMeta,
        plannedDistanceMeters.isAcceptableOrUnknown(
          data['planned_distance_meters']!,
          _plannedDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('planned_pace_sec_per_km')) {
      context.handle(
        _plannedPaceSecPerKmMeta,
        plannedPaceSecPerKm.isAcceptableOrUnknown(
          data['planned_pace_sec_per_km']!,
          _plannedPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('actual_duration_seconds')) {
      context.handle(
        _actualDurationSecondsMeta,
        actualDurationSeconds.isAcceptableOrUnknown(
          data['actual_duration_seconds']!,
          _actualDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('actual_distance_meters')) {
      context.handle(
        _actualDistanceMetersMeta,
        actualDistanceMeters.isAcceptableOrUnknown(
          data['actual_distance_meters']!,
          _actualDistanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('actual_pace_sec_per_km')) {
      context.handle(
        _actualPaceSecPerKmMeta,
        actualPaceSecPerKm.isAcceptableOrUnknown(
          data['actual_pace_sec_per_km']!,
          _actualPaceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('incline_percent')) {
      context.handle(
        _inclinePercentMeta,
        inclinePercent.isAcceptableOrUnknown(
          data['incline_percent']!,
          _inclinePercentMeta,
        ),
      );
    }
    if (data.containsKey('resistance_level')) {
      context.handle(
        _resistanceLevelMeta,
        resistanceLevel.isAcceptableOrUnknown(
          data['resistance_level']!,
          _resistanceLevelMeta,
        ),
      );
    }
    if (data.containsKey('avg_heart_rate')) {
      context.handle(
        _avgHeartRateMeta,
        avgHeartRate.isAcceptableOrUnknown(
          data['avg_heart_rate']!,
          _avgHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardioEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      planItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_item_id'],
      ),
      groupIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group_index'],
      )!,
      groupKind: $CardioEntriesTable.$convertergroupKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}group_kind'],
        )!,
      ),
      groupLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_label'],
      ),
      roundIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_index'],
      )!,
      itemIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_index'],
      )!,
      plannedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_seconds'],
      ),
      plannedDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_distance_meters'],
      ),
      plannedPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}planned_pace_sec_per_km'],
      ),
      actualDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_seconds'],
      ),
      actualDistanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_distance_meters'],
      ),
      actualPaceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_pace_sec_per_km'],
      ),
      inclinePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}incline_percent'],
      ),
      resistanceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resistance_level'],
      ),
      avgHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_heart_rate'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_heart_rate'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      ),
      status: $CardioEntriesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CardioEntriesTable createAlias(String alias) {
    return $CardioEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BlockKind, String, String> $convertergroupKind =
      const EnumNameConverter<BlockKind>(BlockKind.values);
  static JsonTypeConverter2<EntryStatus, String, String> $converterstatus =
      const EnumNameConverter<EntryStatus>(EntryStatus.values);
}

class CardioEntryRow extends DataClass implements Insertable<CardioEntryRow> {
  final int id;
  final int sessionId;
  final int exerciseId;
  final int? planItemId;
  final int groupIndex;
  final BlockKind groupKind;
  final String? groupLabel;
  final int roundIndex;
  final int itemIndex;
  final int? plannedDurationSeconds;
  final double? plannedDistanceMeters;
  final double? plannedPaceSecPerKm;
  final int? actualDurationSeconds;
  final double? actualDistanceMeters;

  /// Derived from duration and distance on write, stored so history and chart
  /// queries do not have to recompute it per row.
  final double? actualPaceSecPerKm;
  final double? inclinePercent;
  final int? resistanceLevel;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? calories;
  final double? elevationGainMeters;
  final EntryStatus status;
  final DateTime? performedAt;
  final String? notes;
  const CardioEntryRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    this.planItemId,
    required this.groupIndex,
    required this.groupKind,
    this.groupLabel,
    required this.roundIndex,
    required this.itemIndex,
    this.plannedDurationSeconds,
    this.plannedDistanceMeters,
    this.plannedPaceSecPerKm,
    this.actualDurationSeconds,
    this.actualDistanceMeters,
    this.actualPaceSecPerKm,
    this.inclinePercent,
    this.resistanceLevel,
    this.avgHeartRate,
    this.maxHeartRate,
    this.calories,
    this.elevationGainMeters,
    required this.status,
    this.performedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['exercise_id'] = Variable<int>(exerciseId);
    if (!nullToAbsent || planItemId != null) {
      map['plan_item_id'] = Variable<int>(planItemId);
    }
    map['group_index'] = Variable<int>(groupIndex);
    {
      map['group_kind'] = Variable<String>(
        $CardioEntriesTable.$convertergroupKind.toSql(groupKind),
      );
    }
    if (!nullToAbsent || groupLabel != null) {
      map['group_label'] = Variable<String>(groupLabel);
    }
    map['round_index'] = Variable<int>(roundIndex);
    map['item_index'] = Variable<int>(itemIndex);
    if (!nullToAbsent || plannedDurationSeconds != null) {
      map['planned_duration_seconds'] = Variable<int>(plannedDurationSeconds);
    }
    if (!nullToAbsent || plannedDistanceMeters != null) {
      map['planned_distance_meters'] = Variable<double>(plannedDistanceMeters);
    }
    if (!nullToAbsent || plannedPaceSecPerKm != null) {
      map['planned_pace_sec_per_km'] = Variable<double>(plannedPaceSecPerKm);
    }
    if (!nullToAbsent || actualDurationSeconds != null) {
      map['actual_duration_seconds'] = Variable<int>(actualDurationSeconds);
    }
    if (!nullToAbsent || actualDistanceMeters != null) {
      map['actual_distance_meters'] = Variable<double>(actualDistanceMeters);
    }
    if (!nullToAbsent || actualPaceSecPerKm != null) {
      map['actual_pace_sec_per_km'] = Variable<double>(actualPaceSecPerKm);
    }
    if (!nullToAbsent || inclinePercent != null) {
      map['incline_percent'] = Variable<double>(inclinePercent);
    }
    if (!nullToAbsent || resistanceLevel != null) {
      map['resistance_level'] = Variable<int>(resistanceLevel);
    }
    if (!nullToAbsent || avgHeartRate != null) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate);
    }
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || elevationGainMeters != null) {
      map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    }
    {
      map['status'] = Variable<String>(
        $CardioEntriesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || performedAt != null) {
      map['performed_at'] = Variable<DateTime>(performedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CardioEntriesCompanion toCompanion(bool nullToAbsent) {
    return CardioEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      planItemId: planItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(planItemId),
      groupIndex: Value(groupIndex),
      groupKind: Value(groupKind),
      groupLabel: groupLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(groupLabel),
      roundIndex: Value(roundIndex),
      itemIndex: Value(itemIndex),
      plannedDurationSeconds: plannedDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDurationSeconds),
      plannedDistanceMeters: plannedDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDistanceMeters),
      plannedPaceSecPerKm: plannedPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedPaceSecPerKm),
      actualDurationSeconds: actualDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationSeconds),
      actualDistanceMeters: actualDistanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDistanceMeters),
      actualPaceSecPerKm: actualPaceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(actualPaceSecPerKm),
      inclinePercent: inclinePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(inclinePercent),
      resistanceLevel: resistanceLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(resistanceLevel),
      avgHeartRate: avgHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(avgHeartRate),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      elevationGainMeters: elevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainMeters),
      status: Value(status),
      performedAt: performedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(performedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CardioEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioEntryRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      planItemId: serializer.fromJson<int?>(json['planItemId']),
      groupIndex: serializer.fromJson<int>(json['groupIndex']),
      groupKind: $CardioEntriesTable.$convertergroupKind.fromJson(
        serializer.fromJson<String>(json['groupKind']),
      ),
      groupLabel: serializer.fromJson<String?>(json['groupLabel']),
      roundIndex: serializer.fromJson<int>(json['roundIndex']),
      itemIndex: serializer.fromJson<int>(json['itemIndex']),
      plannedDurationSeconds: serializer.fromJson<int?>(
        json['plannedDurationSeconds'],
      ),
      plannedDistanceMeters: serializer.fromJson<double?>(
        json['plannedDistanceMeters'],
      ),
      plannedPaceSecPerKm: serializer.fromJson<double?>(
        json['plannedPaceSecPerKm'],
      ),
      actualDurationSeconds: serializer.fromJson<int?>(
        json['actualDurationSeconds'],
      ),
      actualDistanceMeters: serializer.fromJson<double?>(
        json['actualDistanceMeters'],
      ),
      actualPaceSecPerKm: serializer.fromJson<double?>(
        json['actualPaceSecPerKm'],
      ),
      inclinePercent: serializer.fromJson<double?>(json['inclinePercent']),
      resistanceLevel: serializer.fromJson<int?>(json['resistanceLevel']),
      avgHeartRate: serializer.fromJson<int?>(json['avgHeartRate']),
      maxHeartRate: serializer.fromJson<int?>(json['maxHeartRate']),
      calories: serializer.fromJson<int?>(json['calories']),
      elevationGainMeters: serializer.fromJson<double?>(
        json['elevationGainMeters'],
      ),
      status: $CardioEntriesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      performedAt: serializer.fromJson<DateTime?>(json['performedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'planItemId': serializer.toJson<int?>(planItemId),
      'groupIndex': serializer.toJson<int>(groupIndex),
      'groupKind': serializer.toJson<String>(
        $CardioEntriesTable.$convertergroupKind.toJson(groupKind),
      ),
      'groupLabel': serializer.toJson<String?>(groupLabel),
      'roundIndex': serializer.toJson<int>(roundIndex),
      'itemIndex': serializer.toJson<int>(itemIndex),
      'plannedDurationSeconds': serializer.toJson<int?>(plannedDurationSeconds),
      'plannedDistanceMeters': serializer.toJson<double?>(
        plannedDistanceMeters,
      ),
      'plannedPaceSecPerKm': serializer.toJson<double?>(plannedPaceSecPerKm),
      'actualDurationSeconds': serializer.toJson<int?>(actualDurationSeconds),
      'actualDistanceMeters': serializer.toJson<double?>(actualDistanceMeters),
      'actualPaceSecPerKm': serializer.toJson<double?>(actualPaceSecPerKm),
      'inclinePercent': serializer.toJson<double?>(inclinePercent),
      'resistanceLevel': serializer.toJson<int?>(resistanceLevel),
      'avgHeartRate': serializer.toJson<int?>(avgHeartRate),
      'maxHeartRate': serializer.toJson<int?>(maxHeartRate),
      'calories': serializer.toJson<int?>(calories),
      'elevationGainMeters': serializer.toJson<double?>(elevationGainMeters),
      'status': serializer.toJson<String>(
        $CardioEntriesTable.$converterstatus.toJson(status),
      ),
      'performedAt': serializer.toJson<DateTime?>(performedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CardioEntryRow copyWith({
    int? id,
    int? sessionId,
    int? exerciseId,
    Value<int?> planItemId = const Value.absent(),
    int? groupIndex,
    BlockKind? groupKind,
    Value<String?> groupLabel = const Value.absent(),
    int? roundIndex,
    int? itemIndex,
    Value<int?> plannedDurationSeconds = const Value.absent(),
    Value<double?> plannedDistanceMeters = const Value.absent(),
    Value<double?> plannedPaceSecPerKm = const Value.absent(),
    Value<int?> actualDurationSeconds = const Value.absent(),
    Value<double?> actualDistanceMeters = const Value.absent(),
    Value<double?> actualPaceSecPerKm = const Value.absent(),
    Value<double?> inclinePercent = const Value.absent(),
    Value<int?> resistanceLevel = const Value.absent(),
    Value<int?> avgHeartRate = const Value.absent(),
    Value<int?> maxHeartRate = const Value.absent(),
    Value<int?> calories = const Value.absent(),
    Value<double?> elevationGainMeters = const Value.absent(),
    EntryStatus? status,
    Value<DateTime?> performedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CardioEntryRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    planItemId: planItemId.present ? planItemId.value : this.planItemId,
    groupIndex: groupIndex ?? this.groupIndex,
    groupKind: groupKind ?? this.groupKind,
    groupLabel: groupLabel.present ? groupLabel.value : this.groupLabel,
    roundIndex: roundIndex ?? this.roundIndex,
    itemIndex: itemIndex ?? this.itemIndex,
    plannedDurationSeconds: plannedDurationSeconds.present
        ? plannedDurationSeconds.value
        : this.plannedDurationSeconds,
    plannedDistanceMeters: plannedDistanceMeters.present
        ? plannedDistanceMeters.value
        : this.plannedDistanceMeters,
    plannedPaceSecPerKm: plannedPaceSecPerKm.present
        ? plannedPaceSecPerKm.value
        : this.plannedPaceSecPerKm,
    actualDurationSeconds: actualDurationSeconds.present
        ? actualDurationSeconds.value
        : this.actualDurationSeconds,
    actualDistanceMeters: actualDistanceMeters.present
        ? actualDistanceMeters.value
        : this.actualDistanceMeters,
    actualPaceSecPerKm: actualPaceSecPerKm.present
        ? actualPaceSecPerKm.value
        : this.actualPaceSecPerKm,
    inclinePercent: inclinePercent.present
        ? inclinePercent.value
        : this.inclinePercent,
    resistanceLevel: resistanceLevel.present
        ? resistanceLevel.value
        : this.resistanceLevel,
    avgHeartRate: avgHeartRate.present ? avgHeartRate.value : this.avgHeartRate,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    calories: calories.present ? calories.value : this.calories,
    elevationGainMeters: elevationGainMeters.present
        ? elevationGainMeters.value
        : this.elevationGainMeters,
    status: status ?? this.status,
    performedAt: performedAt.present ? performedAt.value : this.performedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  CardioEntryRow copyWithCompanion(CardioEntriesCompanion data) {
    return CardioEntryRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      planItemId: data.planItemId.present
          ? data.planItemId.value
          : this.planItemId,
      groupIndex: data.groupIndex.present
          ? data.groupIndex.value
          : this.groupIndex,
      groupKind: data.groupKind.present ? data.groupKind.value : this.groupKind,
      groupLabel: data.groupLabel.present
          ? data.groupLabel.value
          : this.groupLabel,
      roundIndex: data.roundIndex.present
          ? data.roundIndex.value
          : this.roundIndex,
      itemIndex: data.itemIndex.present ? data.itemIndex.value : this.itemIndex,
      plannedDurationSeconds: data.plannedDurationSeconds.present
          ? data.plannedDurationSeconds.value
          : this.plannedDurationSeconds,
      plannedDistanceMeters: data.plannedDistanceMeters.present
          ? data.plannedDistanceMeters.value
          : this.plannedDistanceMeters,
      plannedPaceSecPerKm: data.plannedPaceSecPerKm.present
          ? data.plannedPaceSecPerKm.value
          : this.plannedPaceSecPerKm,
      actualDurationSeconds: data.actualDurationSeconds.present
          ? data.actualDurationSeconds.value
          : this.actualDurationSeconds,
      actualDistanceMeters: data.actualDistanceMeters.present
          ? data.actualDistanceMeters.value
          : this.actualDistanceMeters,
      actualPaceSecPerKm: data.actualPaceSecPerKm.present
          ? data.actualPaceSecPerKm.value
          : this.actualPaceSecPerKm,
      inclinePercent: data.inclinePercent.present
          ? data.inclinePercent.value
          : this.inclinePercent,
      resistanceLevel: data.resistanceLevel.present
          ? data.resistanceLevel.value
          : this.resistanceLevel,
      avgHeartRate: data.avgHeartRate.present
          ? data.avgHeartRate.value
          : this.avgHeartRate,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      calories: data.calories.present ? data.calories.value : this.calories,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      status: data.status.present ? data.status.value : this.status,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioEntryRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planItemId: $planItemId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('groupKind: $groupKind, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('plannedDistanceMeters: $plannedDistanceMeters, ')
          ..write('plannedPaceSecPerKm: $plannedPaceSecPerKm, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualDistanceMeters: $actualDistanceMeters, ')
          ..write('actualPaceSecPerKm: $actualPaceSecPerKm, ')
          ..write('inclinePercent: $inclinePercent, ')
          ..write('resistanceLevel: $resistanceLevel, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('calories: $calories, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('status: $status, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    exerciseId,
    planItemId,
    groupIndex,
    groupKind,
    groupLabel,
    roundIndex,
    itemIndex,
    plannedDurationSeconds,
    plannedDistanceMeters,
    plannedPaceSecPerKm,
    actualDurationSeconds,
    actualDistanceMeters,
    actualPaceSecPerKm,
    inclinePercent,
    resistanceLevel,
    avgHeartRate,
    maxHeartRate,
    calories,
    elevationGainMeters,
    status,
    performedAt,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioEntryRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.planItemId == this.planItemId &&
          other.groupIndex == this.groupIndex &&
          other.groupKind == this.groupKind &&
          other.groupLabel == this.groupLabel &&
          other.roundIndex == this.roundIndex &&
          other.itemIndex == this.itemIndex &&
          other.plannedDurationSeconds == this.plannedDurationSeconds &&
          other.plannedDistanceMeters == this.plannedDistanceMeters &&
          other.plannedPaceSecPerKm == this.plannedPaceSecPerKm &&
          other.actualDurationSeconds == this.actualDurationSeconds &&
          other.actualDistanceMeters == this.actualDistanceMeters &&
          other.actualPaceSecPerKm == this.actualPaceSecPerKm &&
          other.inclinePercent == this.inclinePercent &&
          other.resistanceLevel == this.resistanceLevel &&
          other.avgHeartRate == this.avgHeartRate &&
          other.maxHeartRate == this.maxHeartRate &&
          other.calories == this.calories &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.status == this.status &&
          other.performedAt == this.performedAt &&
          other.notes == this.notes);
}

class CardioEntriesCompanion extends UpdateCompanion<CardioEntryRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> exerciseId;
  final Value<int?> planItemId;
  final Value<int> groupIndex;
  final Value<BlockKind> groupKind;
  final Value<String?> groupLabel;
  final Value<int> roundIndex;
  final Value<int> itemIndex;
  final Value<int?> plannedDurationSeconds;
  final Value<double?> plannedDistanceMeters;
  final Value<double?> plannedPaceSecPerKm;
  final Value<int?> actualDurationSeconds;
  final Value<double?> actualDistanceMeters;
  final Value<double?> actualPaceSecPerKm;
  final Value<double?> inclinePercent;
  final Value<int?> resistanceLevel;
  final Value<int?> avgHeartRate;
  final Value<int?> maxHeartRate;
  final Value<int?> calories;
  final Value<double?> elevationGainMeters;
  final Value<EntryStatus> status;
  final Value<DateTime?> performedAt;
  final Value<String?> notes;
  const CardioEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.planItemId = const Value.absent(),
    this.groupIndex = const Value.absent(),
    this.groupKind = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.roundIndex = const Value.absent(),
    this.itemIndex = const Value.absent(),
    this.plannedDurationSeconds = const Value.absent(),
    this.plannedDistanceMeters = const Value.absent(),
    this.plannedPaceSecPerKm = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualDistanceMeters = const Value.absent(),
    this.actualPaceSecPerKm = const Value.absent(),
    this.inclinePercent = const Value.absent(),
    this.resistanceLevel = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.calories = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.status = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  CardioEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int exerciseId,
    this.planItemId = const Value.absent(),
    required int groupIndex,
    required BlockKind groupKind,
    this.groupLabel = const Value.absent(),
    required int roundIndex,
    required int itemIndex,
    this.plannedDurationSeconds = const Value.absent(),
    this.plannedDistanceMeters = const Value.absent(),
    this.plannedPaceSecPerKm = const Value.absent(),
    this.actualDurationSeconds = const Value.absent(),
    this.actualDistanceMeters = const Value.absent(),
    this.actualPaceSecPerKm = const Value.absent(),
    this.inclinePercent = const Value.absent(),
    this.resistanceLevel = const Value.absent(),
    this.avgHeartRate = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.calories = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    required EntryStatus status,
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       groupIndex = Value(groupIndex),
       groupKind = Value(groupKind),
       roundIndex = Value(roundIndex),
       itemIndex = Value(itemIndex),
       status = Value(status);
  static Insertable<CardioEntryRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? exerciseId,
    Expression<int>? planItemId,
    Expression<int>? groupIndex,
    Expression<String>? groupKind,
    Expression<String>? groupLabel,
    Expression<int>? roundIndex,
    Expression<int>? itemIndex,
    Expression<int>? plannedDurationSeconds,
    Expression<double>? plannedDistanceMeters,
    Expression<double>? plannedPaceSecPerKm,
    Expression<int>? actualDurationSeconds,
    Expression<double>? actualDistanceMeters,
    Expression<double>? actualPaceSecPerKm,
    Expression<double>? inclinePercent,
    Expression<int>? resistanceLevel,
    Expression<int>? avgHeartRate,
    Expression<int>? maxHeartRate,
    Expression<int>? calories,
    Expression<double>? elevationGainMeters,
    Expression<String>? status,
    Expression<DateTime>? performedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (planItemId != null) 'plan_item_id': planItemId,
      if (groupIndex != null) 'group_index': groupIndex,
      if (groupKind != null) 'group_kind': groupKind,
      if (groupLabel != null) 'group_label': groupLabel,
      if (roundIndex != null) 'round_index': roundIndex,
      if (itemIndex != null) 'item_index': itemIndex,
      if (plannedDurationSeconds != null)
        'planned_duration_seconds': plannedDurationSeconds,
      if (plannedDistanceMeters != null)
        'planned_distance_meters': plannedDistanceMeters,
      if (plannedPaceSecPerKm != null)
        'planned_pace_sec_per_km': plannedPaceSecPerKm,
      if (actualDurationSeconds != null)
        'actual_duration_seconds': actualDurationSeconds,
      if (actualDistanceMeters != null)
        'actual_distance_meters': actualDistanceMeters,
      if (actualPaceSecPerKm != null)
        'actual_pace_sec_per_km': actualPaceSecPerKm,
      if (inclinePercent != null) 'incline_percent': inclinePercent,
      if (resistanceLevel != null) 'resistance_level': resistanceLevel,
      if (avgHeartRate != null) 'avg_heart_rate': avgHeartRate,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (calories != null) 'calories': calories,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (status != null) 'status': status,
      if (performedAt != null) 'performed_at': performedAt,
      if (notes != null) 'notes': notes,
    });
  }

  CardioEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? exerciseId,
    Value<int?>? planItemId,
    Value<int>? groupIndex,
    Value<BlockKind>? groupKind,
    Value<String?>? groupLabel,
    Value<int>? roundIndex,
    Value<int>? itemIndex,
    Value<int?>? plannedDurationSeconds,
    Value<double?>? plannedDistanceMeters,
    Value<double?>? plannedPaceSecPerKm,
    Value<int?>? actualDurationSeconds,
    Value<double?>? actualDistanceMeters,
    Value<double?>? actualPaceSecPerKm,
    Value<double?>? inclinePercent,
    Value<int?>? resistanceLevel,
    Value<int?>? avgHeartRate,
    Value<int?>? maxHeartRate,
    Value<int?>? calories,
    Value<double?>? elevationGainMeters,
    Value<EntryStatus>? status,
    Value<DateTime?>? performedAt,
    Value<String?>? notes,
  }) {
    return CardioEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      planItemId: planItemId ?? this.planItemId,
      groupIndex: groupIndex ?? this.groupIndex,
      groupKind: groupKind ?? this.groupKind,
      groupLabel: groupLabel ?? this.groupLabel,
      roundIndex: roundIndex ?? this.roundIndex,
      itemIndex: itemIndex ?? this.itemIndex,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      plannedDistanceMeters:
          plannedDistanceMeters ?? this.plannedDistanceMeters,
      plannedPaceSecPerKm: plannedPaceSecPerKm ?? this.plannedPaceSecPerKm,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      actualDistanceMeters: actualDistanceMeters ?? this.actualDistanceMeters,
      actualPaceSecPerKm: actualPaceSecPerKm ?? this.actualPaceSecPerKm,
      inclinePercent: inclinePercent ?? this.inclinePercent,
      resistanceLevel: resistanceLevel ?? this.resistanceLevel,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      calories: calories ?? this.calories,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      status: status ?? this.status,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (planItemId.present) {
      map['plan_item_id'] = Variable<int>(planItemId.value);
    }
    if (groupIndex.present) {
      map['group_index'] = Variable<int>(groupIndex.value);
    }
    if (groupKind.present) {
      map['group_kind'] = Variable<String>(
        $CardioEntriesTable.$convertergroupKind.toSql(groupKind.value),
      );
    }
    if (groupLabel.present) {
      map['group_label'] = Variable<String>(groupLabel.value);
    }
    if (roundIndex.present) {
      map['round_index'] = Variable<int>(roundIndex.value);
    }
    if (itemIndex.present) {
      map['item_index'] = Variable<int>(itemIndex.value);
    }
    if (plannedDurationSeconds.present) {
      map['planned_duration_seconds'] = Variable<int>(
        plannedDurationSeconds.value,
      );
    }
    if (plannedDistanceMeters.present) {
      map['planned_distance_meters'] = Variable<double>(
        plannedDistanceMeters.value,
      );
    }
    if (plannedPaceSecPerKm.present) {
      map['planned_pace_sec_per_km'] = Variable<double>(
        plannedPaceSecPerKm.value,
      );
    }
    if (actualDurationSeconds.present) {
      map['actual_duration_seconds'] = Variable<int>(
        actualDurationSeconds.value,
      );
    }
    if (actualDistanceMeters.present) {
      map['actual_distance_meters'] = Variable<double>(
        actualDistanceMeters.value,
      );
    }
    if (actualPaceSecPerKm.present) {
      map['actual_pace_sec_per_km'] = Variable<double>(
        actualPaceSecPerKm.value,
      );
    }
    if (inclinePercent.present) {
      map['incline_percent'] = Variable<double>(inclinePercent.value);
    }
    if (resistanceLevel.present) {
      map['resistance_level'] = Variable<int>(resistanceLevel.value);
    }
    if (avgHeartRate.present) {
      map['avg_heart_rate'] = Variable<int>(avgHeartRate.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<int>(maxHeartRate.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CardioEntriesTable.$converterstatus.toSql(status.value),
      );
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('planItemId: $planItemId, ')
          ..write('groupIndex: $groupIndex, ')
          ..write('groupKind: $groupKind, ')
          ..write('groupLabel: $groupLabel, ')
          ..write('roundIndex: $roundIndex, ')
          ..write('itemIndex: $itemIndex, ')
          ..write('plannedDurationSeconds: $plannedDurationSeconds, ')
          ..write('plannedDistanceMeters: $plannedDistanceMeters, ')
          ..write('plannedPaceSecPerKm: $plannedPaceSecPerKm, ')
          ..write('actualDurationSeconds: $actualDurationSeconds, ')
          ..write('actualDistanceMeters: $actualDistanceMeters, ')
          ..write('actualPaceSecPerKm: $actualPaceSecPerKm, ')
          ..write('inclinePercent: $inclinePercent, ')
          ..write('resistanceLevel: $resistanceLevel, ')
          ..write('avgHeartRate: $avgHeartRate, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('calories: $calories, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('status: $status, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CardioSplitsTable extends CardioSplits
    with TableInfo<$CardioSplitsTable, CardioSplitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardioSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardioEntryIdMeta = const VerificationMeta(
    'cardioEntryId',
  );
  @override
  late final GeneratedColumn<int> cardioEntryId = GeneratedColumn<int>(
    'cardio_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cardio_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _splitIndexMeta = const VerificationMeta(
    'splitIndex',
  );
  @override
  late final GeneratedColumn<int> splitIndex = GeneratedColumn<int>(
    'split_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardioEntryId,
    splitIndex,
    durationSeconds,
    distanceMeters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cardio_splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardioSplitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cardio_entry_id')) {
      context.handle(
        _cardioEntryIdMeta,
        cardioEntryId.isAcceptableOrUnknown(
          data['cardio_entry_id']!,
          _cardioEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardioEntryIdMeta);
    }
    if (data.containsKey('split_index')) {
      context.handle(
        _splitIndexMeta,
        splitIndex.isAcceptableOrUnknown(data['split_index']!, _splitIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_splitIndexMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardioSplitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardioSplitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardioEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardio_entry_id'],
      )!,
      splitIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}split_index'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
    );
  }

  @override
  $CardioSplitsTable createAlias(String alias) {
    return $CardioSplitsTable(attachedDatabase, alias);
  }
}

class CardioSplitRow extends DataClass implements Insertable<CardioSplitRow> {
  final int id;
  final int cardioEntryId;
  final int splitIndex;
  final int durationSeconds;
  final double? distanceMeters;
  const CardioSplitRow({
    required this.id,
    required this.cardioEntryId,
    required this.splitIndex,
    required this.durationSeconds,
    this.distanceMeters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cardio_entry_id'] = Variable<int>(cardioEntryId);
    map['split_index'] = Variable<int>(splitIndex);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    return map;
  }

  CardioSplitsCompanion toCompanion(bool nullToAbsent) {
    return CardioSplitsCompanion(
      id: Value(id),
      cardioEntryId: Value(cardioEntryId),
      splitIndex: Value(splitIndex),
      durationSeconds: Value(durationSeconds),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
    );
  }

  factory CardioSplitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardioSplitRow(
      id: serializer.fromJson<int>(json['id']),
      cardioEntryId: serializer.fromJson<int>(json['cardioEntryId']),
      splitIndex: serializer.fromJson<int>(json['splitIndex']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardioEntryId': serializer.toJson<int>(cardioEntryId),
      'splitIndex': serializer.toJson<int>(splitIndex),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
    };
  }

  CardioSplitRow copyWith({
    int? id,
    int? cardioEntryId,
    int? splitIndex,
    int? durationSeconds,
    Value<double?> distanceMeters = const Value.absent(),
  }) => CardioSplitRow(
    id: id ?? this.id,
    cardioEntryId: cardioEntryId ?? this.cardioEntryId,
    splitIndex: splitIndex ?? this.splitIndex,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
  );
  CardioSplitRow copyWithCompanion(CardioSplitsCompanion data) {
    return CardioSplitRow(
      id: data.id.present ? data.id.value : this.id,
      cardioEntryId: data.cardioEntryId.present
          ? data.cardioEntryId.value
          : this.cardioEntryId,
      splitIndex: data.splitIndex.present
          ? data.splitIndex.value
          : this.splitIndex,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardioSplitRow(')
          ..write('id: $id, ')
          ..write('cardioEntryId: $cardioEntryId, ')
          ..write('splitIndex: $splitIndex, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardioEntryId,
    splitIndex,
    durationSeconds,
    distanceMeters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardioSplitRow &&
          other.id == this.id &&
          other.cardioEntryId == this.cardioEntryId &&
          other.splitIndex == this.splitIndex &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters);
}

class CardioSplitsCompanion extends UpdateCompanion<CardioSplitRow> {
  final Value<int> id;
  final Value<int> cardioEntryId;
  final Value<int> splitIndex;
  final Value<int> durationSeconds;
  final Value<double?> distanceMeters;
  const CardioSplitsCompanion({
    this.id = const Value.absent(),
    this.cardioEntryId = const Value.absent(),
    this.splitIndex = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
  });
  CardioSplitsCompanion.insert({
    this.id = const Value.absent(),
    required int cardioEntryId,
    required int splitIndex,
    required int durationSeconds,
    this.distanceMeters = const Value.absent(),
  }) : cardioEntryId = Value(cardioEntryId),
       splitIndex = Value(splitIndex),
       durationSeconds = Value(durationSeconds);
  static Insertable<CardioSplitRow> custom({
    Expression<int>? id,
    Expression<int>? cardioEntryId,
    Expression<int>? splitIndex,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardioEntryId != null) 'cardio_entry_id': cardioEntryId,
      if (splitIndex != null) 'split_index': splitIndex,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
    });
  }

  CardioSplitsCompanion copyWith({
    Value<int>? id,
    Value<int>? cardioEntryId,
    Value<int>? splitIndex,
    Value<int>? durationSeconds,
    Value<double?>? distanceMeters,
  }) {
    return CardioSplitsCompanion(
      id: id ?? this.id,
      cardioEntryId: cardioEntryId ?? this.cardioEntryId,
      splitIndex: splitIndex ?? this.splitIndex,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardioEntryId.present) {
      map['cardio_entry_id'] = Variable<int>(cardioEntryId.value);
    }
    if (splitIndex.present) {
      map['split_index'] = Variable<int>(splitIndex.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardioSplitsCompanion(')
          ..write('id: $id, ')
          ..write('cardioEntryId: $cardioEntryId, ')
          ..write('splitIndex: $splitIndex, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters')
          ..write(')'))
        .toString();
  }
}

class $ExerciseBaselinesTable extends ExerciseBaselines
    with TableInfo<$ExerciseBaselinesTable, ExerciseBaselineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseBaselinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceSetIdMeta = const VerificationMeta(
    'sourceSetId',
  );
  @override
  late final GeneratedColumn<int> sourceSetId = GeneratedColumn<int>(
    'source_set_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES strength_sets (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    exerciseId,
    reps,
    weightKg,
    achievedAt,
    sourceSetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_baselines';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseBaselineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('source_set_id')) {
      context.handle(
        _sourceSetIdMeta,
        sourceSetId.isAcceptableOrUnknown(
          data['source_set_id']!,
          _sourceSetIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {planId, exerciseId, reps},
  ];
  @override
  ExerciseBaselineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseBaselineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
      sourceSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_set_id'],
      ),
    );
  }

  @override
  $ExerciseBaselinesTable createAlias(String alias) {
    return $ExerciseBaselinesTable(attachedDatabase, alias);
  }
}

class ExerciseBaselineRow extends DataClass
    implements Insertable<ExerciseBaselineRow> {
  final int id;
  final int planId;
  final int exerciseId;
  final int reps;
  final double weightKg;
  final DateTime achievedAt;
  final int? sourceSetId;
  const ExerciseBaselineRow({
    required this.id,
    required this.planId,
    required this.exerciseId,
    required this.reps,
    required this.weightKg,
    required this.achievedAt,
    this.sourceSetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['reps'] = Variable<int>(reps);
    map['weight_kg'] = Variable<double>(weightKg);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    if (!nullToAbsent || sourceSetId != null) {
      map['source_set_id'] = Variable<int>(sourceSetId);
    }
    return map;
  }

  ExerciseBaselinesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseBaselinesCompanion(
      id: Value(id),
      planId: Value(planId),
      exerciseId: Value(exerciseId),
      reps: Value(reps),
      weightKg: Value(weightKg),
      achievedAt: Value(achievedAt),
      sourceSetId: sourceSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSetId),
    );
  }

  factory ExerciseBaselineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseBaselineRow(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      reps: serializer.fromJson<int>(json['reps']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      sourceSetId: serializer.fromJson<int?>(json['sourceSetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'reps': serializer.toJson<int>(reps),
      'weightKg': serializer.toJson<double>(weightKg),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'sourceSetId': serializer.toJson<int?>(sourceSetId),
    };
  }

  ExerciseBaselineRow copyWith({
    int? id,
    int? planId,
    int? exerciseId,
    int? reps,
    double? weightKg,
    DateTime? achievedAt,
    Value<int?> sourceSetId = const Value.absent(),
  }) => ExerciseBaselineRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    exerciseId: exerciseId ?? this.exerciseId,
    reps: reps ?? this.reps,
    weightKg: weightKg ?? this.weightKg,
    achievedAt: achievedAt ?? this.achievedAt,
    sourceSetId: sourceSetId.present ? sourceSetId.value : this.sourceSetId,
  );
  ExerciseBaselineRow copyWithCompanion(ExerciseBaselinesCompanion data) {
    return ExerciseBaselineRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      reps: data.reps.present ? data.reps.value : this.reps,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      sourceSetId: data.sourceSetId.present
          ? data.sourceSetId.value
          : this.sourceSetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseBaselineRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sourceSetId: $sourceSetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    exerciseId,
    reps,
    weightKg,
    achievedAt,
    sourceSetId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseBaselineRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.exerciseId == this.exerciseId &&
          other.reps == this.reps &&
          other.weightKg == this.weightKg &&
          other.achievedAt == this.achievedAt &&
          other.sourceSetId == this.sourceSetId);
}

class ExerciseBaselinesCompanion extends UpdateCompanion<ExerciseBaselineRow> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> exerciseId;
  final Value<int> reps;
  final Value<double> weightKg;
  final Value<DateTime> achievedAt;
  final Value<int?> sourceSetId;
  const ExerciseBaselinesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.reps = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.sourceSetId = const Value.absent(),
  });
  ExerciseBaselinesCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int exerciseId,
    required int reps,
    required double weightKg,
    required DateTime achievedAt,
    this.sourceSetId = const Value.absent(),
  }) : planId = Value(planId),
       exerciseId = Value(exerciseId),
       reps = Value(reps),
       weightKg = Value(weightKg),
       achievedAt = Value(achievedAt);
  static Insertable<ExerciseBaselineRow> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? exerciseId,
    Expression<int>? reps,
    Expression<double>? weightKg,
    Expression<DateTime>? achievedAt,
    Expression<int>? sourceSetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (reps != null) 'reps': reps,
      if (weightKg != null) 'weight_kg': weightKg,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (sourceSetId != null) 'source_set_id': sourceSetId,
    });
  }

  ExerciseBaselinesCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<int>? exerciseId,
    Value<int>? reps,
    Value<double>? weightKg,
    Value<DateTime>? achievedAt,
    Value<int?>? sourceSetId,
  }) {
    return ExerciseBaselinesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      exerciseId: exerciseId ?? this.exerciseId,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      achievedAt: achievedAt ?? this.achievedAt,
      sourceSetId: sourceSetId ?? this.sourceSetId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (sourceSetId.present) {
      map['source_set_id'] = Variable<int>(sourceSetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseBaselinesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('reps: $reps, ')
          ..write('weightKg: $weightKg, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sourceSetId: $sourceSetId')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RecordType, String> recordType =
      GeneratedColumn<String>(
        'record_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RecordType>($PersonalRecordsTable.$converterrecordType);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    recordType,
    reps,
    value,
    achievedAt,
    sessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {exerciseId, recordType, reps},
  ];
  @override
  PersonalRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      recordType: $PersonalRecordsTable.$converterrecordType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}record_type'],
        )!,
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RecordType, String, String> $converterrecordType =
      const EnumNameConverter<RecordType>(RecordType.values);
}

class PersonalRecordRow extends DataClass
    implements Insertable<PersonalRecordRow> {
  final int id;
  final int exerciseId;
  final RecordType recordType;

  /// Rep count for rep-specific records. **Zero** means "not applicable"
  /// rather than null: SQLite treats NULLs as distinct in a unique index, so a
  /// nullable column here would silently permit duplicate records.
  final int reps;

  /// Interpreted according to [recordType] — kilograms, meters, seconds, or
  /// seconds per kilometer.
  final double value;
  final DateTime achievedAt;
  final int? sessionId;
  const PersonalRecordRow({
    required this.id,
    required this.exerciseId,
    required this.recordType,
    required this.reps,
    required this.value,
    required this.achievedAt,
    this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    {
      map['record_type'] = Variable<String>(
        $PersonalRecordsTable.$converterrecordType.toSql(recordType),
      );
    }
    map['reps'] = Variable<int>(reps);
    map['value'] = Variable<double>(value);
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      recordType: Value(recordType),
      reps: Value(reps),
      value: Value(value),
      achievedAt: Value(achievedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
    );
  }

  factory PersonalRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecordRow(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      recordType: $PersonalRecordsTable.$converterrecordType.fromJson(
        serializer.fromJson<String>(json['recordType']),
      ),
      reps: serializer.fromJson<int>(json['reps']),
      value: serializer.fromJson<double>(json['value']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'recordType': serializer.toJson<String>(
        $PersonalRecordsTable.$converterrecordType.toJson(recordType),
      ),
      'reps': serializer.toJson<int>(reps),
      'value': serializer.toJson<double>(value),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
      'sessionId': serializer.toJson<int?>(sessionId),
    };
  }

  PersonalRecordRow copyWith({
    int? id,
    int? exerciseId,
    RecordType? recordType,
    int? reps,
    double? value,
    DateTime? achievedAt,
    Value<int?> sessionId = const Value.absent(),
  }) => PersonalRecordRow(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    recordType: recordType ?? this.recordType,
    reps: reps ?? this.reps,
    value: value ?? this.value,
    achievedAt: achievedAt ?? this.achievedAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
  );
  PersonalRecordRow copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecordRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      reps: data.reps.present ? data.reps.value : this.reps,
      value: data.value.present ? data.value.value : this.value,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('recordType: $recordType, ')
          ..write('reps: $reps, ')
          ..write('value: $value, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    recordType,
    reps,
    value,
    achievedAt,
    sessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecordRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.recordType == this.recordType &&
          other.reps == this.reps &&
          other.value == this.value &&
          other.achievedAt == this.achievedAt &&
          other.sessionId == this.sessionId);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecordRow> {
  final Value<int> id;
  final Value<int> exerciseId;
  final Value<RecordType> recordType;
  final Value<int> reps;
  final Value<double> value;
  final Value<DateTime> achievedAt;
  final Value<int?> sessionId;
  const PersonalRecordsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.reps = const Value.absent(),
    this.value = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int exerciseId,
    required RecordType recordType,
    this.reps = const Value.absent(),
    required double value,
    required DateTime achievedAt,
    this.sessionId = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       recordType = Value(recordType),
       value = Value(value),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecordRow> custom({
    Expression<int>? id,
    Expression<int>? exerciseId,
    Expression<String>? recordType,
    Expression<int>? reps,
    Expression<double>? value,
    Expression<DateTime>? achievedAt,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (recordType != null) 'record_type': recordType,
      if (reps != null) 'reps': reps,
      if (value != null) 'value': value,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? exerciseId,
    Value<RecordType>? recordType,
    Value<int>? reps,
    Value<double>? value,
    Value<DateTime>? achievedAt,
    Value<int?>? sessionId,
  }) {
    return PersonalRecordsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      recordType: recordType ?? this.recordType,
      reps: reps ?? this.reps,
      value: value ?? this.value,
      achievedAt: achievedAt ?? this.achievedAt,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(
        $PersonalRecordsTable.$converterrecordType.toSql(recordType.value),
      );
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('recordType: $recordType, ')
          ..write('reps: $reps, ')
          ..write('value: $value, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
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
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
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
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PlanDaysTable planDays = $PlanDaysTable(this);
  late final $PlanBlocksTable planBlocks = $PlanBlocksTable(this);
  late final $PlanItemsTable planItems = $PlanItemsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $StrengthSetsTable strengthSets = $StrengthSetsTable(this);
  late final $CardioEntriesTable cardioEntries = $CardioEntriesTable(this);
  late final $CardioSplitsTable cardioSplits = $CardioSplitsTable(this);
  late final $ExerciseBaselinesTable exerciseBaselines =
      $ExerciseBaselinesTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    plans,
    planDays,
    planBlocks,
    planItems,
    sessions,
    strengthSets,
    cardioEntries,
    cardioSplits,
    exerciseBaselines,
    personalRecords,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_blocks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_blocks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strength_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strength_sets', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cardio_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plan_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cardio_entries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cardio_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cardio_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_baselines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_baselines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'strength_sets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_baselines', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('personal_records', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('personal_records', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      required String nameKey,
      required ExerciseType type,
      Value<CardioActivity?> cardioActivity,
      Value<String?> muscleGroup,
      Value<String?> equipment,
      Value<String?> notes,
      Value<bool> isCustom,
      Value<bool> isArchived,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> nameKey,
      Value<ExerciseType> type,
      Value<CardioActivity?> cardioActivity,
      Value<String?> muscleGroup,
      Value<String?> equipment,
      Value<String?> notes,
      Value<bool> isCustom,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItemRow>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: $_aliasNameGenerator(db.exercises.id, db.planItems.exerciseId),
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StrengthSetsTable, List<StrengthSetRow>>
  _strengthSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.strengthSets,
    aliasName: $_aliasNameGenerator(
      db.exercises.id,
      db.strengthSets.exerciseId,
    ),
  );

  $$StrengthSetsTableProcessedTableManager get strengthSetsRefs {
    final manager = $$StrengthSetsTableTableManager(
      $_db,
      $_db.strengthSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_strengthSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardioEntriesTable, List<CardioEntryRow>>
  _cardioEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardioEntries,
    aliasName: $_aliasNameGenerator(
      db.exercises.id,
      db.cardioEntries.exerciseId,
    ),
  );

  $$CardioEntriesTableProcessedTableManager get cardioEntriesRefs {
    final manager = $$CardioEntriesTableTableManager(
      $_db,
      $_db.cardioEntries,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardioEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseBaselinesTable, List<ExerciseBaselineRow>>
  _exerciseBaselinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseBaselines,
        aliasName: $_aliasNameGenerator(
          db.exercises.id,
          db.exerciseBaselines.exerciseId,
        ),
      );

  $$ExerciseBaselinesTableProcessedTableManager get exerciseBaselinesRefs {
    final manager = $$ExerciseBaselinesTableTableManager(
      $_db,
      $_db.exerciseBaselines,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseBaselinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecordRow>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(
      db.exercises.id,
      db.personalRecords.exerciseId,
    ),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseType, ExerciseType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CardioActivity?, CardioActivity, String>
  get cardioActivity => $composableBuilder(
    column: $table.cardioActivity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> strengthSetsRefs(
    Expression<bool> Function($$StrengthSetsTableFilterComposer f) f,
  ) {
    final $$StrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardioEntriesRefs(
    Expression<bool> Function($$CardioEntriesTableFilterComposer f) f,
  ) {
    final $$CardioEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseBaselinesRefs(
    Expression<bool> Function($$ExerciseBaselinesTableFilterComposer f) f,
  ) {
    final $$ExerciseBaselinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseBaselines,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseBaselinesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseBaselines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardioActivity => $composableBuilder(
    column: $table.cardioActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardioActivity?, String>
  get cardioActivity => $composableBuilder(
    column: $table.cardioActivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> strengthSetsRefs<T extends Object>(
    Expression<T> Function($$StrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$StrengthSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardioEntriesRefs<T extends Object>(
    Expression<T> Function($$CardioEntriesTableAnnotationComposer a) f,
  ) {
    final $$CardioEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseBaselinesRefs<T extends Object>(
    Expression<T> Function($$ExerciseBaselinesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseBaselinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseBaselines,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseBaselinesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseBaselines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (ExerciseRow, $$ExercisesTableReferences),
          ExerciseRow,
          PrefetchHooks Function({
            bool planItemsRefs,
            bool strengthSetsRefs,
            bool cardioEntriesRefs,
            bool exerciseBaselinesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<ExerciseType> type = const Value.absent(),
                Value<CardioActivity?> cardioActivity = const Value.absent(),
                Value<String?> muscleGroup = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                type: type,
                cardioActivity: cardioActivity,
                muscleGroup: muscleGroup,
                equipment: equipment,
                notes: notes,
                isCustom: isCustom,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameKey,
                required ExerciseType type,
                Value<CardioActivity?> cardioActivity = const Value.absent(),
                Value<String?> muscleGroup = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                type: type,
                cardioActivity: cardioActivity,
                muscleGroup: muscleGroup,
                equipment: equipment,
                notes: notes,
                isCustom: isCustom,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planItemsRefs = false,
                strengthSetsRefs = false,
                cardioEntriesRefs = false,
                exerciseBaselinesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planItemsRefs) db.planItems,
                    if (strengthSetsRefs) db.strengthSets,
                    if (cardioEntriesRefs) db.cardioEntries,
                    if (exerciseBaselinesRefs) db.exerciseBaselines,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planItemsRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          PlanItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._planItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).planItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (strengthSetsRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          StrengthSetRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._strengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).strengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardioEntriesRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          CardioEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._cardioEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).cardioEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseBaselinesRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          ExerciseBaselineRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseBaselinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseBaselinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          PersonalRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (ExerciseRow, $$ExercisesTableReferences),
      ExerciseRow,
      PrefetchHooks Function({
        bool planItemsRefs,
        bool strengthSetsRefs,
        bool cardioEntriesRefs,
        bool exerciseBaselinesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      required PlanMode mode,
      required ScheduleType scheduleType,
      Value<DateTime?> startDate,
      Value<int?> durationWeeks,
      Value<bool> isActive,
      required PlanSource source,
      Value<String?> schemaVersion,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<PlanMode> mode,
      Value<ScheduleType> scheduleType,
      Value<DateTime?> startDate,
      Value<int?> durationWeeks,
      Value<bool> isActive,
      Value<PlanSource> source,
      Value<String?> schemaVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, PlanRow> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlanDaysTable, List<PlanDayRow>>
  _planDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planDays,
    aliasName: $_aliasNameGenerator(db.plans.id, db.planDays.planId),
  );

  $$PlanDaysTableProcessedTableManager get planDaysRefs {
    final manager = $$PlanDaysTableTableManager(
      $_db,
      $_db.planDays,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.plans.id, db.sessions.planId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseBaselinesTable, List<ExerciseBaselineRow>>
  _exerciseBaselinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseBaselines,
        aliasName: $_aliasNameGenerator(
          db.plans.id,
          db.exerciseBaselines.planId,
        ),
      );

  $$ExerciseBaselinesTableProcessedTableManager get exerciseBaselinesRefs {
    final manager = $$ExerciseBaselinesTableTableManager(
      $_db,
      $_db.exerciseBaselines,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseBaselinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlanMode, PlanMode, String> get mode =>
      $composableBuilder(
        column: $table.mode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ScheduleType, ScheduleType, String>
  get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlanSource, PlanSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> planDaysRefs(
    Expression<bool> Function($$PlanDaysTableFilterComposer f) f,
  ) {
    final $$PlanDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableFilterComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseBaselinesRefs(
    Expression<bool> Function($$ExerciseBaselinesTableFilterComposer f) f,
  ) {
    final $$ExerciseBaselinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseBaselines,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseBaselinesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseBaselines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PlanMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ScheduleType, String> get scheduleType =>
      $composableBuilder(
        column: $table.scheduleType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get durationWeeks => $composableBuilder(
    column: $table.durationWeeks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> planDaysRefs<T extends Object>(
    Expression<T> Function($$PlanDaysTableAnnotationComposer a) f,
  ) {
    final $$PlanDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseBaselinesRefs<T extends Object>(
    Expression<T> Function($$ExerciseBaselinesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseBaselinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseBaselines,
          getReferencedColumn: (t) => t.planId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseBaselinesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseBaselines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, $$PlansTableReferences),
          PlanRow,
          PrefetchHooks Function({
            bool planDaysRefs,
            bool sessionsRefs,
            bool exerciseBaselinesRefs,
          })
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<PlanMode> mode = const Value.absent(),
                Value<ScheduleType> scheduleType = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<PlanSource> source = const Value.absent(),
                Value<String?> schemaVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                name: name,
                description: description,
                mode: mode,
                scheduleType: scheduleType,
                startDate: startDate,
                durationWeeks: durationWeeks,
                isActive: isActive,
                source: source,
                schemaVersion: schemaVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                required PlanMode mode,
                required ScheduleType scheduleType,
                Value<DateTime?> startDate = const Value.absent(),
                Value<int?> durationWeeks = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required PlanSource source,
                Value<String?> schemaVersion = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PlansCompanion.insert(
                id: id,
                name: name,
                description: description,
                mode: mode,
                scheduleType: scheduleType,
                startDate: startDate,
                durationWeeks: durationWeeks,
                isActive: isActive,
                source: source,
                schemaVersion: schemaVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planDaysRefs = false,
                sessionsRefs = false,
                exerciseBaselinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planDaysRefs) db.planDays,
                    if (sessionsRefs) db.sessions,
                    if (exerciseBaselinesRefs) db.exerciseBaselines,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planDaysRefs)
                        await $_getPrefetchedData<
                          PlanRow,
                          $PlansTable,
                          PlanDayRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._planDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).planDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          PlanRow,
                          $PlansTable,
                          SessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseBaselinesRefs)
                        await $_getPrefetchedData<
                          PlanRow,
                          $PlansTable,
                          ExerciseBaselineRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlansTableReferences
                              ._exerciseBaselinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlansTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseBaselinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, $$PlansTableReferences),
      PlanRow,
      PrefetchHooks Function({
        bool planDaysRefs,
        bool sessionsRefs,
        bool exerciseBaselinesRefs,
      })
    >;
typedef $$PlanDaysTableCreateCompanionBuilder =
    PlanDaysCompanion Function({
      Value<int> id,
      required int planId,
      required int orderIndex,
      required String label,
      Value<int?> weekNumber,
      Value<Weekday?> dayOfWeek,
      Value<String?> notes,
    });
typedef $$PlanDaysTableUpdateCompanionBuilder =
    PlanDaysCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int> orderIndex,
      Value<String> label,
      Value<int?> weekNumber,
      Value<Weekday?> dayOfWeek,
      Value<String?> notes,
    });

final class $$PlanDaysTableReferences
    extends BaseReferences<_$AppDatabase, $PlanDaysTable, PlanDayRow> {
  $$PlanDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans.createAlias(
    $_aliasNameGenerator(db.planDays.planId, db.plans.id),
  );

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanBlocksTable, List<PlanBlockRow>>
  _planBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planBlocks,
    aliasName: $_aliasNameGenerator(db.planDays.id, db.planBlocks.planDayId),
  );

  $$PlanBlocksTableProcessedTableManager get planBlocksRefs {
    final manager = $$PlanBlocksTableTableManager(
      $_db,
      $_db.planBlocks,
    ).filter((f) => f.planDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.planDays.id, db.sessions.planDayId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.planDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanDaysTableFilterComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weekday?, Weekday, String> get dayOfWeek =>
      $composableBuilder(
        column: $table.dayOfWeek,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planBlocksRefs(
    Expression<bool> Function($$PlanBlocksTableFilterComposer f) f,
  ) {
    final $$PlanBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planBlocks,
      getReferencedColumn: (t) => t.planDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanBlocksTableFilterComposer(
            $db: $db,
            $table: $db.planBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get weekNumber => $composableBuilder(
    column: $table.weekNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Weekday?, String> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planBlocksRefs<T extends Object>(
    Expression<T> Function($$PlanBlocksTableAnnotationComposer a) f,
  ) {
    final $$PlanBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planBlocks,
      getReferencedColumn: (t) => t.planDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.planBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanDaysTable,
          PlanDayRow,
          $$PlanDaysTableFilterComposer,
          $$PlanDaysTableOrderingComposer,
          $$PlanDaysTableAnnotationComposer,
          $$PlanDaysTableCreateCompanionBuilder,
          $$PlanDaysTableUpdateCompanionBuilder,
          (PlanDayRow, $$PlanDaysTableReferences),
          PlanDayRow,
          PrefetchHooks Function({
            bool planId,
            bool planBlocksRefs,
            bool sessionsRefs,
          })
        > {
  $$PlanDaysTableTableManager(_$AppDatabase db, $PlanDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int?> weekNumber = const Value.absent(),
                Value<Weekday?> dayOfWeek = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PlanDaysCompanion(
                id: id,
                planId: planId,
                orderIndex: orderIndex,
                label: label,
                weekNumber: weekNumber,
                dayOfWeek: dayOfWeek,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required int orderIndex,
                required String label,
                Value<int?> weekNumber = const Value.absent(),
                Value<Weekday?> dayOfWeek = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PlanDaysCompanion.insert(
                id: id,
                planId: planId,
                orderIndex: orderIndex,
                label: label,
                weekNumber: weekNumber,
                dayOfWeek: dayOfWeek,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlanDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({planId = false, planBlocksRefs = false, sessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planBlocksRefs) db.planBlocks,
                    if (sessionsRefs) db.sessions,
                  ],
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
                        if (planId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planId,
                                    referencedTable: $$PlanDaysTableReferences
                                        ._planIdTable(db),
                                    referencedColumn: $$PlanDaysTableReferences
                                        ._planIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planBlocksRefs)
                        await $_getPrefetchedData<
                          PlanDayRow,
                          $PlanDaysTable,
                          PlanBlockRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlanDaysTableReferences
                              ._planBlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).planBlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          PlanDayRow,
                          $PlanDaysTable,
                          SessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlanDaysTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanDaysTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planDayId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlanDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanDaysTable,
      PlanDayRow,
      $$PlanDaysTableFilterComposer,
      $$PlanDaysTableOrderingComposer,
      $$PlanDaysTableAnnotationComposer,
      $$PlanDaysTableCreateCompanionBuilder,
      $$PlanDaysTableUpdateCompanionBuilder,
      (PlanDayRow, $$PlanDaysTableReferences),
      PlanDayRow,
      PrefetchHooks Function({
        bool planId,
        bool planBlocksRefs,
        bool sessionsRefs,
      })
    >;
typedef $$PlanBlocksTableCreateCompanionBuilder =
    PlanBlocksCompanion Function({
      Value<int> id,
      required int planDayId,
      required int orderIndex,
      required BlockKind kind,
      Value<String?> label,
      Value<int> rounds,
      Value<int> restBetweenExercisesSeconds,
      Value<int> restAfterRoundSeconds,
    });
typedef $$PlanBlocksTableUpdateCompanionBuilder =
    PlanBlocksCompanion Function({
      Value<int> id,
      Value<int> planDayId,
      Value<int> orderIndex,
      Value<BlockKind> kind,
      Value<String?> label,
      Value<int> rounds,
      Value<int> restBetweenExercisesSeconds,
      Value<int> restAfterRoundSeconds,
    });

final class $$PlanBlocksTableReferences
    extends BaseReferences<_$AppDatabase, $PlanBlocksTable, PlanBlockRow> {
  $$PlanBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlanDaysTable _planDayIdTable(_$AppDatabase db) =>
      db.planDays.createAlias(
        $_aliasNameGenerator(db.planBlocks.planDayId, db.planDays.id),
      );

  $$PlanDaysTableProcessedTableManager get planDayId {
    final $_column = $_itemColumn<int>('plan_day_id')!;

    final manager = $$PlanDaysTableTableManager(
      $_db,
      $_db.planDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItemRow>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: $_aliasNameGenerator(db.planBlocks.id, db.planItems.planBlockId),
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.planBlockId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $PlanBlocksTable> {
  $$PlanBlocksTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BlockKind, BlockKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restBetweenExercisesSeconds => $composableBuilder(
    column: $table.restBetweenExercisesSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restAfterRoundSeconds => $composableBuilder(
    column: $table.restAfterRoundSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanDaysTableFilterComposer get planDayId {
    final $$PlanDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableFilterComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanBlocksTable> {
  $$PlanBlocksTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rounds => $composableBuilder(
    column: $table.rounds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restBetweenExercisesSeconds => $composableBuilder(
    column: $table.restBetweenExercisesSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restAfterRoundSeconds => $composableBuilder(
    column: $table.restAfterRoundSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanDaysTableOrderingComposer get planDayId {
    final $$PlanDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableOrderingComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanBlocksTable> {
  $$PlanBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BlockKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get rounds =>
      $composableBuilder(column: $table.rounds, builder: (column) => column);

  GeneratedColumn<int> get restBetweenExercisesSeconds => $composableBuilder(
    column: $table.restBetweenExercisesSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restAfterRoundSeconds => $composableBuilder(
    column: $table.restAfterRoundSeconds,
    builder: (column) => column,
  );

  $$PlanDaysTableAnnotationComposer get planDayId {
    final $$PlanDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planBlockId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanBlocksTable,
          PlanBlockRow,
          $$PlanBlocksTableFilterComposer,
          $$PlanBlocksTableOrderingComposer,
          $$PlanBlocksTableAnnotationComposer,
          $$PlanBlocksTableCreateCompanionBuilder,
          $$PlanBlocksTableUpdateCompanionBuilder,
          (PlanBlockRow, $$PlanBlocksTableReferences),
          PlanBlockRow,
          PrefetchHooks Function({bool planDayId, bool planItemsRefs})
        > {
  $$PlanBlocksTableTableManager(_$AppDatabase db, $PlanBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planDayId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<BlockKind> kind = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> restBetweenExercisesSeconds = const Value.absent(),
                Value<int> restAfterRoundSeconds = const Value.absent(),
              }) => PlanBlocksCompanion(
                id: id,
                planDayId: planDayId,
                orderIndex: orderIndex,
                kind: kind,
                label: label,
                rounds: rounds,
                restBetweenExercisesSeconds: restBetweenExercisesSeconds,
                restAfterRoundSeconds: restAfterRoundSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planDayId,
                required int orderIndex,
                required BlockKind kind,
                Value<String?> label = const Value.absent(),
                Value<int> rounds = const Value.absent(),
                Value<int> restBetweenExercisesSeconds = const Value.absent(),
                Value<int> restAfterRoundSeconds = const Value.absent(),
              }) => PlanBlocksCompanion.insert(
                id: id,
                planDayId: planDayId,
                orderIndex: orderIndex,
                kind: kind,
                label: label,
                rounds: rounds,
                restBetweenExercisesSeconds: restBetweenExercisesSeconds,
                restAfterRoundSeconds: restAfterRoundSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlanBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planDayId = false, planItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (planItemsRefs) db.planItems],
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
                    if (planDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planDayId,
                                referencedTable: $$PlanBlocksTableReferences
                                    ._planDayIdTable(db),
                                referencedColumn: $$PlanBlocksTableReferences
                                    ._planDayIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planItemsRefs)
                    await $_getPrefetchedData<
                      PlanBlockRow,
                      $PlanBlocksTable,
                      PlanItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlanBlocksTableReferences
                          ._planItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlanBlocksTableReferences(
                            db,
                            table,
                            p0,
                          ).planItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.planBlockId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlanBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanBlocksTable,
      PlanBlockRow,
      $$PlanBlocksTableFilterComposer,
      $$PlanBlocksTableOrderingComposer,
      $$PlanBlocksTableAnnotationComposer,
      $$PlanBlocksTableCreateCompanionBuilder,
      $$PlanBlocksTableUpdateCompanionBuilder,
      (PlanBlockRow, $$PlanBlocksTableReferences),
      PlanBlockRow,
      PrefetchHooks Function({bool planDayId, bool planItemsRefs})
    >;
typedef $$PlanItemsTableCreateCompanionBuilder =
    PlanItemsCompanion Function({
      Value<int> id,
      required int planBlockId,
      required int exerciseId,
      required int orderIndex,
      Value<int?> targetReps,
      Value<double?> targetWeightKg,
      Value<WeightMode?> weightMode,
      Value<double?> weightOffsetKg,
      Value<double?> weightPercent,
      Value<double?> rpe,
      Value<String?> tempo,
      Value<bool> toFailure,
      Value<int?> targetDurationSeconds,
      Value<double?> targetDistanceMeters,
      Value<double?> targetPaceSecPerKm,
      Value<double?> targetInclinePercent,
      Value<int?> targetResistanceLevel,
      Value<String?> intervalsJson,
      Value<String?> notes,
    });
typedef $$PlanItemsTableUpdateCompanionBuilder =
    PlanItemsCompanion Function({
      Value<int> id,
      Value<int> planBlockId,
      Value<int> exerciseId,
      Value<int> orderIndex,
      Value<int?> targetReps,
      Value<double?> targetWeightKg,
      Value<WeightMode?> weightMode,
      Value<double?> weightOffsetKg,
      Value<double?> weightPercent,
      Value<double?> rpe,
      Value<String?> tempo,
      Value<bool> toFailure,
      Value<int?> targetDurationSeconds,
      Value<double?> targetDistanceMeters,
      Value<double?> targetPaceSecPerKm,
      Value<double?> targetInclinePercent,
      Value<int?> targetResistanceLevel,
      Value<String?> intervalsJson,
      Value<String?> notes,
    });

final class $$PlanItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItemRow> {
  $$PlanItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlanBlocksTable _planBlockIdTable(_$AppDatabase db) =>
      db.planBlocks.createAlias(
        $_aliasNameGenerator(db.planItems.planBlockId, db.planBlocks.id),
      );

  $$PlanBlocksTableProcessedTableManager get planBlockId {
    final $_column = $_itemColumn<int>('plan_block_id')!;

    final manager = $$PlanBlocksTableTableManager(
      $_db,
      $_db.planBlocks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planBlockIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.planItems.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StrengthSetsTable, List<StrengthSetRow>>
  _strengthSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.strengthSets,
    aliasName: $_aliasNameGenerator(
      db.planItems.id,
      db.strengthSets.planItemId,
    ),
  );

  $$StrengthSetsTableProcessedTableManager get strengthSetsRefs {
    final manager = $$StrengthSetsTableTableManager(
      $_db,
      $_db.strengthSets,
    ).filter((f) => f.planItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_strengthSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardioEntriesTable, List<CardioEntryRow>>
  _cardioEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardioEntries,
    aliasName: $_aliasNameGenerator(
      db.planItems.id,
      db.cardioEntries.planItemId,
    ),
  );

  $$CardioEntriesTableProcessedTableManager get cardioEntriesRefs {
    final manager = $$CardioEntriesTableTableManager(
      $_db,
      $_db.cardioEntries,
    ).filter((f) => f.planItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardioEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightMode?, WeightMode, String>
  get weightMode => $composableBuilder(
    column: $table.weightMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get weightOffsetKg => $composableBuilder(
    column: $table.weightOffsetKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get toFailure => $composableBuilder(
    column: $table.toFailure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetInclinePercent => $composableBuilder(
    column: $table.targetInclinePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetResistanceLevel => $composableBuilder(
    column: $table.targetResistanceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanBlocksTableFilterComposer get planBlockId {
    final $$PlanBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planBlockId,
      referencedTable: $db.planBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanBlocksTableFilterComposer(
            $db: $db,
            $table: $db.planBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strengthSetsRefs(
    Expression<bool> Function($$StrengthSetsTableFilterComposer f) f,
  ) {
    final $$StrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.planItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardioEntriesRefs(
    Expression<bool> Function($$CardioEntriesTableFilterComposer f) f,
  ) {
    final $$CardioEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.planItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightMode => $composableBuilder(
    column: $table.weightMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightOffsetKg => $composableBuilder(
    column: $table.weightOffsetKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get toFailure => $composableBuilder(
    column: $table.toFailure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetInclinePercent => $composableBuilder(
    column: $table.targetInclinePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetResistanceLevel => $composableBuilder(
    column: $table.targetResistanceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanBlocksTableOrderingComposer get planBlockId {
    final $$PlanBlocksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planBlockId,
      referencedTable: $db.planBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanBlocksTableOrderingComposer(
            $db: $db,
            $table: $db.planBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WeightMode?, String> get weightMode =>
      $composableBuilder(
        column: $table.weightMode,
        builder: (column) => column,
      );

  GeneratedColumn<double> get weightOffsetKg => $composableBuilder(
    column: $table.weightOffsetKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<bool> get toFailure =>
      $composableBuilder(column: $table.toFailure, builder: (column) => column);

  GeneratedColumn<int> get targetDurationSeconds => $composableBuilder(
    column: $table.targetDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistanceMeters => $composableBuilder(
    column: $table.targetDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetPaceSecPerKm => $composableBuilder(
    column: $table.targetPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetInclinePercent => $composableBuilder(
    column: $table.targetInclinePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetResistanceLevel => $composableBuilder(
    column: $table.targetResistanceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalsJson => $composableBuilder(
    column: $table.intervalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PlanBlocksTableAnnotationComposer get planBlockId {
    final $$PlanBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planBlockId,
      referencedTable: $db.planBlocks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.planBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strengthSetsRefs<T extends Object>(
    Expression<T> Function($$StrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$StrengthSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.planItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardioEntriesRefs<T extends Object>(
    Expression<T> Function($$CardioEntriesTableAnnotationComposer a) f,
  ) {
    final $$CardioEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.planItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanItemsTable,
          PlanItemRow,
          $$PlanItemsTableFilterComposer,
          $$PlanItemsTableOrderingComposer,
          $$PlanItemsTableAnnotationComposer,
          $$PlanItemsTableCreateCompanionBuilder,
          $$PlanItemsTableUpdateCompanionBuilder,
          (PlanItemRow, $$PlanItemsTableReferences),
          PlanItemRow,
          PrefetchHooks Function({
            bool planBlockId,
            bool exerciseId,
            bool strengthSetsRefs,
            bool cardioEntriesRefs,
          })
        > {
  $$PlanItemsTableTableManager(_$AppDatabase db, $PlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planBlockId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<WeightMode?> weightMode = const Value.absent(),
                Value<double?> weightOffsetKg = const Value.absent(),
                Value<double?> weightPercent = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<bool> toFailure = const Value.absent(),
                Value<int?> targetDurationSeconds = const Value.absent(),
                Value<double?> targetDistanceMeters = const Value.absent(),
                Value<double?> targetPaceSecPerKm = const Value.absent(),
                Value<double?> targetInclinePercent = const Value.absent(),
                Value<int?> targetResistanceLevel = const Value.absent(),
                Value<String?> intervalsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PlanItemsCompanion(
                id: id,
                planBlockId: planBlockId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetReps: targetReps,
                targetWeightKg: targetWeightKg,
                weightMode: weightMode,
                weightOffsetKg: weightOffsetKg,
                weightPercent: weightPercent,
                rpe: rpe,
                tempo: tempo,
                toFailure: toFailure,
                targetDurationSeconds: targetDurationSeconds,
                targetDistanceMeters: targetDistanceMeters,
                targetPaceSecPerKm: targetPaceSecPerKm,
                targetInclinePercent: targetInclinePercent,
                targetResistanceLevel: targetResistanceLevel,
                intervalsJson: intervalsJson,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planBlockId,
                required int exerciseId,
                required int orderIndex,
                Value<int?> targetReps = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<WeightMode?> weightMode = const Value.absent(),
                Value<double?> weightOffsetKg = const Value.absent(),
                Value<double?> weightPercent = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<bool> toFailure = const Value.absent(),
                Value<int?> targetDurationSeconds = const Value.absent(),
                Value<double?> targetDistanceMeters = const Value.absent(),
                Value<double?> targetPaceSecPerKm = const Value.absent(),
                Value<double?> targetInclinePercent = const Value.absent(),
                Value<int?> targetResistanceLevel = const Value.absent(),
                Value<String?> intervalsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PlanItemsCompanion.insert(
                id: id,
                planBlockId: planBlockId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetReps: targetReps,
                targetWeightKg: targetWeightKg,
                weightMode: weightMode,
                weightOffsetKg: weightOffsetKg,
                weightPercent: weightPercent,
                rpe: rpe,
                tempo: tempo,
                toFailure: toFailure,
                targetDurationSeconds: targetDurationSeconds,
                targetDistanceMeters: targetDistanceMeters,
                targetPaceSecPerKm: targetPaceSecPerKm,
                targetInclinePercent: targetInclinePercent,
                targetResistanceLevel: targetResistanceLevel,
                intervalsJson: intervalsJson,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlanItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planBlockId = false,
                exerciseId = false,
                strengthSetsRefs = false,
                cardioEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strengthSetsRefs) db.strengthSets,
                    if (cardioEntriesRefs) db.cardioEntries,
                  ],
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
                        if (planBlockId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planBlockId,
                                    referencedTable: $$PlanItemsTableReferences
                                        ._planBlockIdTable(db),
                                    referencedColumn: $$PlanItemsTableReferences
                                        ._planBlockIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable: $$PlanItemsTableReferences
                                        ._exerciseIdTable(db),
                                    referencedColumn: $$PlanItemsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strengthSetsRefs)
                        await $_getPrefetchedData<
                          PlanItemRow,
                          $PlanItemsTable,
                          StrengthSetRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlanItemsTableReferences
                              ._strengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).strengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardioEntriesRefs)
                        await $_getPrefetchedData<
                          PlanItemRow,
                          $PlanItemsTable,
                          CardioEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$PlanItemsTableReferences
                              ._cardioEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardioEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.planItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanItemsTable,
      PlanItemRow,
      $$PlanItemsTableFilterComposer,
      $$PlanItemsTableOrderingComposer,
      $$PlanItemsTableAnnotationComposer,
      $$PlanItemsTableCreateCompanionBuilder,
      $$PlanItemsTableUpdateCompanionBuilder,
      (PlanItemRow, $$PlanItemsTableReferences),
      PlanItemRow,
      PrefetchHooks Function({
        bool planBlockId,
        bool exerciseId,
        bool strengthSetsRefs,
        bool cardioEntriesRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<int?> planDayId,
      Value<String?> title,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required SessionStatus status,
      Value<int?> durationSeconds,
      Value<String?> notes,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int?> planId,
      Value<int?> planDayId,
      Value<String?> title,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<SessionStatus> status,
      Value<int?> durationSeconds,
      Value<String?> notes,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans.createAlias(
    $_aliasNameGenerator(db.sessions.planId, db.plans.id),
  );

  $$PlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<int>('plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlanDaysTable _planDayIdTable(_$AppDatabase db) => db.planDays
      .createAlias($_aliasNameGenerator(db.sessions.planDayId, db.planDays.id));

  $$PlanDaysTableProcessedTableManager? get planDayId {
    final $_column = $_itemColumn<int>('plan_day_id');
    if ($_column == null) return null;
    final manager = $$PlanDaysTableTableManager(
      $_db,
      $_db.planDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StrengthSetsTable, List<StrengthSetRow>>
  _strengthSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.strengthSets,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.strengthSets.sessionId),
  );

  $$StrengthSetsTableProcessedTableManager get strengthSetsRefs {
    final manager = $$StrengthSetsTableTableManager(
      $_db,
      $_db.strengthSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_strengthSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardioEntriesTable, List<CardioEntryRow>>
  _cardioEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardioEntries,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.cardioEntries.sessionId),
  );

  $$CardioEntriesTableProcessedTableManager get cardioEntriesRefs {
    final manager = $$CardioEntriesTableTableManager(
      $_db,
      $_db.cardioEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardioEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecordRow>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: $_aliasNameGenerator(
      db.sessions.id,
      db.personalRecords.sessionId,
    ),
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanDaysTableFilterComposer get planDayId {
    final $$PlanDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableFilterComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> strengthSetsRefs(
    Expression<bool> Function($$StrengthSetsTableFilterComposer f) f,
  ) {
    final $$StrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardioEntriesRefs(
    Expression<bool> Function($$CardioEntriesTableFilterComposer f) f,
  ) {
    final $$CardioEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanDaysTableOrderingComposer get planDayId {
    final $$PlanDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableOrderingComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanDaysTableAnnotationComposer get planDayId {
    final $$PlanDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planDayId,
      referencedTable: $db.planDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.planDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> strengthSetsRefs<T extends Object>(
    Expression<T> Function($$StrengthSetsTableAnnotationComposer a) f,
  ) {
    final $$StrengthSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardioEntriesRefs<T extends Object>(
    Expression<T> Function($$CardioEntriesTableAnnotationComposer a) f,
  ) {
    final $$CardioEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({
            bool planId,
            bool planDayId,
            bool strengthSetsRefs,
            bool cardioEntriesRefs,
            bool personalRecordsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int?> planDayId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                planId: planId,
                planDayId: planDayId,
                title: title,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                durationSeconds: durationSeconds,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> planId = const Value.absent(),
                Value<int?> planDayId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required SessionStatus status,
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                planId: planId,
                planDayId: planDayId,
                title: title,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                durationSeconds: durationSeconds,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planId = false,
                planDayId = false,
                strengthSetsRefs = false,
                cardioEntriesRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (strengthSetsRefs) db.strengthSets,
                    if (cardioEntriesRefs) db.cardioEntries,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
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
                        if (planId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planId,
                                    referencedTable: $$SessionsTableReferences
                                        ._planIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._planIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (planDayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planDayId,
                                    referencedTable: $$SessionsTableReferences
                                        ._planDayIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._planDayIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (strengthSetsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          StrengthSetRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._strengthSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).strengthSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardioEntriesRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          CardioEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._cardioEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardioEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          PersonalRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({
        bool planId,
        bool planDayId,
        bool strengthSetsRefs,
        bool cardioEntriesRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$StrengthSetsTableCreateCompanionBuilder =
    StrengthSetsCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      Value<int?> planItemId,
      required int groupIndex,
      required BlockKind groupKind,
      Value<String?> groupLabel,
      required int roundIndex,
      required int itemIndex,
      Value<int?> plannedReps,
      Value<double?> plannedWeightKg,
      Value<int?> actualReps,
      Value<double?> actualWeightKg,
      Value<double?> rpe,
      Value<bool> isWarmup,
      required EntryStatus status,
      Value<int?> restTakenSeconds,
      Value<DateTime?> performedAt,
      Value<String?> notes,
    });
typedef $$StrengthSetsTableUpdateCompanionBuilder =
    StrengthSetsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int?> planItemId,
      Value<int> groupIndex,
      Value<BlockKind> groupKind,
      Value<String?> groupLabel,
      Value<int> roundIndex,
      Value<int> itemIndex,
      Value<int?> plannedReps,
      Value<double?> plannedWeightKg,
      Value<int?> actualReps,
      Value<double?> actualWeightKg,
      Value<double?> rpe,
      Value<bool> isWarmup,
      Value<EntryStatus> status,
      Value<int?> restTakenSeconds,
      Value<DateTime?> performedAt,
      Value<String?> notes,
    });

final class $$StrengthSetsTableReferences
    extends BaseReferences<_$AppDatabase, $StrengthSetsTable, StrengthSetRow> {
  $$StrengthSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.strengthSets.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.strengthSets.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlanItemsTable _planItemIdTable(_$AppDatabase db) =>
      db.planItems.createAlias(
        $_aliasNameGenerator(db.strengthSets.planItemId, db.planItems.id),
      );

  $$PlanItemsTableProcessedTableManager? get planItemId {
    final $_column = $_itemColumn<int>('plan_item_id');
    if ($_column == null) return null;
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExerciseBaselinesTable, List<ExerciseBaselineRow>>
  _exerciseBaselinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseBaselines,
        aliasName: $_aliasNameGenerator(
          db.strengthSets.id,
          db.exerciseBaselines.sourceSetId,
        ),
      );

  $$ExerciseBaselinesTableProcessedTableManager get exerciseBaselinesRefs {
    final manager = $$ExerciseBaselinesTableTableManager(
      $_db,
      $_db.exerciseBaselines,
    ).filter((f) => f.sourceSetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseBaselinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StrengthSetsTableFilterComposer
    extends Composer<_$AppDatabase, $StrengthSetsTable> {
  $$StrengthSetsTableFilterComposer({
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

  ColumnFilters<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BlockKind, BlockKind, String> get groupKind =>
      $composableBuilder(
        column: $table.groupKind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntryStatus, EntryStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableFilterComposer get planItemId {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> exerciseBaselinesRefs(
    Expression<bool> Function($$ExerciseBaselinesTableFilterComposer f) f,
  ) {
    final $$ExerciseBaselinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseBaselines,
      getReferencedColumn: (t) => t.sourceSetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseBaselinesTableFilterComposer(
            $db: $db,
            $table: $db.exerciseBaselines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StrengthSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $StrengthSetsTable> {
  $$StrengthSetsTableOrderingComposer({
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

  ColumnOrderings<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupKind => $composableBuilder(
    column: $table.groupKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableOrderingComposer get planItemId {
    final $$PlanItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableOrderingComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrengthSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrengthSetsTable> {
  $$StrengthSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BlockKind, String> get groupKind =>
      $composableBuilder(column: $table.groupKind, builder: (column) => column);

  GeneratedColumn<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumn<int> get plannedReps => $composableBuilder(
    column: $table.plannedReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedWeightKg => $composableBuilder(
    column: $table.plannedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualReps => $composableBuilder(
    column: $table.actualReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualWeightKg => $composableBuilder(
    column: $table.actualWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get restTakenSeconds => $composableBuilder(
    column: $table.restTakenSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableAnnotationComposer get planItemId {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> exerciseBaselinesRefs<T extends Object>(
    Expression<T> Function($$ExerciseBaselinesTableAnnotationComposer a) f,
  ) {
    final $$ExerciseBaselinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseBaselines,
          getReferencedColumn: (t) => t.sourceSetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseBaselinesTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseBaselines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StrengthSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrengthSetsTable,
          StrengthSetRow,
          $$StrengthSetsTableFilterComposer,
          $$StrengthSetsTableOrderingComposer,
          $$StrengthSetsTableAnnotationComposer,
          $$StrengthSetsTableCreateCompanionBuilder,
          $$StrengthSetsTableUpdateCompanionBuilder,
          (StrengthSetRow, $$StrengthSetsTableReferences),
          StrengthSetRow,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool planItemId,
            bool exerciseBaselinesRefs,
          })
        > {
  $$StrengthSetsTableTableManager(_$AppDatabase db, $StrengthSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrengthSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrengthSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrengthSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int?> planItemId = const Value.absent(),
                Value<int> groupIndex = const Value.absent(),
                Value<BlockKind> groupKind = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<int> itemIndex = const Value.absent(),
                Value<int?> plannedReps = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<EntryStatus> status = const Value.absent(),
                Value<int?> restTakenSeconds = const Value.absent(),
                Value<DateTime?> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => StrengthSetsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planItemId: planItemId,
                groupIndex: groupIndex,
                groupKind: groupKind,
                groupLabel: groupLabel,
                roundIndex: roundIndex,
                itemIndex: itemIndex,
                plannedReps: plannedReps,
                plannedWeightKg: plannedWeightKg,
                actualReps: actualReps,
                actualWeightKg: actualWeightKg,
                rpe: rpe,
                isWarmup: isWarmup,
                status: status,
                restTakenSeconds: restTakenSeconds,
                performedAt: performedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                Value<int?> planItemId = const Value.absent(),
                required int groupIndex,
                required BlockKind groupKind,
                Value<String?> groupLabel = const Value.absent(),
                required int roundIndex,
                required int itemIndex,
                Value<int?> plannedReps = const Value.absent(),
                Value<double?> plannedWeightKg = const Value.absent(),
                Value<int?> actualReps = const Value.absent(),
                Value<double?> actualWeightKg = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                required EntryStatus status,
                Value<int?> restTakenSeconds = const Value.absent(),
                Value<DateTime?> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => StrengthSetsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planItemId: planItemId,
                groupIndex: groupIndex,
                groupKind: groupKind,
                groupLabel: groupLabel,
                roundIndex: roundIndex,
                itemIndex: itemIndex,
                plannedReps: plannedReps,
                plannedWeightKg: plannedWeightKg,
                actualReps: actualReps,
                actualWeightKg: actualWeightKg,
                rpe: rpe,
                isWarmup: isWarmup,
                status: status,
                restTakenSeconds: restTakenSeconds,
                performedAt: performedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrengthSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                planItemId = false,
                exerciseBaselinesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseBaselinesRefs) db.exerciseBaselines,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$StrengthSetsTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$StrengthSetsTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$StrengthSetsTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$StrengthSetsTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (planItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planItemId,
                                    referencedTable:
                                        $$StrengthSetsTableReferences
                                            ._planItemIdTable(db),
                                    referencedColumn:
                                        $$StrengthSetsTableReferences
                                            ._planItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseBaselinesRefs)
                        await $_getPrefetchedData<
                          StrengthSetRow,
                          $StrengthSetsTable,
                          ExerciseBaselineRow
                        >(
                          currentTable: table,
                          referencedTable: $$StrengthSetsTableReferences
                              ._exerciseBaselinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StrengthSetsTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseBaselinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StrengthSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrengthSetsTable,
      StrengthSetRow,
      $$StrengthSetsTableFilterComposer,
      $$StrengthSetsTableOrderingComposer,
      $$StrengthSetsTableAnnotationComposer,
      $$StrengthSetsTableCreateCompanionBuilder,
      $$StrengthSetsTableUpdateCompanionBuilder,
      (StrengthSetRow, $$StrengthSetsTableReferences),
      StrengthSetRow,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool planItemId,
        bool exerciseBaselinesRefs,
      })
    >;
typedef $$CardioEntriesTableCreateCompanionBuilder =
    CardioEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required int exerciseId,
      Value<int?> planItemId,
      required int groupIndex,
      required BlockKind groupKind,
      Value<String?> groupLabel,
      required int roundIndex,
      required int itemIndex,
      Value<int?> plannedDurationSeconds,
      Value<double?> plannedDistanceMeters,
      Value<double?> plannedPaceSecPerKm,
      Value<int?> actualDurationSeconds,
      Value<double?> actualDistanceMeters,
      Value<double?> actualPaceSecPerKm,
      Value<double?> inclinePercent,
      Value<int?> resistanceLevel,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> calories,
      Value<double?> elevationGainMeters,
      required EntryStatus status,
      Value<DateTime?> performedAt,
      Value<String?> notes,
    });
typedef $$CardioEntriesTableUpdateCompanionBuilder =
    CardioEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<int> exerciseId,
      Value<int?> planItemId,
      Value<int> groupIndex,
      Value<BlockKind> groupKind,
      Value<String?> groupLabel,
      Value<int> roundIndex,
      Value<int> itemIndex,
      Value<int?> plannedDurationSeconds,
      Value<double?> plannedDistanceMeters,
      Value<double?> plannedPaceSecPerKm,
      Value<int?> actualDurationSeconds,
      Value<double?> actualDistanceMeters,
      Value<double?> actualPaceSecPerKm,
      Value<double?> inclinePercent,
      Value<int?> resistanceLevel,
      Value<int?> avgHeartRate,
      Value<int?> maxHeartRate,
      Value<int?> calories,
      Value<double?> elevationGainMeters,
      Value<EntryStatus> status,
      Value<DateTime?> performedAt,
      Value<String?> notes,
    });

final class $$CardioEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $CardioEntriesTable, CardioEntryRow> {
  $$CardioEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.cardioEntries.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.cardioEntries.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlanItemsTable _planItemIdTable(_$AppDatabase db) =>
      db.planItems.createAlias(
        $_aliasNameGenerator(db.cardioEntries.planItemId, db.planItems.id),
      );

  $$PlanItemsTableProcessedTableManager? get planItemId {
    final $_column = $_itemColumn<int>('plan_item_id');
    if ($_column == null) return null;
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardioSplitsTable, List<CardioSplitRow>>
  _cardioSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardioSplits,
    aliasName: $_aliasNameGenerator(
      db.cardioEntries.id,
      db.cardioSplits.cardioEntryId,
    ),
  );

  $$CardioSplitsTableProcessedTableManager get cardioSplitsRefs {
    final manager = $$CardioSplitsTableTableManager(
      $_db,
      $_db.cardioSplits,
    ).filter((f) => f.cardioEntryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardioSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardioEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CardioEntriesTable> {
  $$CardioEntriesTableFilterComposer({
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

  ColumnFilters<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BlockKind, BlockKind, String> get groupKind =>
      $composableBuilder(
        column: $table.groupKind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plannedPaceSecPerKm => $composableBuilder(
    column: $table.plannedPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualPaceSecPerKm => $composableBuilder(
    column: $table.actualPaceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resistanceLevel => $composableBuilder(
    column: $table.resistanceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntryStatus, EntryStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableFilterComposer get planItemId {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardioSplitsRefs(
    Expression<bool> Function($$CardioSplitsTableFilterComposer f) f,
  ) {
    final $$CardioSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioSplits,
      getReferencedColumn: (t) => t.cardioEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSplitsTableFilterComposer(
            $db: $db,
            $table: $db.cardioSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardioEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardioEntriesTable> {
  $$CardioEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupKind => $composableBuilder(
    column: $table.groupKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemIndex => $composableBuilder(
    column: $table.itemIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plannedPaceSecPerKm => $composableBuilder(
    column: $table.plannedPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualPaceSecPerKm => $composableBuilder(
    column: $table.actualPaceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resistanceLevel => $composableBuilder(
    column: $table.resistanceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableOrderingComposer get planItemId {
    final $$PlanItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableOrderingComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardioEntriesTable> {
  $$CardioEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get groupIndex => $composableBuilder(
    column: $table.groupIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BlockKind, String> get groupKind =>
      $composableBuilder(column: $table.groupKind, builder: (column) => column);

  GeneratedColumn<String> get groupLabel => $composableBuilder(
    column: $table.groupLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundIndex => $composableBuilder(
    column: $table.roundIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get itemIndex =>
      $composableBuilder(column: $table.itemIndex, builder: (column) => column);

  GeneratedColumn<int> get plannedDurationSeconds => $composableBuilder(
    column: $table.plannedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedDistanceMeters => $composableBuilder(
    column: $table.plannedDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get plannedPaceSecPerKm => $composableBuilder(
    column: $table.plannedPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationSeconds => $composableBuilder(
    column: $table.actualDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualDistanceMeters => $composableBuilder(
    column: $table.actualDistanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualPaceSecPerKm => $composableBuilder(
    column: $table.actualPaceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get inclinePercent => $composableBuilder(
    column: $table.inclinePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resistanceLevel => $composableBuilder(
    column: $table.resistanceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgHeartRate => $composableBuilder(
    column: $table.avgHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EntryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlanItemsTableAnnotationComposer get planItemId {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planItemId,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardioSplitsRefs<T extends Object>(
    Expression<T> Function($$CardioSplitsTableAnnotationComposer a) f,
  ) {
    final $$CardioSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardioSplits,
      getReferencedColumn: (t) => t.cardioEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardioEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardioEntriesTable,
          CardioEntryRow,
          $$CardioEntriesTableFilterComposer,
          $$CardioEntriesTableOrderingComposer,
          $$CardioEntriesTableAnnotationComposer,
          $$CardioEntriesTableCreateCompanionBuilder,
          $$CardioEntriesTableUpdateCompanionBuilder,
          (CardioEntryRow, $$CardioEntriesTableReferences),
          CardioEntryRow,
          PrefetchHooks Function({
            bool sessionId,
            bool exerciseId,
            bool planItemId,
            bool cardioSplitsRefs,
          })
        > {
  $$CardioEntriesTableTableManager(_$AppDatabase db, $CardioEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardioEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardioEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardioEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int?> planItemId = const Value.absent(),
                Value<int> groupIndex = const Value.absent(),
                Value<BlockKind> groupKind = const Value.absent(),
                Value<String?> groupLabel = const Value.absent(),
                Value<int> roundIndex = const Value.absent(),
                Value<int> itemIndex = const Value.absent(),
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<double?> plannedDistanceMeters = const Value.absent(),
                Value<double?> plannedPaceSecPerKm = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualDistanceMeters = const Value.absent(),
                Value<double?> actualPaceSecPerKm = const Value.absent(),
                Value<double?> inclinePercent = const Value.absent(),
                Value<int?> resistanceLevel = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<EntryStatus> status = const Value.absent(),
                Value<DateTime?> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CardioEntriesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planItemId: planItemId,
                groupIndex: groupIndex,
                groupKind: groupKind,
                groupLabel: groupLabel,
                roundIndex: roundIndex,
                itemIndex: itemIndex,
                plannedDurationSeconds: plannedDurationSeconds,
                plannedDistanceMeters: plannedDistanceMeters,
                plannedPaceSecPerKm: plannedPaceSecPerKm,
                actualDurationSeconds: actualDurationSeconds,
                actualDistanceMeters: actualDistanceMeters,
                actualPaceSecPerKm: actualPaceSecPerKm,
                inclinePercent: inclinePercent,
                resistanceLevel: resistanceLevel,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                calories: calories,
                elevationGainMeters: elevationGainMeters,
                status: status,
                performedAt: performedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int exerciseId,
                Value<int?> planItemId = const Value.absent(),
                required int groupIndex,
                required BlockKind groupKind,
                Value<String?> groupLabel = const Value.absent(),
                required int roundIndex,
                required int itemIndex,
                Value<int?> plannedDurationSeconds = const Value.absent(),
                Value<double?> plannedDistanceMeters = const Value.absent(),
                Value<double?> plannedPaceSecPerKm = const Value.absent(),
                Value<int?> actualDurationSeconds = const Value.absent(),
                Value<double?> actualDistanceMeters = const Value.absent(),
                Value<double?> actualPaceSecPerKm = const Value.absent(),
                Value<double?> inclinePercent = const Value.absent(),
                Value<int?> resistanceLevel = const Value.absent(),
                Value<int?> avgHeartRate = const Value.absent(),
                Value<int?> maxHeartRate = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                required EntryStatus status,
                Value<DateTime?> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => CardioEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                planItemId: planItemId,
                groupIndex: groupIndex,
                groupKind: groupKind,
                groupLabel: groupLabel,
                roundIndex: roundIndex,
                itemIndex: itemIndex,
                plannedDurationSeconds: plannedDurationSeconds,
                plannedDistanceMeters: plannedDistanceMeters,
                plannedPaceSecPerKm: plannedPaceSecPerKm,
                actualDurationSeconds: actualDurationSeconds,
                actualDistanceMeters: actualDistanceMeters,
                actualPaceSecPerKm: actualPaceSecPerKm,
                inclinePercent: inclinePercent,
                resistanceLevel: resistanceLevel,
                avgHeartRate: avgHeartRate,
                maxHeartRate: maxHeartRate,
                calories: calories,
                elevationGainMeters: elevationGainMeters,
                status: status,
                performedAt: performedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardioEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                exerciseId = false,
                planItemId = false,
                cardioSplitsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardioSplitsRefs) db.cardioSplits,
                  ],
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
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable:
                                        $$CardioEntriesTableReferences
                                            ._sessionIdTable(db),
                                    referencedColumn:
                                        $$CardioEntriesTableReferences
                                            ._sessionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$CardioEntriesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$CardioEntriesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (planItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planItemId,
                                    referencedTable:
                                        $$CardioEntriesTableReferences
                                            ._planItemIdTable(db),
                                    referencedColumn:
                                        $$CardioEntriesTableReferences
                                            ._planItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardioSplitsRefs)
                        await $_getPrefetchedData<
                          CardioEntryRow,
                          $CardioEntriesTable,
                          CardioSplitRow
                        >(
                          currentTable: table,
                          referencedTable: $$CardioEntriesTableReferences
                              ._cardioSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardioEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).cardioSplitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardioEntryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardioEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardioEntriesTable,
      CardioEntryRow,
      $$CardioEntriesTableFilterComposer,
      $$CardioEntriesTableOrderingComposer,
      $$CardioEntriesTableAnnotationComposer,
      $$CardioEntriesTableCreateCompanionBuilder,
      $$CardioEntriesTableUpdateCompanionBuilder,
      (CardioEntryRow, $$CardioEntriesTableReferences),
      CardioEntryRow,
      PrefetchHooks Function({
        bool sessionId,
        bool exerciseId,
        bool planItemId,
        bool cardioSplitsRefs,
      })
    >;
typedef $$CardioSplitsTableCreateCompanionBuilder =
    CardioSplitsCompanion Function({
      Value<int> id,
      required int cardioEntryId,
      required int splitIndex,
      required int durationSeconds,
      Value<double?> distanceMeters,
    });
typedef $$CardioSplitsTableUpdateCompanionBuilder =
    CardioSplitsCompanion Function({
      Value<int> id,
      Value<int> cardioEntryId,
      Value<int> splitIndex,
      Value<int> durationSeconds,
      Value<double?> distanceMeters,
    });

final class $$CardioSplitsTableReferences
    extends BaseReferences<_$AppDatabase, $CardioSplitsTable, CardioSplitRow> {
  $$CardioSplitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardioEntriesTable _cardioEntryIdTable(_$AppDatabase db) =>
      db.cardioEntries.createAlias(
        $_aliasNameGenerator(
          db.cardioSplits.cardioEntryId,
          db.cardioEntries.id,
        ),
      );

  $$CardioEntriesTableProcessedTableManager get cardioEntryId {
    final $_column = $_itemColumn<int>('cardio_entry_id')!;

    final manager = $$CardioEntriesTableTableManager(
      $_db,
      $_db.cardioEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardioEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardioSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $CardioSplitsTable> {
  $$CardioSplitsTableFilterComposer({
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

  ColumnFilters<int> get splitIndex => $composableBuilder(
    column: $table.splitIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  $$CardioEntriesTableFilterComposer get cardioEntryId {
    final $$CardioEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardioEntryId,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardioSplitsTable> {
  $$CardioSplitsTableOrderingComposer({
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

  ColumnOrderings<int> get splitIndex => $composableBuilder(
    column: $table.splitIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardioEntriesTableOrderingComposer get cardioEntryId {
    final $$CardioEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardioEntryId,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardioSplitsTable> {
  $$CardioSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get splitIndex => $composableBuilder(
    column: $table.splitIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  $$CardioEntriesTableAnnotationComposer get cardioEntryId {
    final $$CardioEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardioEntryId,
      referencedTable: $db.cardioEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardioEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardioEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardioSplitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardioSplitsTable,
          CardioSplitRow,
          $$CardioSplitsTableFilterComposer,
          $$CardioSplitsTableOrderingComposer,
          $$CardioSplitsTableAnnotationComposer,
          $$CardioSplitsTableCreateCompanionBuilder,
          $$CardioSplitsTableUpdateCompanionBuilder,
          (CardioSplitRow, $$CardioSplitsTableReferences),
          CardioSplitRow,
          PrefetchHooks Function({bool cardioEntryId})
        > {
  $$CardioSplitsTableTableManager(_$AppDatabase db, $CardioSplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardioSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardioSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardioSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardioEntryId = const Value.absent(),
                Value<int> splitIndex = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
              }) => CardioSplitsCompanion(
                id: id,
                cardioEntryId: cardioEntryId,
                splitIndex: splitIndex,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardioEntryId,
                required int splitIndex,
                required int durationSeconds,
                Value<double?> distanceMeters = const Value.absent(),
              }) => CardioSplitsCompanion.insert(
                id: id,
                cardioEntryId: cardioEntryId,
                splitIndex: splitIndex,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardioSplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardioEntryId = false}) {
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
                    if (cardioEntryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardioEntryId,
                                referencedTable: $$CardioSplitsTableReferences
                                    ._cardioEntryIdTable(db),
                                referencedColumn: $$CardioSplitsTableReferences
                                    ._cardioEntryIdTable(db)
                                    .id,
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

typedef $$CardioSplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardioSplitsTable,
      CardioSplitRow,
      $$CardioSplitsTableFilterComposer,
      $$CardioSplitsTableOrderingComposer,
      $$CardioSplitsTableAnnotationComposer,
      $$CardioSplitsTableCreateCompanionBuilder,
      $$CardioSplitsTableUpdateCompanionBuilder,
      (CardioSplitRow, $$CardioSplitsTableReferences),
      CardioSplitRow,
      PrefetchHooks Function({bool cardioEntryId})
    >;
typedef $$ExerciseBaselinesTableCreateCompanionBuilder =
    ExerciseBaselinesCompanion Function({
      Value<int> id,
      required int planId,
      required int exerciseId,
      required int reps,
      required double weightKg,
      required DateTime achievedAt,
      Value<int?> sourceSetId,
    });
typedef $$ExerciseBaselinesTableUpdateCompanionBuilder =
    ExerciseBaselinesCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<int> exerciseId,
      Value<int> reps,
      Value<double> weightKg,
      Value<DateTime> achievedAt,
      Value<int?> sourceSetId,
    });

final class $$ExerciseBaselinesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseBaselinesTable,
          ExerciseBaselineRow
        > {
  $$ExerciseBaselinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans.createAlias(
    $_aliasNameGenerator(db.exerciseBaselines.planId, db.plans.id),
  );

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.exerciseBaselines.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StrengthSetsTable _sourceSetIdTable(_$AppDatabase db) =>
      db.strengthSets.createAlias(
        $_aliasNameGenerator(
          db.exerciseBaselines.sourceSetId,
          db.strengthSets.id,
        ),
      );

  $$StrengthSetsTableProcessedTableManager? get sourceSetId {
    final $_column = $_itemColumn<int>('source_set_id');
    if ($_column == null) return null;
    final manager = $$StrengthSetsTableTableManager(
      $_db,
      $_db.strengthSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseBaselinesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseBaselinesTable> {
  $$ExerciseBaselinesTableFilterComposer({
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

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrengthSetsTableFilterComposer get sourceSetId {
    final $$StrengthSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSetId,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableFilterComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseBaselinesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseBaselinesTable> {
  $$ExerciseBaselinesTableOrderingComposer({
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

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrengthSetsTableOrderingComposer get sourceSetId {
    final $$StrengthSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSetId,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableOrderingComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseBaselinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseBaselinesTable> {
  $$ExerciseBaselinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StrengthSetsTableAnnotationComposer get sourceSetId {
    final $$StrengthSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSetId,
      referencedTable: $db.strengthSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrengthSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.strengthSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseBaselinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseBaselinesTable,
          ExerciseBaselineRow,
          $$ExerciseBaselinesTableFilterComposer,
          $$ExerciseBaselinesTableOrderingComposer,
          $$ExerciseBaselinesTableAnnotationComposer,
          $$ExerciseBaselinesTableCreateCompanionBuilder,
          $$ExerciseBaselinesTableUpdateCompanionBuilder,
          (ExerciseBaselineRow, $$ExerciseBaselinesTableReferences),
          ExerciseBaselineRow,
          PrefetchHooks Function({
            bool planId,
            bool exerciseId,
            bool sourceSetId,
          })
        > {
  $$ExerciseBaselinesTableTableManager(
    _$AppDatabase db,
    $ExerciseBaselinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseBaselinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseBaselinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseBaselinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<int?> sourceSetId = const Value.absent(),
              }) => ExerciseBaselinesCompanion(
                id: id,
                planId: planId,
                exerciseId: exerciseId,
                reps: reps,
                weightKg: weightKg,
                achievedAt: achievedAt,
                sourceSetId: sourceSetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required int exerciseId,
                required int reps,
                required double weightKg,
                required DateTime achievedAt,
                Value<int?> sourceSetId = const Value.absent(),
              }) => ExerciseBaselinesCompanion.insert(
                id: id,
                planId: planId,
                exerciseId: exerciseId,
                reps: reps,
                weightKg: weightKg,
                achievedAt: achievedAt,
                sourceSetId: sourceSetId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseBaselinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({planId = false, exerciseId = false, sourceSetId = false}) {
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
                        if (planId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.planId,
                                    referencedTable:
                                        $$ExerciseBaselinesTableReferences
                                            ._planIdTable(db),
                                    referencedColumn:
                                        $$ExerciseBaselinesTableReferences
                                            ._planIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (exerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.exerciseId,
                                    referencedTable:
                                        $$ExerciseBaselinesTableReferences
                                            ._exerciseIdTable(db),
                                    referencedColumn:
                                        $$ExerciseBaselinesTableReferences
                                            ._exerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceSetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSetId,
                                    referencedTable:
                                        $$ExerciseBaselinesTableReferences
                                            ._sourceSetIdTable(db),
                                    referencedColumn:
                                        $$ExerciseBaselinesTableReferences
                                            ._sourceSetIdTable(db)
                                            .id,
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

typedef $$ExerciseBaselinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseBaselinesTable,
      ExerciseBaselineRow,
      $$ExerciseBaselinesTableFilterComposer,
      $$ExerciseBaselinesTableOrderingComposer,
      $$ExerciseBaselinesTableAnnotationComposer,
      $$ExerciseBaselinesTableCreateCompanionBuilder,
      $$ExerciseBaselinesTableUpdateCompanionBuilder,
      (ExerciseBaselineRow, $$ExerciseBaselinesTableReferences),
      ExerciseBaselineRow,
      PrefetchHooks Function({bool planId, bool exerciseId, bool sourceSetId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      required int exerciseId,
      required RecordType recordType,
      Value<int> reps,
      required double value,
      required DateTime achievedAt,
      Value<int?> sessionId,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<int> id,
      Value<int> exerciseId,
      Value<RecordType> recordType,
      Value<int> reps,
      Value<double> value,
      Value<DateTime> achievedAt,
      Value<int?> sessionId,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow
        > {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias(
        $_aliasNameGenerator(db.personalRecords.exerciseId, db.exercises.id),
      );

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.personalRecords.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<RecordType, RecordType, String>
  get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecordType, String> get recordType =>
      $composableBuilder(
        column: $table.recordType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecordRow, $$PersonalRecordsTableReferences),
          PersonalRecordRow,
          PrefetchHooks Function({bool exerciseId, bool sessionId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<RecordType> recordType = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
              }) => PersonalRecordsCompanion(
                id: id,
                exerciseId: exerciseId,
                recordType: recordType,
                reps: reps,
                value: value,
                achievedAt: achievedAt,
                sessionId: sessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int exerciseId,
                required RecordType recordType,
                Value<int> reps = const Value.absent(),
                required double value,
                required DateTime achievedAt,
                Value<int?> sessionId = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                recordType: recordType,
                reps: reps,
                value: value,
                achievedAt: achievedAt,
                sessionId: sessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false, sessionId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
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

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecordRow,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecordRow, $$PersonalRecordsTableReferences),
      PersonalRecordRow,
      PrefetchHooks Function({bool exerciseId, bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PlanDaysTableTableManager get planDays =>
      $$PlanDaysTableTableManager(_db, _db.planDays);
  $$PlanBlocksTableTableManager get planBlocks =>
      $$PlanBlocksTableTableManager(_db, _db.planBlocks);
  $$PlanItemsTableTableManager get planItems =>
      $$PlanItemsTableTableManager(_db, _db.planItems);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$StrengthSetsTableTableManager get strengthSets =>
      $$StrengthSetsTableTableManager(_db, _db.strengthSets);
  $$CardioEntriesTableTableManager get cardioEntries =>
      $$CardioEntriesTableTableManager(_db, _db.cardioEntries);
  $$CardioSplitsTableTableManager get cardioSplits =>
      $$CardioSplitsTableTableManager(_db, _db.cardioSplits);
  $$ExerciseBaselinesTableTableManager get exerciseBaselines =>
      $$ExerciseBaselinesTableTableManager(_db, _db.exerciseBaselines);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
