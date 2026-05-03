import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:falcon_system/data/models/aerodrome.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:falcon_system/data/sections/taxiway_element_score.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';

import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_keys.dart';

class HiveService {
  static bool _initialized = false;

  /// ── Current logged-in admin (set on successful login) ──────────────────
  static String? _currentAdminEmail;
  static String? get currentAdminEmail => _currentAdminEmail;
  static void setCurrentAdminEmail(String email) {
    _currentAdminEmail = email.trim().toLowerCase();
  }

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
    _initialized = true;
  }

  static void _registerAdapters() {
    Hive.registerAdapter(AdminProfileAdapter());
    Hive.registerAdapter(AerodromeAdapter());
    Hive.registerAdapter(AirportManagerAdapter());
    Hive.registerAdapter(InspectionHeadAdapter());
    Hive.registerAdapter(InspectionMemberAdapter());
    Hive.registerAdapter(AircraftAdapter());
    Hive.registerAdapter(EvaluationReportAdapter());
    Hive.registerAdapter(TaxiwayElementScoreAdapter()); // typeId: 7
    Hive.registerAdapter(TaxiwayEvaluationAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<dynamic>(HiveKeys.adminProfileBox);
    await Hive.openBox<dynamic>(HiveKeys.aerodromesBox);
    await Hive.openBox<dynamic>(HiveKeys.airportManagersBox);
    await Hive.openBox<dynamic>(HiveKeys.inspectionHeadBox);
    await Hive.openBox<dynamic>(HiveKeys.inspectionTeamBox);
    await Hive.openBox<dynamic>(HiveKeys.aircraftBox);
    await Hive.openBox<dynamic>(HiveKeys.evaluationReportsBox);
  }

  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  static Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(HiveKeys.adminProfileBox);
    await Hive.deleteBoxFromDisk(HiveKeys.aerodromesBox);
    await Hive.deleteBoxFromDisk(HiveKeys.airportManagersBox);
    await Hive.deleteBoxFromDisk(HiveKeys.inspectionHeadBox);
    await Hive.deleteBoxFromDisk(HiveKeys.inspectionTeamBox);
    await Hive.deleteBoxFromDisk(HiveKeys.aircraftBox);
    await Hive.deleteBoxFromDisk(HiveKeys.evaluationReportsBox);
  }

  // ── Box getters ───────────────────────────────────────────────────────────
  static Box<dynamic> get adminBox => Hive.box(HiveKeys.adminProfileBox);
  static Box<dynamic> get aerodromeBox => Hive.box(HiveKeys.aerodromesBox);
  static Box<dynamic> get managerBox => Hive.box(HiveKeys.airportManagersBox);
  static Box<dynamic> get inspectionHeadBox =>
      Hive.box(HiveKeys.inspectionHeadBox);
  static Box<dynamic> get inspectionMemberBox =>
      Hive.box(HiveKeys.inspectionTeamBox);
  static Box<dynamic> get aircraftBox => Hive.box(HiveKeys.aircraftBox);
  static Box<dynamic> get evaluationBox =>
      Hive.box(HiveKeys.evaluationReportsBox);

  // ── Admin Profile ─────────────────────────────────────────────────────────

  /// Save admin using their **email** as the storage key.
  /// This allows multiple admins, each identified by their email.
  static Future<void> saveAdminProfile(AdminProfile profile) async {
    final key = profile.email.trim().toLowerCase();
    await adminBox.put(key, profile);
  }

  /// Get admin profile by email (case-insensitive).
  /// Falls back to legacy 'admin' key for older data.
  static AdminProfile? getAdminByEmail(String email) {
    final key = email.trim().toLowerCase();
    // ① Direct email-key lookup (new storage format)
    final direct = adminBox.get(key);
    if (direct is AdminProfile) return direct;

    // ② Legacy 'admin' key — check if email matches
    final legacy = adminBox.get('admin');
    if (legacy is AdminProfile && legacy.email.trim().toLowerCase() == key) {
      return legacy;
    }

    // ③ Full scan (migration edge case)
    for (final k in adminBox.keys) {
      final p = adminBox.get(k);
      if (p is AdminProfile && p.email.trim().toLowerCase() == key) {
        return p;
      }
    }
    return null;
  }

  /// Returns the profile of the currently logged-in admin.
  /// Falls back to the first admin found (useful during initial setup).
  static AdminProfile? getAdminProfile() {
    if (_currentAdminEmail != null) {
      final p = getAdminByEmail(_currentAdminEmail!);
      if (p != null) return p;
    }
    // Try legacy 'admin' key
    final legacy = adminBox.get('admin');
    if (legacy is AdminProfile) return legacy;
    // First value in box
    for (final k in adminBox.keys) {
      final p = adminBox.get(k);
      if (p is AdminProfile) return p;
    }
    return null;
  }

  /// All registered admins (for admin list screen if needed later)
  static List<AdminProfile> getAllAdmins() {
    final result = <AdminProfile>[];
    final seen = <String>{};
    for (final k in adminBox.keys) {
      final p = adminBox.get(k);
      if (p is AdminProfile && seen.add(p.id)) {
        result.add(p);
      }
    }
    return result;
  }
}
