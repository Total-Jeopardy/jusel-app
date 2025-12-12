// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UsersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    defaultValue: const Constant(true),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    role,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UsersTableData extends DataClass implements Insertable<UsersTableData> {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const UsersTableData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: Value(email),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UsersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UsersTableData copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UsersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UsersTableData copyWithCompanion(UsersTableCompanion data) {
    return UsersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, role, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.role == this.role &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersTableCompanion extends UpdateCompanion<UsersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> role;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String role,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone),
       email = Value(email),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<UsersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? role,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? email,
    Value<String>? role,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isProducedMeta = const VerificationMeta(
    'isProduced',
  );
  @override
  late final GeneratedColumn<bool> isProduced = GeneratedColumn<bool>(
    'is_produced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_produced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _currentSellingPriceMeta =
      const VerificationMeta('currentSellingPrice');
  @override
  late final GeneratedColumn<double> currentSellingPrice =
      GeneratedColumn<double>(
        'current_selling_price',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currentCostPriceMeta = const VerificationMeta(
    'currentCostPrice',
  );
  @override
  late final GeneratedColumn<double> currentCostPrice = GeneratedColumn<double>(
    'current_cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentStockQtyMeta = const VerificationMeta(
    'currentStockQty',
  );
  @override
  late final GeneratedColumn<int> currentStockQty = GeneratedColumn<int>(
    'current_stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitsPerPackMeta = const VerificationMeta(
    'unitsPerPack',
  );
  @override
  late final GeneratedColumn<int> unitsPerPack = GeneratedColumn<int>(
    'units_per_pack',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    subcategory,
    imageUrl,
    isProduced,
    currentSellingPrice,
    currentCostPrice,
    currentStockQty,
    unitsPerPack,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_produced')) {
      context.handle(
        _isProducedMeta,
        isProduced.isAcceptableOrUnknown(data['is_produced']!, _isProducedMeta),
      );
    } else if (isInserting) {
      context.missing(_isProducedMeta);
    }
    if (data.containsKey('current_selling_price')) {
      context.handle(
        _currentSellingPriceMeta,
        currentSellingPrice.isAcceptableOrUnknown(
          data['current_selling_price']!,
          _currentSellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentSellingPriceMeta);
    }
    if (data.containsKey('current_cost_price')) {
      context.handle(
        _currentCostPriceMeta,
        currentCostPrice.isAcceptableOrUnknown(
          data['current_cost_price']!,
          _currentCostPriceMeta,
        ),
      );
    }
    if (data.containsKey('current_stock_qty')) {
      context.handle(
        _currentStockQtyMeta,
        currentStockQty.isAcceptableOrUnknown(
          data['current_stock_qty']!,
          _currentStockQtyMeta,
        ),
      );
    }
    if (data.containsKey('units_per_pack')) {
      context.handle(
        _unitsPerPackMeta,
        unitsPerPack.isAcceptableOrUnknown(
          data['units_per_pack']!,
          _unitsPerPackMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      isProduced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_produced'],
      )!,
      currentSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_selling_price'],
      )!,
      currentCostPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_cost_price'],
      ),
      currentStockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_stock_qty'],
      )!,
      unitsPerPack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}units_per_pack'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String? imageUrl;
  final bool isProduced;
  final double currentSellingPrice;
  final double? currentCostPrice;
  final int currentStockQty;
  final int? unitsPerPack;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const ProductsTableData({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.imageUrl,
    required this.isProduced,
    required this.currentSellingPrice,
    this.currentCostPrice,
    required this.currentStockQty,
    this.unitsPerPack,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_produced'] = Variable<bool>(isProduced);
    map['current_selling_price'] = Variable<double>(currentSellingPrice);
    if (!nullToAbsent || currentCostPrice != null) {
      map['current_cost_price'] = Variable<double>(currentCostPrice);
    }
    map['current_stock_qty'] = Variable<int>(currentStockQty);
    if (!nullToAbsent || unitsPerPack != null) {
      map['units_per_pack'] = Variable<int>(unitsPerPack);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isProduced: Value(isProduced),
      currentSellingPrice: Value(currentSellingPrice),
      currentCostPrice: currentCostPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(currentCostPrice),
      currentStockQty: Value(currentStockQty),
      unitsPerPack: unitsPerPack == null && nullToAbsent
          ? const Value.absent()
          : Value(unitsPerPack),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ProductsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isProduced: serializer.fromJson<bool>(json['isProduced']),
      currentSellingPrice: serializer.fromJson<double>(
        json['currentSellingPrice'],
      ),
      currentCostPrice: serializer.fromJson<double?>(json['currentCostPrice']),
      currentStockQty: serializer.fromJson<int>(json['currentStockQty']),
      unitsPerPack: serializer.fromJson<int?>(json['unitsPerPack']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'subcategory': serializer.toJson<String?>(subcategory),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isProduced': serializer.toJson<bool>(isProduced),
      'currentSellingPrice': serializer.toJson<double>(currentSellingPrice),
      'currentCostPrice': serializer.toJson<double?>(currentCostPrice),
      'currentStockQty': serializer.toJson<int>(currentStockQty),
      'unitsPerPack': serializer.toJson<int?>(unitsPerPack),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ProductsTableData copyWith({
    String? id,
    String? name,
    String? category,
    Value<String?> subcategory = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    bool? isProduced,
    double? currentSellingPrice,
    Value<double?> currentCostPrice = const Value.absent(),
    int? currentStockQty,
    Value<int?> unitsPerPack = const Value.absent(),
    String? status,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => ProductsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    isProduced: isProduced ?? this.isProduced,
    currentSellingPrice: currentSellingPrice ?? this.currentSellingPrice,
    currentCostPrice: currentCostPrice.present
        ? currentCostPrice.value
        : this.currentCostPrice,
    currentStockQty: currentStockQty ?? this.currentStockQty,
    unitsPerPack: unitsPerPack.present ? unitsPerPack.value : this.unitsPerPack,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isProduced: data.isProduced.present
          ? data.isProduced.value
          : this.isProduced,
      currentSellingPrice: data.currentSellingPrice.present
          ? data.currentSellingPrice.value
          : this.currentSellingPrice,
      currentCostPrice: data.currentCostPrice.present
          ? data.currentCostPrice.value
          : this.currentCostPrice,
      currentStockQty: data.currentStockQty.present
          ? data.currentStockQty.value
          : this.currentStockQty,
      unitsPerPack: data.unitsPerPack.present
          ? data.unitsPerPack.value
          : this.unitsPerPack,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isProduced: $isProduced, ')
          ..write('currentSellingPrice: $currentSellingPrice, ')
          ..write('currentCostPrice: $currentCostPrice, ')
          ..write('currentStockQty: $currentStockQty, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    subcategory,
    imageUrl,
    isProduced,
    currentSellingPrice,
    currentCostPrice,
    currentStockQty,
    unitsPerPack,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.imageUrl == this.imageUrl &&
          other.isProduced == this.isProduced &&
          other.currentSellingPrice == this.currentSellingPrice &&
          other.currentCostPrice == this.currentCostPrice &&
          other.currentStockQty == this.currentStockQty &&
          other.unitsPerPack == this.unitsPerPack &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> subcategory;
  final Value<String?> imageUrl;
  final Value<bool> isProduced;
  final Value<double> currentSellingPrice;
  final Value<double?> currentCostPrice;
  final Value<int> currentStockQty;
  final Value<int?> unitsPerPack;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const ProductsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isProduced = const Value.absent(),
    this.currentSellingPrice = const Value.absent(),
    this.currentCostPrice = const Value.absent(),
    this.currentStockQty = const Value.absent(),
    this.unitsPerPack = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.subcategory = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required bool isProduced,
    required double currentSellingPrice,
    this.currentCostPrice = const Value.absent(),
    this.currentStockQty = const Value.absent(),
    this.unitsPerPack = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       isProduced = Value(isProduced),
       currentSellingPrice = Value(currentSellingPrice),
       createdAt = Value(createdAt);
  static Insertable<ProductsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? imageUrl,
    Expression<bool>? isProduced,
    Expression<double>? currentSellingPrice,
    Expression<double>? currentCostPrice,
    Expression<int>? currentStockQty,
    Expression<int>? unitsPerPack,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isProduced != null) 'is_produced': isProduced,
      if (currentSellingPrice != null)
        'current_selling_price': currentSellingPrice,
      if (currentCostPrice != null) 'current_cost_price': currentCostPrice,
      if (currentStockQty != null) 'current_stock_qty': currentStockQty,
      if (unitsPerPack != null) 'units_per_pack': unitsPerPack,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? subcategory,
    Value<String?>? imageUrl,
    Value<bool>? isProduced,
    Value<double>? currentSellingPrice,
    Value<double?>? currentCostPrice,
    Value<int>? currentStockQty,
    Value<int?>? unitsPerPack,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProductsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      imageUrl: imageUrl ?? this.imageUrl,
      isProduced: isProduced ?? this.isProduced,
      currentSellingPrice: currentSellingPrice ?? this.currentSellingPrice,
      currentCostPrice: currentCostPrice ?? this.currentCostPrice,
      currentStockQty: currentStockQty ?? this.currentStockQty,
      unitsPerPack: unitsPerPack ?? this.unitsPerPack,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isProduced.present) {
      map['is_produced'] = Variable<bool>(isProduced.value);
    }
    if (currentSellingPrice.present) {
      map['current_selling_price'] = Variable<double>(
        currentSellingPrice.value,
      );
    }
    if (currentCostPrice.present) {
      map['current_cost_price'] = Variable<double>(currentCostPrice.value);
    }
    if (currentStockQty.present) {
      map['current_stock_qty'] = Variable<int>(currentStockQty.value);
    }
    if (unitsPerPack.present) {
      map['units_per_pack'] = Variable<int>(unitsPerPack.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isProduced: $isProduced, ')
          ..write('currentSellingPrice: $currentSellingPrice, ')
          ..write('currentCostPrice: $currentCostPrice, ')
          ..write('currentStockQty: $currentStockQty, ')
          ..write('unitsPerPack: $unitsPerPack, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductPriceHistoryTableTable extends ProductPriceHistoryTable
    with
        TableInfo<
          $ProductPriceHistoryTableTable,
          ProductPriceHistoryTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductPriceHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldSellingPriceMeta = const VerificationMeta(
    'oldSellingPrice',
  );
  @override
  late final GeneratedColumn<double> oldSellingPrice = GeneratedColumn<double>(
    'old_selling_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newSellingPriceMeta = const VerificationMeta(
    'newSellingPrice',
  );
  @override
  late final GeneratedColumn<double> newSellingPrice = GeneratedColumn<double>(
    'new_selling_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldCostPriceMeta = const VerificationMeta(
    'oldCostPrice',
  );
  @override
  late final GeneratedColumn<double> oldCostPrice = GeneratedColumn<double>(
    'old_cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newCostPriceMeta = const VerificationMeta(
    'newCostPrice',
  );
  @override
  late final GeneratedColumn<double> newCostPrice = GeneratedColumn<double>(
    'new_cost_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    oldSellingPrice,
    newSellingPrice,
    oldCostPrice,
    newCostPrice,
    changeType,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_price_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductPriceHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('old_selling_price')) {
      context.handle(
        _oldSellingPriceMeta,
        oldSellingPrice.isAcceptableOrUnknown(
          data['old_selling_price']!,
          _oldSellingPriceMeta,
        ),
      );
    }
    if (data.containsKey('new_selling_price')) {
      context.handle(
        _newSellingPriceMeta,
        newSellingPrice.isAcceptableOrUnknown(
          data['new_selling_price']!,
          _newSellingPriceMeta,
        ),
      );
    }
    if (data.containsKey('old_cost_price')) {
      context.handle(
        _oldCostPriceMeta,
        oldCostPrice.isAcceptableOrUnknown(
          data['old_cost_price']!,
          _oldCostPriceMeta,
        ),
      );
    }
    if (data.containsKey('new_cost_price')) {
      context.handle(
        _newCostPriceMeta,
        newCostPrice.isAcceptableOrUnknown(
          data['new_cost_price']!,
          _newCostPriceMeta,
        ),
      );
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductPriceHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductPriceHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      oldSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}old_selling_price'],
      ),
      newSellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_selling_price'],
      ),
      oldCostPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}old_cost_price'],
      ),
      newCostPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_cost_price'],
      ),
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductPriceHistoryTableTable createAlias(String alias) {
    return $ProductPriceHistoryTableTable(attachedDatabase, alias);
  }
}

class ProductPriceHistoryTableData extends DataClass
    implements Insertable<ProductPriceHistoryTableData> {
  final String id;
  final String productId;
  final double? oldSellingPrice;
  final double? newSellingPrice;
  final double? oldCostPrice;
  final double? newCostPrice;
  final String changeType;
  final String? reason;
  final DateTime createdAt;
  const ProductPriceHistoryTableData({
    required this.id,
    required this.productId,
    this.oldSellingPrice,
    this.newSellingPrice,
    this.oldCostPrice,
    this.newCostPrice,
    required this.changeType,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    if (!nullToAbsent || oldSellingPrice != null) {
      map['old_selling_price'] = Variable<double>(oldSellingPrice);
    }
    if (!nullToAbsent || newSellingPrice != null) {
      map['new_selling_price'] = Variable<double>(newSellingPrice);
    }
    if (!nullToAbsent || oldCostPrice != null) {
      map['old_cost_price'] = Variable<double>(oldCostPrice);
    }
    if (!nullToAbsent || newCostPrice != null) {
      map['new_cost_price'] = Variable<double>(newCostPrice);
    }
    map['change_type'] = Variable<String>(changeType);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductPriceHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return ProductPriceHistoryTableCompanion(
      id: Value(id),
      productId: Value(productId),
      oldSellingPrice: oldSellingPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(oldSellingPrice),
      newSellingPrice: newSellingPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(newSellingPrice),
      oldCostPrice: oldCostPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(oldCostPrice),
      newCostPrice: newCostPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(newCostPrice),
      changeType: Value(changeType),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory ProductPriceHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductPriceHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      oldSellingPrice: serializer.fromJson<double?>(json['oldSellingPrice']),
      newSellingPrice: serializer.fromJson<double?>(json['newSellingPrice']),
      oldCostPrice: serializer.fromJson<double?>(json['oldCostPrice']),
      newCostPrice: serializer.fromJson<double?>(json['newCostPrice']),
      changeType: serializer.fromJson<String>(json['changeType']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'oldSellingPrice': serializer.toJson<double?>(oldSellingPrice),
      'newSellingPrice': serializer.toJson<double?>(newSellingPrice),
      'oldCostPrice': serializer.toJson<double?>(oldCostPrice),
      'newCostPrice': serializer.toJson<double?>(newCostPrice),
      'changeType': serializer.toJson<String>(changeType),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProductPriceHistoryTableData copyWith({
    String? id,
    String? productId,
    Value<double?> oldSellingPrice = const Value.absent(),
    Value<double?> newSellingPrice = const Value.absent(),
    Value<double?> oldCostPrice = const Value.absent(),
    Value<double?> newCostPrice = const Value.absent(),
    String? changeType,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => ProductPriceHistoryTableData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    oldSellingPrice: oldSellingPrice.present
        ? oldSellingPrice.value
        : this.oldSellingPrice,
    newSellingPrice: newSellingPrice.present
        ? newSellingPrice.value
        : this.newSellingPrice,
    oldCostPrice: oldCostPrice.present ? oldCostPrice.value : this.oldCostPrice,
    newCostPrice: newCostPrice.present ? newCostPrice.value : this.newCostPrice,
    changeType: changeType ?? this.changeType,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  ProductPriceHistoryTableData copyWithCompanion(
    ProductPriceHistoryTableCompanion data,
  ) {
    return ProductPriceHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      oldSellingPrice: data.oldSellingPrice.present
          ? data.oldSellingPrice.value
          : this.oldSellingPrice,
      newSellingPrice: data.newSellingPrice.present
          ? data.newSellingPrice.value
          : this.newSellingPrice,
      oldCostPrice: data.oldCostPrice.present
          ? data.oldCostPrice.value
          : this.oldCostPrice,
      newCostPrice: data.newCostPrice.present
          ? data.newCostPrice.value
          : this.newCostPrice,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductPriceHistoryTableData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('oldSellingPrice: $oldSellingPrice, ')
          ..write('newSellingPrice: $newSellingPrice, ')
          ..write('oldCostPrice: $oldCostPrice, ')
          ..write('newCostPrice: $newCostPrice, ')
          ..write('changeType: $changeType, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    oldSellingPrice,
    newSellingPrice,
    oldCostPrice,
    newCostPrice,
    changeType,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductPriceHistoryTableData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.oldSellingPrice == this.oldSellingPrice &&
          other.newSellingPrice == this.newSellingPrice &&
          other.oldCostPrice == this.oldCostPrice &&
          other.newCostPrice == this.newCostPrice &&
          other.changeType == this.changeType &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class ProductPriceHistoryTableCompanion
    extends UpdateCompanion<ProductPriceHistoryTableData> {
  final Value<String> id;
  final Value<String> productId;
  final Value<double?> oldSellingPrice;
  final Value<double?> newSellingPrice;
  final Value<double?> oldCostPrice;
  final Value<double?> newCostPrice;
  final Value<String> changeType;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProductPriceHistoryTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.oldSellingPrice = const Value.absent(),
    this.newSellingPrice = const Value.absent(),
    this.oldCostPrice = const Value.absent(),
    this.newCostPrice = const Value.absent(),
    this.changeType = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductPriceHistoryTableCompanion.insert({
    required String id,
    required String productId,
    this.oldSellingPrice = const Value.absent(),
    this.newSellingPrice = const Value.absent(),
    this.oldCostPrice = const Value.absent(),
    this.newCostPrice = const Value.absent(),
    required String changeType,
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       changeType = Value(changeType),
       createdAt = Value(createdAt);
  static Insertable<ProductPriceHistoryTableData> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<double>? oldSellingPrice,
    Expression<double>? newSellingPrice,
    Expression<double>? oldCostPrice,
    Expression<double>? newCostPrice,
    Expression<String>? changeType,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (oldSellingPrice != null) 'old_selling_price': oldSellingPrice,
      if (newSellingPrice != null) 'new_selling_price': newSellingPrice,
      if (oldCostPrice != null) 'old_cost_price': oldCostPrice,
      if (newCostPrice != null) 'new_cost_price': newCostPrice,
      if (changeType != null) 'change_type': changeType,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductPriceHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<double?>? oldSellingPrice,
    Value<double?>? newSellingPrice,
    Value<double?>? oldCostPrice,
    Value<double?>? newCostPrice,
    Value<String>? changeType,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProductPriceHistoryTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      oldSellingPrice: oldSellingPrice ?? this.oldSellingPrice,
      newSellingPrice: newSellingPrice ?? this.newSellingPrice,
      oldCostPrice: oldCostPrice ?? this.oldCostPrice,
      newCostPrice: newCostPrice ?? this.newCostPrice,
      changeType: changeType ?? this.changeType,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (oldSellingPrice.present) {
      map['old_selling_price'] = Variable<double>(oldSellingPrice.value);
    }
    if (newSellingPrice.present) {
      map['new_selling_price'] = Variable<double>(newSellingPrice.value);
    }
    if (oldCostPrice.present) {
      map['old_cost_price'] = Variable<double>(oldCostPrice.value);
    }
    if (newCostPrice.present) {
      map['new_cost_price'] = Variable<double>(newCostPrice.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductPriceHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('oldSellingPrice: $oldSellingPrice, ')
          ..write('newSellingPrice: $newSellingPrice, ')
          ..write('oldCostPrice: $oldCostPrice, ')
          ..write('newCostPrice: $newCostPrice, ')
          ..write('changeType: $changeType, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTableTable extends StockMovementsTable
    with TableInfo<$StockMovementsTableTable, StockMovementsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUnitsMeta = const VerificationMeta(
    'quantityUnits',
  );
  @override
  late final GeneratedColumn<int> quantityUnits = GeneratedColumn<int>(
    'quantity_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityPacksMeta = const VerificationMeta(
    'quantityPacks',
  );
  @override
  late final GeneratedColumn<int> quantityPacks = GeneratedColumn<int>(
    'quantity_packs',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costPerUnitMeta = const VerificationMeta(
    'costPerUnit',
  );
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
    'cost_per_unit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellingPricePerUnitMeta =
      const VerificationMeta('sellingPricePerUnit');
  @override
  late final GeneratedColumn<double> sellingPricePerUnit =
      GeneratedColumn<double>(
        'selling_price_per_unit',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _totalRevenueMeta = const VerificationMeta(
    'totalRevenue',
  );
  @override
  late final GeneratedColumn<double> totalRevenue = GeneratedColumn<double>(
    'total_revenue',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<double> profit = GeneratedColumn<double>(
    'profit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<String> createdByUserId = GeneratedColumn<String>(
    'created_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    type,
    quantityUnits,
    quantityPacks,
    batchId,
    costPerUnit,
    totalCost,
    sellingPricePerUnit,
    totalRevenue,
    profit,
    paymentMethod,
    reason,
    createdByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity_units')) {
      context.handle(
        _quantityUnitsMeta,
        quantityUnits.isAcceptableOrUnknown(
          data['quantity_units']!,
          _quantityUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitsMeta);
    }
    if (data.containsKey('quantity_packs')) {
      context.handle(
        _quantityPacksMeta,
        quantityPacks.isAcceptableOrUnknown(
          data['quantity_packs']!,
          _quantityPacksMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
        _costPerUnitMeta,
        costPerUnit.isAcceptableOrUnknown(
          data['cost_per_unit']!,
          _costPerUnitMeta,
        ),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    }
    if (data.containsKey('selling_price_per_unit')) {
      context.handle(
        _sellingPricePerUnitMeta,
        sellingPricePerUnit.isAcceptableOrUnknown(
          data['selling_price_per_unit']!,
          _sellingPricePerUnitMeta,
        ),
      );
    }
    if (data.containsKey('total_revenue')) {
      context.handle(
        _totalRevenueMeta,
        totalRevenue.isAcceptableOrUnknown(
          data['total_revenue']!,
          _totalRevenueMeta,
        ),
      );
    }
    if (data.containsKey('profit')) {
      context.handle(
        _profitMeta,
        profit.isAcceptableOrUnknown(data['profit']!, _profitMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdByUserIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      quantityUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_units'],
      )!,
      quantityPacks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_packs'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      costPerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_per_unit'],
      ),
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      ),
      sellingPricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price_per_unit'],
      ),
      totalRevenue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_revenue'],
      ),
      profit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTableTable createAlias(String alias) {
    return $StockMovementsTableTable(attachedDatabase, alias);
  }
}

class StockMovementsTableData extends DataClass
    implements Insertable<StockMovementsTableData> {
  final String id;
  final String productId;
  final String type;
  final int quantityUnits;
  final int? quantityPacks;
  final String? batchId;
  final double? costPerUnit;
  final double? totalCost;
  final double? sellingPricePerUnit;
  final double? totalRevenue;
  final double? profit;
  final String? paymentMethod;
  final String? reason;
  final String createdByUserId;
  final DateTime createdAt;
  const StockMovementsTableData({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityUnits,
    this.quantityPacks,
    this.batchId,
    this.costPerUnit,
    this.totalCost,
    this.sellingPricePerUnit,
    this.totalRevenue,
    this.profit,
    this.paymentMethod,
    this.reason,
    required this.createdByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['type'] = Variable<String>(type);
    map['quantity_units'] = Variable<int>(quantityUnits);
    if (!nullToAbsent || quantityPacks != null) {
      map['quantity_packs'] = Variable<int>(quantityPacks);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || costPerUnit != null) {
      map['cost_per_unit'] = Variable<double>(costPerUnit);
    }
    if (!nullToAbsent || totalCost != null) {
      map['total_cost'] = Variable<double>(totalCost);
    }
    if (!nullToAbsent || sellingPricePerUnit != null) {
      map['selling_price_per_unit'] = Variable<double>(sellingPricePerUnit);
    }
    if (!nullToAbsent || totalRevenue != null) {
      map['total_revenue'] = Variable<double>(totalRevenue);
    }
    if (!nullToAbsent || profit != null) {
      map['profit'] = Variable<double>(profit);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_by_user_id'] = Variable<String>(createdByUserId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsTableCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsTableCompanion(
      id: Value(id),
      productId: Value(productId),
      type: Value(type),
      quantityUnits: Value(quantityUnits),
      quantityPacks: quantityPacks == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityPacks),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      costPerUnit: costPerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(costPerUnit),
      totalCost: totalCost == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCost),
      sellingPricePerUnit: sellingPricePerUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(sellingPricePerUnit),
      totalRevenue: totalRevenue == null && nullToAbsent
          ? const Value.absent()
          : Value(totalRevenue),
      profit: profit == null && nullToAbsent
          ? const Value.absent()
          : Value(profit),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdByUserId: Value(createdByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovementsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementsTableData(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      type: serializer.fromJson<String>(json['type']),
      quantityUnits: serializer.fromJson<int>(json['quantityUnits']),
      quantityPacks: serializer.fromJson<int?>(json['quantityPacks']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      costPerUnit: serializer.fromJson<double?>(json['costPerUnit']),
      totalCost: serializer.fromJson<double?>(json['totalCost']),
      sellingPricePerUnit: serializer.fromJson<double?>(
        json['sellingPricePerUnit'],
      ),
      totalRevenue: serializer.fromJson<double?>(json['totalRevenue']),
      profit: serializer.fromJson<double?>(json['profit']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      reason: serializer.fromJson<String?>(json['reason']),
      createdByUserId: serializer.fromJson<String>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'type': serializer.toJson<String>(type),
      'quantityUnits': serializer.toJson<int>(quantityUnits),
      'quantityPacks': serializer.toJson<int?>(quantityPacks),
      'batchId': serializer.toJson<String?>(batchId),
      'costPerUnit': serializer.toJson<double?>(costPerUnit),
      'totalCost': serializer.toJson<double?>(totalCost),
      'sellingPricePerUnit': serializer.toJson<double?>(sellingPricePerUnit),
      'totalRevenue': serializer.toJson<double?>(totalRevenue),
      'profit': serializer.toJson<double?>(profit),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'reason': serializer.toJson<String?>(reason),
      'createdByUserId': serializer.toJson<String>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovementsTableData copyWith({
    String? id,
    String? productId,
    String? type,
    int? quantityUnits,
    Value<int?> quantityPacks = const Value.absent(),
    Value<String?> batchId = const Value.absent(),
    Value<double?> costPerUnit = const Value.absent(),
    Value<double?> totalCost = const Value.absent(),
    Value<double?> sellingPricePerUnit = const Value.absent(),
    Value<double?> totalRevenue = const Value.absent(),
    Value<double?> profit = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    String? createdByUserId,
    DateTime? createdAt,
  }) => StockMovementsTableData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    type: type ?? this.type,
    quantityUnits: quantityUnits ?? this.quantityUnits,
    quantityPacks: quantityPacks.present
        ? quantityPacks.value
        : this.quantityPacks,
    batchId: batchId.present ? batchId.value : this.batchId,
    costPerUnit: costPerUnit.present ? costPerUnit.value : this.costPerUnit,
    totalCost: totalCost.present ? totalCost.value : this.totalCost,
    sellingPricePerUnit: sellingPricePerUnit.present
        ? sellingPricePerUnit.value
        : this.sellingPricePerUnit,
    totalRevenue: totalRevenue.present ? totalRevenue.value : this.totalRevenue,
    profit: profit.present ? profit.value : this.profit,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    reason: reason.present ? reason.value : this.reason,
    createdByUserId: createdByUserId ?? this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovementsTableData copyWithCompanion(StockMovementsTableCompanion data) {
    return StockMovementsTableData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      type: data.type.present ? data.type.value : this.type,
      quantityUnits: data.quantityUnits.present
          ? data.quantityUnits.value
          : this.quantityUnits,
      quantityPacks: data.quantityPacks.present
          ? data.quantityPacks.value
          : this.quantityPacks,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      costPerUnit: data.costPerUnit.present
          ? data.costPerUnit.value
          : this.costPerUnit,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      sellingPricePerUnit: data.sellingPricePerUnit.present
          ? data.sellingPricePerUnit.value
          : this.sellingPricePerUnit,
      totalRevenue: data.totalRevenue.present
          ? data.totalRevenue.value
          : this.totalRevenue,
      profit: data.profit.present ? data.profit.value : this.profit,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsTableData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityUnits: $quantityUnits, ')
          ..write('quantityPacks: $quantityPacks, ')
          ..write('batchId: $batchId, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('totalCost: $totalCost, ')
          ..write('sellingPricePerUnit: $sellingPricePerUnit, ')
          ..write('totalRevenue: $totalRevenue, ')
          ..write('profit: $profit, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reason: $reason, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    type,
    quantityUnits,
    quantityPacks,
    batchId,
    costPerUnit,
    totalCost,
    sellingPricePerUnit,
    totalRevenue,
    profit,
    paymentMethod,
    reason,
    createdByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementsTableData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.type == this.type &&
          other.quantityUnits == this.quantityUnits &&
          other.quantityPacks == this.quantityPacks &&
          other.batchId == this.batchId &&
          other.costPerUnit == this.costPerUnit &&
          other.totalCost == this.totalCost &&
          other.sellingPricePerUnit == this.sellingPricePerUnit &&
          other.totalRevenue == this.totalRevenue &&
          other.profit == this.profit &&
          other.paymentMethod == this.paymentMethod &&
          other.reason == this.reason &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt);
}

class StockMovementsTableCompanion
    extends UpdateCompanion<StockMovementsTableData> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> type;
  final Value<int> quantityUnits;
  final Value<int?> quantityPacks;
  final Value<String?> batchId;
  final Value<double?> costPerUnit;
  final Value<double?> totalCost;
  final Value<double?> sellingPricePerUnit;
  final Value<double?> totalRevenue;
  final Value<double?> profit;
  final Value<String?> paymentMethod;
  final Value<String?> reason;
  final Value<String> createdByUserId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantityUnits = const Value.absent(),
    this.quantityPacks = const Value.absent(),
    this.batchId = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.sellingPricePerUnit = const Value.absent(),
    this.totalRevenue = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsTableCompanion.insert({
    required String id,
    required String productId,
    required String type,
    required int quantityUnits,
    this.quantityPacks = const Value.absent(),
    this.batchId = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.sellingPricePerUnit = const Value.absent(),
    this.totalRevenue = const Value.absent(),
    this.profit = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reason = const Value.absent(),
    required String createdByUserId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       type = Value(type),
       quantityUnits = Value(quantityUnits),
       createdByUserId = Value(createdByUserId),
       createdAt = Value(createdAt);
  static Insertable<StockMovementsTableData> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? type,
    Expression<int>? quantityUnits,
    Expression<int>? quantityPacks,
    Expression<String>? batchId,
    Expression<double>? costPerUnit,
    Expression<double>? totalCost,
    Expression<double>? sellingPricePerUnit,
    Expression<double>? totalRevenue,
    Expression<double>? profit,
    Expression<String>? paymentMethod,
    Expression<String>? reason,
    Expression<String>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (type != null) 'type': type,
      if (quantityUnits != null) 'quantity_units': quantityUnits,
      if (quantityPacks != null) 'quantity_packs': quantityPacks,
      if (batchId != null) 'batch_id': batchId,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (totalCost != null) 'total_cost': totalCost,
      if (sellingPricePerUnit != null)
        'selling_price_per_unit': sellingPricePerUnit,
      if (totalRevenue != null) 'total_revenue': totalRevenue,
      if (profit != null) 'profit': profit,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reason != null) 'reason': reason,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? type,
    Value<int>? quantityUnits,
    Value<int?>? quantityPacks,
    Value<String?>? batchId,
    Value<double?>? costPerUnit,
    Value<double?>? totalCost,
    Value<double?>? sellingPricePerUnit,
    Value<double?>? totalRevenue,
    Value<double?>? profit,
    Value<String?>? paymentMethod,
    Value<String?>? reason,
    Value<String>? createdByUserId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantityUnits: quantityUnits ?? this.quantityUnits,
      quantityPacks: quantityPacks ?? this.quantityPacks,
      batchId: batchId ?? this.batchId,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      totalCost: totalCost ?? this.totalCost,
      sellingPricePerUnit: sellingPricePerUnit ?? this.sellingPricePerUnit,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      profit: profit ?? this.profit,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reason: reason ?? this.reason,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantityUnits.present) {
      map['quantity_units'] = Variable<int>(quantityUnits.value);
    }
    if (quantityPacks.present) {
      map['quantity_packs'] = Variable<int>(quantityPacks.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (sellingPricePerUnit.present) {
      map['selling_price_per_unit'] = Variable<double>(
        sellingPricePerUnit.value,
      );
    }
    if (totalRevenue.present) {
      map['total_revenue'] = Variable<double>(totalRevenue.value);
    }
    if (profit.present) {
      map['profit'] = Variable<double>(profit.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<String>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('type: $type, ')
          ..write('quantityUnits: $quantityUnits, ')
          ..write('quantityPacks: $quantityPacks, ')
          ..write('batchId: $batchId, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('totalCost: $totalCost, ')
          ..write('sellingPricePerUnit: $sellingPricePerUnit, ')
          ..write('totalRevenue: $totalRevenue, ')
          ..write('profit: $profit, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reason: $reason, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductionBatchesTableTable extends ProductionBatchesTable
    with TableInfo<$ProductionBatchesTableTable, ProductionBatchesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductionBatchesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityProducedMeta = const VerificationMeta(
    'quantityProduced',
  );
  @override
  late final GeneratedColumn<int> quantityProduced = GeneratedColumn<int>(
    'quantity_produced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientsCostMeta = const VerificationMeta(
    'ingredientsCost',
  );
  @override
  late final GeneratedColumn<double> ingredientsCost = GeneratedColumn<double>(
    'ingredients_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gasCostMeta = const VerificationMeta(
    'gasCost',
  );
  @override
  late final GeneratedColumn<double> gasCost = GeneratedColumn<double>(
    'gas_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilCostMeta = const VerificationMeta(
    'oilCost',
  );
  @override
  late final GeneratedColumn<double> oilCost = GeneratedColumn<double>(
    'oil_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _laborCostMeta = const VerificationMeta(
    'laborCost',
  );
  @override
  late final GeneratedColumn<double> laborCost = GeneratedColumn<double>(
    'labor_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transportCostMeta = const VerificationMeta(
    'transportCost',
  );
  @override
  late final GeneratedColumn<double> transportCost = GeneratedColumn<double>(
    'transport_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _packagingCostMeta = const VerificationMeta(
    'packagingCost',
  );
  @override
  late final GeneratedColumn<double> packagingCost = GeneratedColumn<double>(
    'packaging_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _otherCostMeta = const VerificationMeta(
    'otherCost',
  );
  @override
  late final GeneratedColumn<double> otherCost = GeneratedColumn<double>(
    'other_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _batchProfitMeta = const VerificationMeta(
    'batchProfit',
  );
  @override
  late final GeneratedColumn<double> batchProfit = GeneratedColumn<double>(
    'batch_profit',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    productId,
    quantityProduced,
    ingredientsCost,
    gasCost,
    oilCost,
    laborCost,
    transportCost,
    packagingCost,
    otherCost,
    totalCost,
    unitCost,
    batchProfit,
    createdAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'production_batches_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductionBatchesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_produced')) {
      context.handle(
        _quantityProducedMeta,
        quantityProduced.isAcceptableOrUnknown(
          data['quantity_produced']!,
          _quantityProducedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityProducedMeta);
    }
    if (data.containsKey('ingredients_cost')) {
      context.handle(
        _ingredientsCostMeta,
        ingredientsCost.isAcceptableOrUnknown(
          data['ingredients_cost']!,
          _ingredientsCostMeta,
        ),
      );
    }
    if (data.containsKey('gas_cost')) {
      context.handle(
        _gasCostMeta,
        gasCost.isAcceptableOrUnknown(data['gas_cost']!, _gasCostMeta),
      );
    }
    if (data.containsKey('oil_cost')) {
      context.handle(
        _oilCostMeta,
        oilCost.isAcceptableOrUnknown(data['oil_cost']!, _oilCostMeta),
      );
    }
    if (data.containsKey('labor_cost')) {
      context.handle(
        _laborCostMeta,
        laborCost.isAcceptableOrUnknown(data['labor_cost']!, _laborCostMeta),
      );
    }
    if (data.containsKey('transport_cost')) {
      context.handle(
        _transportCostMeta,
        transportCost.isAcceptableOrUnknown(
          data['transport_cost']!,
          _transportCostMeta,
        ),
      );
    }
    if (data.containsKey('packaging_cost')) {
      context.handle(
        _packagingCostMeta,
        packagingCost.isAcceptableOrUnknown(
          data['packaging_cost']!,
          _packagingCostMeta,
        ),
      );
    }
    if (data.containsKey('other_cost')) {
      context.handle(
        _otherCostMeta,
        otherCost.isAcceptableOrUnknown(data['other_cost']!, _otherCostMeta),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('batch_profit')) {
      context.handle(
        _batchProfitMeta,
        batchProfit.isAcceptableOrUnknown(
          data['batch_profit']!,
          _batchProfitMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  ProductionBatchesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductionBatchesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      quantityProduced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_produced'],
      )!,
      ingredientsCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ingredients_cost'],
      ),
      gasCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gas_cost'],
      ),
      oilCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}oil_cost'],
      ),
      laborCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}labor_cost'],
      ),
      transportCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transport_cost'],
      ),
      packagingCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}packaging_cost'],
      ),
      otherCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}other_cost'],
      ),
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      )!,
      batchProfit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}batch_profit'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ProductionBatchesTableTable createAlias(String alias) {
    return $ProductionBatchesTableTable(attachedDatabase, alias);
  }
}

class ProductionBatchesTableData extends DataClass
    implements Insertable<ProductionBatchesTableData> {
  final int id;
  final String productId;
  final int quantityProduced;
  final double? ingredientsCost;
  final double? gasCost;
  final double? oilCost;
  final double? laborCost;
  final double? transportCost;
  final double? packagingCost;
  final double? otherCost;
  final double totalCost;
  final double unitCost;
  final double? batchProfit;
  final DateTime createdAt;
  final String? notes;
  const ProductionBatchesTableData({
    required this.id,
    required this.productId,
    required this.quantityProduced,
    this.ingredientsCost,
    this.gasCost,
    this.oilCost,
    this.laborCost,
    this.transportCost,
    this.packagingCost,
    this.otherCost,
    required this.totalCost,
    required this.unitCost,
    this.batchProfit,
    required this.createdAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<String>(productId);
    map['quantity_produced'] = Variable<int>(quantityProduced);
    if (!nullToAbsent || ingredientsCost != null) {
      map['ingredients_cost'] = Variable<double>(ingredientsCost);
    }
    if (!nullToAbsent || gasCost != null) {
      map['gas_cost'] = Variable<double>(gasCost);
    }
    if (!nullToAbsent || oilCost != null) {
      map['oil_cost'] = Variable<double>(oilCost);
    }
    if (!nullToAbsent || laborCost != null) {
      map['labor_cost'] = Variable<double>(laborCost);
    }
    if (!nullToAbsent || transportCost != null) {
      map['transport_cost'] = Variable<double>(transportCost);
    }
    if (!nullToAbsent || packagingCost != null) {
      map['packaging_cost'] = Variable<double>(packagingCost);
    }
    if (!nullToAbsent || otherCost != null) {
      map['other_cost'] = Variable<double>(otherCost);
    }
    map['total_cost'] = Variable<double>(totalCost);
    map['unit_cost'] = Variable<double>(unitCost);
    if (!nullToAbsent || batchProfit != null) {
      map['batch_profit'] = Variable<double>(batchProfit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ProductionBatchesTableCompanion toCompanion(bool nullToAbsent) {
    return ProductionBatchesTableCompanion(
      id: Value(id),
      productId: Value(productId),
      quantityProduced: Value(quantityProduced),
      ingredientsCost: ingredientsCost == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientsCost),
      gasCost: gasCost == null && nullToAbsent
          ? const Value.absent()
          : Value(gasCost),
      oilCost: oilCost == null && nullToAbsent
          ? const Value.absent()
          : Value(oilCost),
      laborCost: laborCost == null && nullToAbsent
          ? const Value.absent()
          : Value(laborCost),
      transportCost: transportCost == null && nullToAbsent
          ? const Value.absent()
          : Value(transportCost),
      packagingCost: packagingCost == null && nullToAbsent
          ? const Value.absent()
          : Value(packagingCost),
      otherCost: otherCost == null && nullToAbsent
          ? const Value.absent()
          : Value(otherCost),
      totalCost: Value(totalCost),
      unitCost: Value(unitCost),
      batchProfit: batchProfit == null && nullToAbsent
          ? const Value.absent()
          : Value(batchProfit),
      createdAt: Value(createdAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ProductionBatchesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductionBatchesTableData(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      quantityProduced: serializer.fromJson<int>(json['quantityProduced']),
      ingredientsCost: serializer.fromJson<double?>(json['ingredientsCost']),
      gasCost: serializer.fromJson<double?>(json['gasCost']),
      oilCost: serializer.fromJson<double?>(json['oilCost']),
      laborCost: serializer.fromJson<double?>(json['laborCost']),
      transportCost: serializer.fromJson<double?>(json['transportCost']),
      packagingCost: serializer.fromJson<double?>(json['packagingCost']),
      otherCost: serializer.fromJson<double?>(json['otherCost']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      batchProfit: serializer.fromJson<double?>(json['batchProfit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<String>(productId),
      'quantityProduced': serializer.toJson<int>(quantityProduced),
      'ingredientsCost': serializer.toJson<double?>(ingredientsCost),
      'gasCost': serializer.toJson<double?>(gasCost),
      'oilCost': serializer.toJson<double?>(oilCost),
      'laborCost': serializer.toJson<double?>(laborCost),
      'transportCost': serializer.toJson<double?>(transportCost),
      'packagingCost': serializer.toJson<double?>(packagingCost),
      'otherCost': serializer.toJson<double?>(otherCost),
      'totalCost': serializer.toJson<double>(totalCost),
      'unitCost': serializer.toJson<double>(unitCost),
      'batchProfit': serializer.toJson<double?>(batchProfit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ProductionBatchesTableData copyWith({
    int? id,
    String? productId,
    int? quantityProduced,
    Value<double?> ingredientsCost = const Value.absent(),
    Value<double?> gasCost = const Value.absent(),
    Value<double?> oilCost = const Value.absent(),
    Value<double?> laborCost = const Value.absent(),
    Value<double?> transportCost = const Value.absent(),
    Value<double?> packagingCost = const Value.absent(),
    Value<double?> otherCost = const Value.absent(),
    double? totalCost,
    double? unitCost,
    Value<double?> batchProfit = const Value.absent(),
    DateTime? createdAt,
    Value<String?> notes = const Value.absent(),
  }) => ProductionBatchesTableData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    quantityProduced: quantityProduced ?? this.quantityProduced,
    ingredientsCost: ingredientsCost.present
        ? ingredientsCost.value
        : this.ingredientsCost,
    gasCost: gasCost.present ? gasCost.value : this.gasCost,
    oilCost: oilCost.present ? oilCost.value : this.oilCost,
    laborCost: laborCost.present ? laborCost.value : this.laborCost,
    transportCost: transportCost.present
        ? transportCost.value
        : this.transportCost,
    packagingCost: packagingCost.present
        ? packagingCost.value
        : this.packagingCost,
    otherCost: otherCost.present ? otherCost.value : this.otherCost,
    totalCost: totalCost ?? this.totalCost,
    unitCost: unitCost ?? this.unitCost,
    batchProfit: batchProfit.present ? batchProfit.value : this.batchProfit,
    createdAt: createdAt ?? this.createdAt,
    notes: notes.present ? notes.value : this.notes,
  );
  ProductionBatchesTableData copyWithCompanion(
    ProductionBatchesTableCompanion data,
  ) {
    return ProductionBatchesTableData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityProduced: data.quantityProduced.present
          ? data.quantityProduced.value
          : this.quantityProduced,
      ingredientsCost: data.ingredientsCost.present
          ? data.ingredientsCost.value
          : this.ingredientsCost,
      gasCost: data.gasCost.present ? data.gasCost.value : this.gasCost,
      oilCost: data.oilCost.present ? data.oilCost.value : this.oilCost,
      laborCost: data.laborCost.present ? data.laborCost.value : this.laborCost,
      transportCost: data.transportCost.present
          ? data.transportCost.value
          : this.transportCost,
      packagingCost: data.packagingCost.present
          ? data.packagingCost.value
          : this.packagingCost,
      otherCost: data.otherCost.present ? data.otherCost.value : this.otherCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      batchProfit: data.batchProfit.present
          ? data.batchProfit.value
          : this.batchProfit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductionBatchesTableData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityProduced: $quantityProduced, ')
          ..write('ingredientsCost: $ingredientsCost, ')
          ..write('gasCost: $gasCost, ')
          ..write('oilCost: $oilCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('transportCost: $transportCost, ')
          ..write('packagingCost: $packagingCost, ')
          ..write('otherCost: $otherCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('unitCost: $unitCost, ')
          ..write('batchProfit: $batchProfit, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    quantityProduced,
    ingredientsCost,
    gasCost,
    oilCost,
    laborCost,
    transportCost,
    packagingCost,
    otherCost,
    totalCost,
    unitCost,
    batchProfit,
    createdAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductionBatchesTableData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantityProduced == this.quantityProduced &&
          other.ingredientsCost == this.ingredientsCost &&
          other.gasCost == this.gasCost &&
          other.oilCost == this.oilCost &&
          other.laborCost == this.laborCost &&
          other.transportCost == this.transportCost &&
          other.packagingCost == this.packagingCost &&
          other.otherCost == this.otherCost &&
          other.totalCost == this.totalCost &&
          other.unitCost == this.unitCost &&
          other.batchProfit == this.batchProfit &&
          other.createdAt == this.createdAt &&
          other.notes == this.notes);
}

class ProductionBatchesTableCompanion
    extends UpdateCompanion<ProductionBatchesTableData> {
  final Value<int> id;
  final Value<String> productId;
  final Value<int> quantityProduced;
  final Value<double?> ingredientsCost;
  final Value<double?> gasCost;
  final Value<double?> oilCost;
  final Value<double?> laborCost;
  final Value<double?> transportCost;
  final Value<double?> packagingCost;
  final Value<double?> otherCost;
  final Value<double> totalCost;
  final Value<double> unitCost;
  final Value<double?> batchProfit;
  final Value<DateTime> createdAt;
  final Value<String?> notes;
  const ProductionBatchesTableCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantityProduced = const Value.absent(),
    this.ingredientsCost = const Value.absent(),
    this.gasCost = const Value.absent(),
    this.oilCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.transportCost = const Value.absent(),
    this.packagingCost = const Value.absent(),
    this.otherCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.batchProfit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ProductionBatchesTableCompanion.insert({
    this.id = const Value.absent(),
    required String productId,
    required int quantityProduced,
    this.ingredientsCost = const Value.absent(),
    this.gasCost = const Value.absent(),
    this.oilCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.transportCost = const Value.absent(),
    this.packagingCost = const Value.absent(),
    this.otherCost = const Value.absent(),
    required double totalCost,
    required double unitCost,
    this.batchProfit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
  }) : productId = Value(productId),
       quantityProduced = Value(quantityProduced),
       totalCost = Value(totalCost),
       unitCost = Value(unitCost);
  static Insertable<ProductionBatchesTableData> custom({
    Expression<int>? id,
    Expression<String>? productId,
    Expression<int>? quantityProduced,
    Expression<double>? ingredientsCost,
    Expression<double>? gasCost,
    Expression<double>? oilCost,
    Expression<double>? laborCost,
    Expression<double>? transportCost,
    Expression<double>? packagingCost,
    Expression<double>? otherCost,
    Expression<double>? totalCost,
    Expression<double>? unitCost,
    Expression<double>? batchProfit,
    Expression<DateTime>? createdAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantityProduced != null) 'quantity_produced': quantityProduced,
      if (ingredientsCost != null) 'ingredients_cost': ingredientsCost,
      if (gasCost != null) 'gas_cost': gasCost,
      if (oilCost != null) 'oil_cost': oilCost,
      if (laborCost != null) 'labor_cost': laborCost,
      if (transportCost != null) 'transport_cost': transportCost,
      if (packagingCost != null) 'packaging_cost': packagingCost,
      if (otherCost != null) 'other_cost': otherCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (unitCost != null) 'unit_cost': unitCost,
      if (batchProfit != null) 'batch_profit': batchProfit,
      if (createdAt != null) 'created_at': createdAt,
      if (notes != null) 'notes': notes,
    });
  }

  ProductionBatchesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? productId,
    Value<int>? quantityProduced,
    Value<double?>? ingredientsCost,
    Value<double?>? gasCost,
    Value<double?>? oilCost,
    Value<double?>? laborCost,
    Value<double?>? transportCost,
    Value<double?>? packagingCost,
    Value<double?>? otherCost,
    Value<double>? totalCost,
    Value<double>? unitCost,
    Value<double?>? batchProfit,
    Value<DateTime>? createdAt,
    Value<String?>? notes,
  }) {
    return ProductionBatchesTableCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantityProduced: quantityProduced ?? this.quantityProduced,
      ingredientsCost: ingredientsCost ?? this.ingredientsCost,
      gasCost: gasCost ?? this.gasCost,
      oilCost: oilCost ?? this.oilCost,
      laborCost: laborCost ?? this.laborCost,
      transportCost: transportCost ?? this.transportCost,
      packagingCost: packagingCost ?? this.packagingCost,
      otherCost: otherCost ?? this.otherCost,
      totalCost: totalCost ?? this.totalCost,
      unitCost: unitCost ?? this.unitCost,
      batchProfit: batchProfit ?? this.batchProfit,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (quantityProduced.present) {
      map['quantity_produced'] = Variable<int>(quantityProduced.value);
    }
    if (ingredientsCost.present) {
      map['ingredients_cost'] = Variable<double>(ingredientsCost.value);
    }
    if (gasCost.present) {
      map['gas_cost'] = Variable<double>(gasCost.value);
    }
    if (oilCost.present) {
      map['oil_cost'] = Variable<double>(oilCost.value);
    }
    if (laborCost.present) {
      map['labor_cost'] = Variable<double>(laborCost.value);
    }
    if (transportCost.present) {
      map['transport_cost'] = Variable<double>(transportCost.value);
    }
    if (packagingCost.present) {
      map['packaging_cost'] = Variable<double>(packagingCost.value);
    }
    if (otherCost.present) {
      map['other_cost'] = Variable<double>(otherCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (batchProfit.present) {
      map['batch_profit'] = Variable<double>(batchProfit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductionBatchesTableCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityProduced: $quantityProduced, ')
          ..write('ingredientsCost: $ingredientsCost, ')
          ..write('gasCost: $gasCost, ')
          ..write('oilCost: $oilCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('transportCost: $transportCost, ')
          ..write('packagingCost: $packagingCost, ')
          ..write('otherCost: $otherCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('unitCost: $unitCost, ')
          ..write('batchProfit: $batchProfit, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncQueueTableTable extends PendingSyncQueueTable
    with TableInfo<$PendingSyncQueueTableTable, PendingSyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _retriesMeta = const VerificationMeta(
    'retries',
  );
  @override
  late final GeneratedColumn<int> retries = GeneratedColumn<int>(
    'retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastRetryAtMeta = const VerificationMeta(
    'lastRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRetryAt = GeneratedColumn<DateTime>(
    'last_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    payload,
    status,
    retries,
    errorMessage,
    createdAt,
    lastRetryAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retries')) {
      context.handle(
        _retriesMeta,
        retries.isAcceptableOrUnknown(data['retries']!, _retriesMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_retry_at')) {
      context.handle(
        _lastRetryAtMeta,
        lastRetryAt.isAcceptableOrUnknown(
          data['last_retry_at']!,
          _lastRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncQueueTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncQueueTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retries'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_retry_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $PendingSyncQueueTableTable createAlias(String alias) {
    return $PendingSyncQueueTableTable(attachedDatabase, alias);
  }
}

class PendingSyncQueueTableData extends DataClass
    implements Insertable<PendingSyncQueueTableData> {
  final String id;
  final String operationType;
  final String payload;
  final String status;
  final int retries;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? lastRetryAt;
  final DateTime? syncedAt;
  const PendingSyncQueueTableData({
    required this.id,
    required this.operationType,
    required this.payload,
    required this.status,
    required this.retries,
    this.errorMessage,
    required this.createdAt,
    this.lastRetryAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retries'] = Variable<int>(retries);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastRetryAt != null) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  PendingSyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncQueueTableCompanion(
      id: Value(id),
      operationType: Value(operationType),
      payload: Value(payload),
      status: Value(status),
      retries: Value(retries),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      lastRetryAt: lastRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRetryAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory PendingSyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retries: serializer.fromJson<int>(json['retries']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastRetryAt: serializer.fromJson<DateTime?>(json['lastRetryAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationType': serializer.toJson<String>(operationType),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retries': serializer.toJson<int>(retries),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastRetryAt': serializer.toJson<DateTime?>(lastRetryAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  PendingSyncQueueTableData copyWith({
    String? id,
    String? operationType,
    String? payload,
    String? status,
    int? retries,
    Value<String?> errorMessage = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> lastRetryAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => PendingSyncQueueTableData(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retries: retries ?? this.retries,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    lastRetryAt: lastRetryAt.present ? lastRetryAt.value : this.lastRetryAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  PendingSyncQueueTableData copyWithCompanion(
    PendingSyncQueueTableCompanion data,
  ) {
    return PendingSyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retries: data.retries.present ? data.retries.value : this.retries,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastRetryAt: data.lastRetryAt.present
          ? data.lastRetryAt.value
          : this.lastRetryAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncQueueTableData(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retries: $retries, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    payload,
    status,
    retries,
    errorMessage,
    createdAt,
    lastRetryAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncQueueTableData &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retries == this.retries &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.lastRetryAt == this.lastRetryAt &&
          other.syncedAt == this.syncedAt);
}

class PendingSyncQueueTableCompanion
    extends UpdateCompanion<PendingSyncQueueTableData> {
  final Value<String> id;
  final Value<String> operationType;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retries;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastRetryAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const PendingSyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retries = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingSyncQueueTableCompanion.insert({
    required String id,
    required String operationType,
    required String payload,
    this.status = const Value.absent(),
    this.retries = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationType = Value(operationType),
       payload = Value(payload);
  static Insertable<PendingSyncQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? operationType,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retries,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastRetryAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retries != null) 'retries': retries,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (lastRetryAt != null) 'last_retry_at': lastRetryAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingSyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? operationType,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? retries,
    Value<String?>? errorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastRetryAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return PendingSyncQueueTableCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retries: retries ?? this.retries,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retries.present) {
      map['retries'] = Variable<int>(retries.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastRetryAt.present) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retries: $retries, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $ProductPriceHistoryTableTable productPriceHistoryTable =
      $ProductPriceHistoryTableTable(this);
  late final $StockMovementsTableTable stockMovementsTable =
      $StockMovementsTableTable(this);
  late final $ProductionBatchesTableTable productionBatchesTable =
      $ProductionBatchesTableTable(this);
  late final $PendingSyncQueueTableTable pendingSyncQueueTable =
      $PendingSyncQueueTableTable(this);
  late final UsersDao usersDao = UsersDao(this as AppDatabase);
  late final ProductionBatchesDao productionBatchesDao = ProductionBatchesDao(
    this as AppDatabase,
  );
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final StockMovementsDao stockMovementsDao = StockMovementsDao(
    this as AppDatabase,
  );
  late final PendingSyncQueueDao pendingSyncQueueDao = PendingSyncQueueDao(
    this as AppDatabase,
  );
  late final ProductPriceHistoryDao productPriceHistoryDao =
      ProductPriceHistoryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    usersTable,
    productsTable,
    productPriceHistoryTable,
    stockMovementsTable,
    productionBatchesTable,
    pendingSyncQueueTable,
  ];
}

typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      required String id,
      required String name,
      required String phone,
      required String email,
      required String role,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String> email,
      Value<String> role,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UsersTableData,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (
            UsersTableData,
            BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
          ),
          UsersTableData,
          PrefetchHooks Function()
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                required String email,
                required String role,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                role: role,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UsersTableData,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (
        UsersTableData,
        BaseReferences<_$AppDatabase, $UsersTableTable, UsersTableData>,
      ),
      UsersTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductsTableTableCreateCompanionBuilder =
    ProductsTableCompanion Function({
      required String id,
      required String name,
      required String category,
      Value<String?> subcategory,
      Value<String?> imageUrl,
      required bool isProduced,
      required double currentSellingPrice,
      Value<double?> currentCostPrice,
      Value<int> currentStockQty,
      Value<int?> unitsPerPack,
      Value<String> status,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$ProductsTableTableUpdateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<String?> subcategory,
      Value<String?> imageUrl,
      Value<bool> isProduced,
      Value<double> currentSellingPrice,
      Value<double?> currentCostPrice,
      Value<int> currentStockQty,
      Value<int?> unitsPerPack,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProduced => $composableBuilder(
    column: $table.isProduced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentSellingPrice => $composableBuilder(
    column: $table.currentSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentCostPrice => $composableBuilder(
    column: $table.currentCostPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStockQty => $composableBuilder(
    column: $table.currentStockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
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
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProduced => $composableBuilder(
    column: $table.isProduced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentSellingPrice => $composableBuilder(
    column: $table.currentSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentCostPrice => $composableBuilder(
    column: $table.currentCostPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStockQty => $composableBuilder(
    column: $table.currentStockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
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

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isProduced => $composableBuilder(
    column: $table.isProduced,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentSellingPrice => $composableBuilder(
    column: $table.currentSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentCostPrice => $composableBuilder(
    column: $table.currentCostPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStockQty => $composableBuilder(
    column: $table.currentStockQty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitsPerPack => $composableBuilder(
    column: $table.unitsPerPack,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTableTable,
          ProductsTableData,
          $$ProductsTableTableFilterComposer,
          $$ProductsTableTableOrderingComposer,
          $$ProductsTableTableAnnotationComposer,
          $$ProductsTableTableCreateCompanionBuilder,
          $$ProductsTableTableUpdateCompanionBuilder,
          (
            ProductsTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductsTableTable,
              ProductsTableData
            >,
          ),
          ProductsTableData,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isProduced = const Value.absent(),
                Value<double> currentSellingPrice = const Value.absent(),
                Value<double?> currentCostPrice = const Value.absent(),
                Value<int> currentStockQty = const Value.absent(),
                Value<int?> unitsPerPack = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                imageUrl: imageUrl,
                isProduced: isProduced,
                currentSellingPrice: currentSellingPrice,
                currentCostPrice: currentCostPrice,
                currentStockQty: currentStockQty,
                unitsPerPack: unitsPerPack,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                Value<String?> subcategory = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required bool isProduced,
                required double currentSellingPrice,
                Value<double?> currentCostPrice = const Value.absent(),
                Value<int> currentStockQty = const Value.absent(),
                Value<int?> unitsPerPack = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsTableCompanion.insert(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                imageUrl: imageUrl,
                isProduced: isProduced,
                currentSellingPrice: currentSellingPrice,
                currentCostPrice: currentCostPrice,
                currentStockQty: currentStockQty,
                unitsPerPack: unitsPerPack,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTableTable,
      ProductsTableData,
      $$ProductsTableTableFilterComposer,
      $$ProductsTableTableOrderingComposer,
      $$ProductsTableTableAnnotationComposer,
      $$ProductsTableTableCreateCompanionBuilder,
      $$ProductsTableTableUpdateCompanionBuilder,
      (
        ProductsTableData,
        BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData>,
      ),
      ProductsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductPriceHistoryTableTableCreateCompanionBuilder =
    ProductPriceHistoryTableCompanion Function({
      required String id,
      required String productId,
      Value<double?> oldSellingPrice,
      Value<double?> newSellingPrice,
      Value<double?> oldCostPrice,
      Value<double?> newCostPrice,
      required String changeType,
      Value<String?> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProductPriceHistoryTableTableUpdateCompanionBuilder =
    ProductPriceHistoryTableCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<double?> oldSellingPrice,
      Value<double?> newSellingPrice,
      Value<double?> oldCostPrice,
      Value<double?> newCostPrice,
      Value<String> changeType,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProductPriceHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductPriceHistoryTableTable> {
  $$ProductPriceHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oldSellingPrice => $composableBuilder(
    column: $table.oldSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newSellingPrice => $composableBuilder(
    column: $table.newSellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oldCostPrice => $composableBuilder(
    column: $table.oldCostPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newCostPrice => $composableBuilder(
    column: $table.newCostPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductPriceHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductPriceHistoryTableTable> {
  $$ProductPriceHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oldSellingPrice => $composableBuilder(
    column: $table.oldSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newSellingPrice => $composableBuilder(
    column: $table.newSellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oldCostPrice => $composableBuilder(
    column: $table.oldCostPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newCostPrice => $composableBuilder(
    column: $table.newCostPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductPriceHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductPriceHistoryTableTable> {
  $$ProductPriceHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<double> get oldSellingPrice => $composableBuilder(
    column: $table.oldSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newSellingPrice => $composableBuilder(
    column: $table.newSellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get oldCostPrice => $composableBuilder(
    column: $table.oldCostPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newCostPrice => $composableBuilder(
    column: $table.newCostPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductPriceHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductPriceHistoryTableTable,
          ProductPriceHistoryTableData,
          $$ProductPriceHistoryTableTableFilterComposer,
          $$ProductPriceHistoryTableTableOrderingComposer,
          $$ProductPriceHistoryTableTableAnnotationComposer,
          $$ProductPriceHistoryTableTableCreateCompanionBuilder,
          $$ProductPriceHistoryTableTableUpdateCompanionBuilder,
          (
            ProductPriceHistoryTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductPriceHistoryTableTable,
              ProductPriceHistoryTableData
            >,
          ),
          ProductPriceHistoryTableData,
          PrefetchHooks Function()
        > {
  $$ProductPriceHistoryTableTableTableManager(
    _$AppDatabase db,
    $ProductPriceHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductPriceHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductPriceHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductPriceHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<double?> oldSellingPrice = const Value.absent(),
                Value<double?> newSellingPrice = const Value.absent(),
                Value<double?> oldCostPrice = const Value.absent(),
                Value<double?> newCostPrice = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductPriceHistoryTableCompanion(
                id: id,
                productId: productId,
                oldSellingPrice: oldSellingPrice,
                newSellingPrice: newSellingPrice,
                oldCostPrice: oldCostPrice,
                newCostPrice: newCostPrice,
                changeType: changeType,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                Value<double?> oldSellingPrice = const Value.absent(),
                Value<double?> newSellingPrice = const Value.absent(),
                Value<double?> oldCostPrice = const Value.absent(),
                Value<double?> newCostPrice = const Value.absent(),
                required String changeType,
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductPriceHistoryTableCompanion.insert(
                id: id,
                productId: productId,
                oldSellingPrice: oldSellingPrice,
                newSellingPrice: newSellingPrice,
                oldCostPrice: oldCostPrice,
                newCostPrice: newCostPrice,
                changeType: changeType,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductPriceHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductPriceHistoryTableTable,
      ProductPriceHistoryTableData,
      $$ProductPriceHistoryTableTableFilterComposer,
      $$ProductPriceHistoryTableTableOrderingComposer,
      $$ProductPriceHistoryTableTableAnnotationComposer,
      $$ProductPriceHistoryTableTableCreateCompanionBuilder,
      $$ProductPriceHistoryTableTableUpdateCompanionBuilder,
      (
        ProductPriceHistoryTableData,
        BaseReferences<
          _$AppDatabase,
          $ProductPriceHistoryTableTable,
          ProductPriceHistoryTableData
        >,
      ),
      ProductPriceHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$StockMovementsTableTableCreateCompanionBuilder =
    StockMovementsTableCompanion Function({
      required String id,
      required String productId,
      required String type,
      required int quantityUnits,
      Value<int?> quantityPacks,
      Value<String?> batchId,
      Value<double?> costPerUnit,
      Value<double?> totalCost,
      Value<double?> sellingPricePerUnit,
      Value<double?> totalRevenue,
      Value<double?> profit,
      Value<String?> paymentMethod,
      Value<String?> reason,
      required String createdByUserId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableTableUpdateCompanionBuilder =
    StockMovementsTableCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> type,
      Value<int> quantityUnits,
      Value<int?> quantityPacks,
      Value<String?> batchId,
      Value<double?> costPerUnit,
      Value<double?> totalCost,
      Value<double?> sellingPricePerUnit,
      Value<double?> totalRevenue,
      Value<double?> profit,
      Value<String?> paymentMethod,
      Value<String?> reason,
      Value<String> createdByUserId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$StockMovementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTableTable> {
  $$StockMovementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityUnits => $composableBuilder(
    column: $table.quantityUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityPacks => $composableBuilder(
    column: $table.quantityPacks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPricePerUnit => $composableBuilder(
    column: $table.sellingPricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockMovementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTableTable> {
  $$StockMovementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityUnits => $composableBuilder(
    column: $table.quantityUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityPacks => $composableBuilder(
    column: $table.quantityPacks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPricePerUnit => $composableBuilder(
    column: $table.sellingPricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profit => $composableBuilder(
    column: $table.profit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockMovementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTableTable> {
  $$StockMovementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantityUnits => $composableBuilder(
    column: $table.quantityUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityPacks => $composableBuilder(
    column: $table.quantityPacks,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
    column: $table.costPerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<double> get sellingPricePerUnit => $composableBuilder(
    column: $table.sellingPricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalRevenue => $composableBuilder(
    column: $table.totalRevenue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockMovementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTableTable,
          StockMovementsTableData,
          $$StockMovementsTableTableFilterComposer,
          $$StockMovementsTableTableOrderingComposer,
          $$StockMovementsTableTableAnnotationComposer,
          $$StockMovementsTableTableCreateCompanionBuilder,
          $$StockMovementsTableTableUpdateCompanionBuilder,
          (
            StockMovementsTableData,
            BaseReferences<
              _$AppDatabase,
              $StockMovementsTableTable,
              StockMovementsTableData
            >,
          ),
          StockMovementsTableData,
          PrefetchHooks Function()
        > {
  $$StockMovementsTableTableTableManager(
    _$AppDatabase db,
    $StockMovementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StockMovementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> quantityUnits = const Value.absent(),
                Value<int?> quantityPacks = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<double?> totalCost = const Value.absent(),
                Value<double?> sellingPricePerUnit = const Value.absent(),
                Value<double?> totalRevenue = const Value.absent(),
                Value<double?> profit = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsTableCompanion(
                id: id,
                productId: productId,
                type: type,
                quantityUnits: quantityUnits,
                quantityPacks: quantityPacks,
                batchId: batchId,
                costPerUnit: costPerUnit,
                totalCost: totalCost,
                sellingPricePerUnit: sellingPricePerUnit,
                totalRevenue: totalRevenue,
                profit: profit,
                paymentMethod: paymentMethod,
                reason: reason,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String type,
                required int quantityUnits,
                Value<int?> quantityPacks = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<double?> costPerUnit = const Value.absent(),
                Value<double?> totalCost = const Value.absent(),
                Value<double?> sellingPricePerUnit = const Value.absent(),
                Value<double?> totalRevenue = const Value.absent(),
                Value<double?> profit = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required String createdByUserId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsTableCompanion.insert(
                id: id,
                productId: productId,
                type: type,
                quantityUnits: quantityUnits,
                quantityPacks: quantityPacks,
                batchId: batchId,
                costPerUnit: costPerUnit,
                totalCost: totalCost,
                sellingPricePerUnit: sellingPricePerUnit,
                totalRevenue: totalRevenue,
                profit: profit,
                paymentMethod: paymentMethod,
                reason: reason,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockMovementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTableTable,
      StockMovementsTableData,
      $$StockMovementsTableTableFilterComposer,
      $$StockMovementsTableTableOrderingComposer,
      $$StockMovementsTableTableAnnotationComposer,
      $$StockMovementsTableTableCreateCompanionBuilder,
      $$StockMovementsTableTableUpdateCompanionBuilder,
      (
        StockMovementsTableData,
        BaseReferences<
          _$AppDatabase,
          $StockMovementsTableTable,
          StockMovementsTableData
        >,
      ),
      StockMovementsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProductionBatchesTableTableCreateCompanionBuilder =
    ProductionBatchesTableCompanion Function({
      Value<int> id,
      required String productId,
      required int quantityProduced,
      Value<double?> ingredientsCost,
      Value<double?> gasCost,
      Value<double?> oilCost,
      Value<double?> laborCost,
      Value<double?> transportCost,
      Value<double?> packagingCost,
      Value<double?> otherCost,
      required double totalCost,
      required double unitCost,
      Value<double?> batchProfit,
      Value<DateTime> createdAt,
      Value<String?> notes,
    });
typedef $$ProductionBatchesTableTableUpdateCompanionBuilder =
    ProductionBatchesTableCompanion Function({
      Value<int> id,
      Value<String> productId,
      Value<int> quantityProduced,
      Value<double?> ingredientsCost,
      Value<double?> gasCost,
      Value<double?> oilCost,
      Value<double?> laborCost,
      Value<double?> transportCost,
      Value<double?> packagingCost,
      Value<double?> otherCost,
      Value<double> totalCost,
      Value<double> unitCost,
      Value<double?> batchProfit,
      Value<DateTime> createdAt,
      Value<String?> notes,
    });

class $$ProductionBatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductionBatchesTableTable> {
  $$ProductionBatchesTableTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityProduced => $composableBuilder(
    column: $table.quantityProduced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ingredientsCost => $composableBuilder(
    column: $table.ingredientsCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gasCost => $composableBuilder(
    column: $table.gasCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get oilCost => $composableBuilder(
    column: $table.oilCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transportCost => $composableBuilder(
    column: $table.transportCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get packagingCost => $composableBuilder(
    column: $table.packagingCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get otherCost => $composableBuilder(
    column: $table.otherCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batchProfit => $composableBuilder(
    column: $table.batchProfit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductionBatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductionBatchesTableTable> {
  $$ProductionBatchesTableTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityProduced => $composableBuilder(
    column: $table.quantityProduced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ingredientsCost => $composableBuilder(
    column: $table.ingredientsCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gasCost => $composableBuilder(
    column: $table.gasCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get oilCost => $composableBuilder(
    column: $table.oilCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transportCost => $composableBuilder(
    column: $table.transportCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get packagingCost => $composableBuilder(
    column: $table.packagingCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get otherCost => $composableBuilder(
    column: $table.otherCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batchProfit => $composableBuilder(
    column: $table.batchProfit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductionBatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductionBatchesTableTable> {
  $$ProductionBatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantityProduced => $composableBuilder(
    column: $table.quantityProduced,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ingredientsCost => $composableBuilder(
    column: $table.ingredientsCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gasCost =>
      $composableBuilder(column: $table.gasCost, builder: (column) => column);

  GeneratedColumn<double> get oilCost =>
      $composableBuilder(column: $table.oilCost, builder: (column) => column);

  GeneratedColumn<double> get laborCost =>
      $composableBuilder(column: $table.laborCost, builder: (column) => column);

  GeneratedColumn<double> get transportCost => $composableBuilder(
    column: $table.transportCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get packagingCost => $composableBuilder(
    column: $table.packagingCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get otherCost =>
      $composableBuilder(column: $table.otherCost, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get batchProfit => $composableBuilder(
    column: $table.batchProfit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ProductionBatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductionBatchesTableTable,
          ProductionBatchesTableData,
          $$ProductionBatchesTableTableFilterComposer,
          $$ProductionBatchesTableTableOrderingComposer,
          $$ProductionBatchesTableTableAnnotationComposer,
          $$ProductionBatchesTableTableCreateCompanionBuilder,
          $$ProductionBatchesTableTableUpdateCompanionBuilder,
          (
            ProductionBatchesTableData,
            BaseReferences<
              _$AppDatabase,
              $ProductionBatchesTableTable,
              ProductionBatchesTableData
            >,
          ),
          ProductionBatchesTableData,
          PrefetchHooks Function()
        > {
  $$ProductionBatchesTableTableTableManager(
    _$AppDatabase db,
    $ProductionBatchesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductionBatchesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProductionBatchesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductionBatchesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> quantityProduced = const Value.absent(),
                Value<double?> ingredientsCost = const Value.absent(),
                Value<double?> gasCost = const Value.absent(),
                Value<double?> oilCost = const Value.absent(),
                Value<double?> laborCost = const Value.absent(),
                Value<double?> transportCost = const Value.absent(),
                Value<double?> packagingCost = const Value.absent(),
                Value<double?> otherCost = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<double> unitCost = const Value.absent(),
                Value<double?> batchProfit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ProductionBatchesTableCompanion(
                id: id,
                productId: productId,
                quantityProduced: quantityProduced,
                ingredientsCost: ingredientsCost,
                gasCost: gasCost,
                oilCost: oilCost,
                laborCost: laborCost,
                transportCost: transportCost,
                packagingCost: packagingCost,
                otherCost: otherCost,
                totalCost: totalCost,
                unitCost: unitCost,
                batchProfit: batchProfit,
                createdAt: createdAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String productId,
                required int quantityProduced,
                Value<double?> ingredientsCost = const Value.absent(),
                Value<double?> gasCost = const Value.absent(),
                Value<double?> oilCost = const Value.absent(),
                Value<double?> laborCost = const Value.absent(),
                Value<double?> transportCost = const Value.absent(),
                Value<double?> packagingCost = const Value.absent(),
                Value<double?> otherCost = const Value.absent(),
                required double totalCost,
                required double unitCost,
                Value<double?> batchProfit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ProductionBatchesTableCompanion.insert(
                id: id,
                productId: productId,
                quantityProduced: quantityProduced,
                ingredientsCost: ingredientsCost,
                gasCost: gasCost,
                oilCost: oilCost,
                laborCost: laborCost,
                transportCost: transportCost,
                packagingCost: packagingCost,
                otherCost: otherCost,
                totalCost: totalCost,
                unitCost: unitCost,
                batchProfit: batchProfit,
                createdAt: createdAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductionBatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductionBatchesTableTable,
      ProductionBatchesTableData,
      $$ProductionBatchesTableTableFilterComposer,
      $$ProductionBatchesTableTableOrderingComposer,
      $$ProductionBatchesTableTableAnnotationComposer,
      $$ProductionBatchesTableTableCreateCompanionBuilder,
      $$ProductionBatchesTableTableUpdateCompanionBuilder,
      (
        ProductionBatchesTableData,
        BaseReferences<
          _$AppDatabase,
          $ProductionBatchesTableTable,
          ProductionBatchesTableData
        >,
      ),
      ProductionBatchesTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingSyncQueueTableTableCreateCompanionBuilder =
    PendingSyncQueueTableCompanion Function({
      required String id,
      required String operationType,
      required String payload,
      Value<String> status,
      Value<int> retries,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime?> lastRetryAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$PendingSyncQueueTableTableUpdateCompanionBuilder =
    PendingSyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> operationType,
      Value<String> payload,
      Value<String> status,
      Value<int> retries,
      Value<String?> errorMessage,
      Value<DateTime> createdAt,
      Value<DateTime?> lastRetryAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$PendingSyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncQueueTableTable> {
  $$PendingSyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncQueueTableTable> {
  $$PendingSyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retries => $composableBuilder(
    column: $table.retries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncQueueTableTable> {
  $$PendingSyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retries =>
      $composableBuilder(column: $table.retries, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$PendingSyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSyncQueueTableTable,
          PendingSyncQueueTableData,
          $$PendingSyncQueueTableTableFilterComposer,
          $$PendingSyncQueueTableTableOrderingComposer,
          $$PendingSyncQueueTableTableAnnotationComposer,
          $$PendingSyncQueueTableTableCreateCompanionBuilder,
          $$PendingSyncQueueTableTableUpdateCompanionBuilder,
          (
            PendingSyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingSyncQueueTableTable,
              PendingSyncQueueTableData
            >,
          ),
          PendingSyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$PendingSyncQueueTableTableTableManager(
    _$AppDatabase db,
    $PendingSyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncQueueTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingSyncQueueTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingSyncQueueTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastRetryAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingSyncQueueTableCompanion(
                id: id,
                operationType: operationType,
                payload: payload,
                status: status,
                retries: retries,
                errorMessage: errorMessage,
                createdAt: createdAt,
                lastRetryAt: lastRetryAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationType,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> retries = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastRetryAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingSyncQueueTableCompanion.insert(
                id: id,
                operationType: operationType,
                payload: payload,
                status: status,
                retries: retries,
                errorMessage: errorMessage,
                createdAt: createdAt,
                lastRetryAt: lastRetryAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSyncQueueTableTable,
      PendingSyncQueueTableData,
      $$PendingSyncQueueTableTableFilterComposer,
      $$PendingSyncQueueTableTableOrderingComposer,
      $$PendingSyncQueueTableTableAnnotationComposer,
      $$PendingSyncQueueTableTableCreateCompanionBuilder,
      $$PendingSyncQueueTableTableUpdateCompanionBuilder,
      (
        PendingSyncQueueTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingSyncQueueTableTable,
          PendingSyncQueueTableData
        >,
      ),
      PendingSyncQueueTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$ProductPriceHistoryTableTableTableManager get productPriceHistoryTable =>
      $$ProductPriceHistoryTableTableTableManager(
        _db,
        _db.productPriceHistoryTable,
      );
  $$StockMovementsTableTableTableManager get stockMovementsTable =>
      $$StockMovementsTableTableTableManager(_db, _db.stockMovementsTable);
  $$ProductionBatchesTableTableTableManager get productionBatchesTable =>
      $$ProductionBatchesTableTableTableManager(
        _db,
        _db.productionBatchesTable,
      );
  $$PendingSyncQueueTableTableTableManager get pendingSyncQueueTable =>
      $$PendingSyncQueueTableTableTableManager(_db, _db.pendingSyncQueueTable);
}
