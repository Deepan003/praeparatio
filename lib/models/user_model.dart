import 'package:intl/intl.dart';

class UserModel {
  final String id;
  final String name;
  final String username;
  final String passwordHash;
  final String passwordPlain;
  final String studentClass;
  final String batch;
  int prepcoins;
  final bool isAdmin;
  bool isBanned;
  List<String> earnedBadgeIds;
  String? selectedAvatarId;
  List<String> claimedAvatarIds;
  final DateTime createdAt;
  DateTime? lastLogin;
  Map<String, bool> monthlyPayments; // 'YYYY-MM' -> true=paid, false=explicitly not paid
  List<String> feeExemptMonths;     // months where fees are not required (e.g. 'YYYY-MM')
  Map<String, int> loginStreak;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.passwordHash,
    this.passwordPlain = '',
    required this.studentClass,
    required this.batch,
    this.prepcoins = 80,
    this.isAdmin = false,
    this.isBanned = false,
    List<String>? earnedBadgeIds,
    this.selectedAvatarId,
    List<String>? claimedAvatarIds,
    required this.createdAt,
    this.lastLogin,
    Map<String, bool>? monthlyPayments,
    List<String>? feeExemptMonths,
    Map<String, int>? loginStreak,
  })  : earnedBadgeIds = earnedBadgeIds ?? [],
        claimedAvatarIds = claimedAvatarIds ?? [],
        monthlyPayments = monthlyPayments ?? {},
        feeExemptMonths = feeExemptMonths ?? [],
        loginStreak = loginStreak ?? {};

  // ── Fee helpers ─────────────────────────────────────────────

  /// Returns fee status for a given 'YYYY-MM' key.
  /// 'paid', 'exempt', or 'unpaid'
  String feeStatusFor(String monthKey) {
    if (feeExemptMonths.contains(monthKey)) return 'exempt';
    if (monthlyPayments[monthKey] == true) return 'paid';
    return 'unpaid';
  }

  bool hasPaidForMonth(String monthKey) => monthlyPayments[monthKey] == true;
  bool isExemptForMonth(String monthKey) => feeExemptMonths.contains(monthKey);

  /// Current month fee status
  String get currentMonthFeeStatus {
    final key = DateFormat('yyyy-MM').format(DateTime.now());
    return feeStatusFor(key);
  }

  /// All months that have any fee data (paid, unpaid marked, or exempt)
  Set<String> get allFeeMonths {
    final s = <String>{};
    s.addAll(monthlyPayments.keys);
    s.addAll(feeExemptMonths);
    return s;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'username': username,
        'passwordHash': passwordHash,
        'studentClass': studentClass,
        'batch': batch,
        'prepcoins': prepcoins,
        'isAdmin': isAdmin,
        'isBanned': isBanned,
        'earnedBadgeIds': earnedBadgeIds,
        'selectedAvatarId': selectedAvatarId,
        'claimedAvatarIds': claimedAvatarIds,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'monthlyPayments': monthlyPayments,
        'feeExemptMonths': feeExemptMonths,
        'loginStreak': loginStreak,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'],
        username: map['username'],
        passwordHash: map['passwordHash'],
        studentClass: map['studentClass'] ?? '11',
        batch: map['batch'] ?? '11 NEET',
        prepcoins: map['prepcoins'] ?? 80,
        isAdmin: map['isAdmin'] ?? false,
        isBanned: map['isBanned'] ?? false,
        earnedBadgeIds: List<String>.from(map['earnedBadgeIds'] ?? []),
        selectedAvatarId: map['selectedAvatarId'],
        claimedAvatarIds: List<String>.from(map['claimedAvatarIds'] ?? []),
        createdAt: DateTime.parse(map['createdAt']),
        lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
        monthlyPayments: Map<String, bool>.from(map['monthlyPayments'] ?? {}),
        feeExemptMonths: List<String>.from(map['feeExemptMonths'] ?? []),
        loginStreak: Map<String, int>.from(map['loginStreak'] ?? {}),
      );

  UserModel copyWith({
    String? name,
    int? prepcoins,
    bool? isBanned,
    List<String>? earnedBadgeIds,
    String? selectedAvatarId,
    List<String>? claimedAvatarIds,
    DateTime? lastLogin,
    Map<String, bool>? monthlyPayments,
    List<String>? feeExemptMonths,
  }) => UserModel(
        id: id,
        name: name ?? this.name,
        username: username,
        passwordHash: passwordHash,
        studentClass: studentClass,
        batch: batch,
        prepcoins: prepcoins ?? this.prepcoins,
        isAdmin: isAdmin,
        isBanned: isBanned ?? this.isBanned,
        earnedBadgeIds: earnedBadgeIds ?? List.from(this.earnedBadgeIds),
        selectedAvatarId: selectedAvatarId ?? this.selectedAvatarId,
        claimedAvatarIds: claimedAvatarIds ?? List.from(this.claimedAvatarIds),
        createdAt: createdAt,
        lastLogin: lastLogin ?? this.lastLogin,
        monthlyPayments: monthlyPayments ?? Map.from(this.monthlyPayments),
        feeExemptMonths: feeExemptMonths ?? List.from(this.feeExemptMonths),
      );
}
