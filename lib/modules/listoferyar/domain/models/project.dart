class ListoferyarProject {
  const ListoferyarProject({
    this.id,
    required this.name,
    this.employer = '',
    this.consultant = '',
    this.contractor = '',
    this.residentSupervisor = '',
    this.contractDate = '',
    this.contractNumber = '',
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final String employer;
  final String consultant;
  final String contractor;
  final String residentSupervisor;
  final String contractDate;
  final String contractNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'employer': employer,
        'consultant': consultant,
        'contractor': contractor,
        'resident_supervisor': residentSupervisor,
        'contract_date': contractDate,
        'contract_number': contractNumber,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  ListoferyarProject copyWith({
    int? id,
    String? name,
    String? employer,
    String? consultant,
    String? contractor,
    String? residentSupervisor,
    String? contractDate,
    String? contractNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ListoferyarProject(
        id: id ?? this.id,
        name: name ?? this.name,
        employer: employer ?? this.employer,
        consultant: consultant ?? this.consultant,
        contractor: contractor ?? this.contractor,
        residentSupervisor: residentSupervisor ?? this.residentSupervisor,
        contractDate: contractDate ?? this.contractDate,
        contractNumber: contractNumber ?? this.contractNumber,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory ListoferyarProject.fromMap(Map<String, Object?> map) =>
      ListoferyarProject(
        id: map['id'] as int?,
        name: map['name'] as String? ?? '',
        employer: map['employer'] as String? ?? '',
        consultant: map['consultant'] as String? ?? '',
        contractor: map['contractor'] as String? ?? '',
        residentSupervisor: map['resident_supervisor'] as String? ?? '',
        contractDate: map['contract_date'] as String? ?? '',
        contractNumber: map['contract_number'] as String? ?? '',
        createdAt: _date(map['created_at']),
        updatedAt: _date(map['updated_at']),
      );

  static DateTime? _date(Object? value) => value is String
      ? DateTime.tryParse(value)
      : null;
}
