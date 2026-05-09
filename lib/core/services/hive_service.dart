import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:falcon_system/data/models/aerodrome.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';
import 'package:falcon_system/data/sections/apron_element_score.dart';
import 'package:falcon_system/data/sections/apron_evaluation.dart';
import 'package:falcon_system/data/sections/met_element_score.dart';
import 'package:falcon_system/data/sections/met_evaluation.dart';
import 'package:falcon_system/data/sections/navaids_element_score.dart';
import 'package:falcon_system/data/sections/navaids_evaluation.dart';
import 'package:falcon_system/data/sections/rffs_element_score.dart';
import 'package:falcon_system/data/sections/rffs_evaluation.dart';
import 'package:falcon_system/data/sections/sms_element_score.dart';
import 'package:falcon_system/data/sections/sms_evaluation.dart';
import 'package:falcon_system/data/sections/taxiway_element_score.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_keys.dart';

class HiveService {
  static bool _initialized = false;


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
    Hive.registerAdapter(RffsElementScoreAdapter());
    Hive.registerAdapter(RffsEvaluationAdapter());
    Hive.registerAdapter(ApronElementScoreAdapter());
    Hive.registerAdapter(ApronEvaluationAdapter());
    Hive.registerAdapter(SmsElementScoreAdapter());
    Hive.registerAdapter(SmsEvaluationAdapter());
    Hive.registerAdapter(AerodromeAdapter());
    Hive.registerAdapter(AirportManagerAdapter());
    Hive.registerAdapter(InspectionHeadAdapter());
    Hive.registerAdapter(InspectionMemberAdapter());
    Hive.registerAdapter(AircraftAdapter());
    Hive.registerAdapter(EvaluationReportAdapter());
    Hive.registerAdapter(TaxiwayElementScoreAdapter());
    Hive.registerAdapter(TaxiwayEvaluationAdapter());
    Hive.registerAdapter(MetElementScoreAdapter());
    Hive.registerAdapter(NavaidsElementScoreAdapter());
    Hive.registerAdapter(NavaidsEvaluationAdapter());
    Hive.registerAdapter(MetEvaluationAdapter());
  }

  static Future<void> _openBoxes() async {
    await _safeOpenBox<AdminProfile>(HiveKeys.adminProfileBox);
    await _safeOpenBox<Aerodrome>(HiveKeys.aerodromesBox);
    await _safeOpenBox<AirportManager>(HiveKeys.airportManagersBox);
    await _safeOpenBox<InspectionHead>(HiveKeys.inspectionHeadBox);
    await _safeOpenBox<InspectionMember>(HiveKeys.inspectionTeamBox);
    await _safeOpenBox<Aircraft>(HiveKeys.aircraftBox);
    await _safeOpenBox<EvaluationReport>(HiveKeys.evaluationReportsBox);
  }

  static Future<void> _safeOpenBox<T>(String boxName) async {
   
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.close();
    }

  
    try {
      await Hive.openBox<T>(boxName);
      debugPrint('✓ Box $boxName opened successfully');
      return;
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('⚠ Error opening box $boxName: $e');

     
      if (errorStr.contains('is not a subtype')) {
        debugPrint('  ⚠ Detected corrupted/mismatched data - will clear');
      }
    }

   
    await Future.delayed(const Duration(milliseconds: 300));

 
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        await box.close();
      }
    } catch (_) {}

  
    try {
      debugPrint('  → Clearing corrupted data in $boxName');
      final box = await Hive.openBox<T>(boxName);
      if (box.isNotEmpty) {
        debugPrint('    Removing ${box.length} corrupted records');
        await box.clear();
      }
      debugPrint('✓ Box $boxName recovered');
      return;
    } catch (e) {
      debugPrint('⚠ Cannot clear box: $e');
    }

   
    final backupName =
        '${boxName}_backup_${DateTime.now().millisecondsSinceEpoch}';
    try {
      debugPrint('  → Trying with backup location: $backupName');
      
      try {
        await Hive.deleteBoxFromDisk(backupName);
      } catch (_) {}

      await Hive.openBox<T>(backupName);
      debugPrint('✓ Box opened at backup location: $backupName');
      return;
    } catch (e) {
      debugPrint('⚠ Backup location also failed: $e');
    }

  
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await Hive.openBox<T>(boxName);
      debugPrint('✓ Box $boxName finally opened');
      return;
    } catch (e) {
     
      debugPrint('⚠ FALLBACK: Box $boxName could not be initialized');
      debugPrint('   Reason: $e');
      debugPrint('   App will continue - some features may be limited');
    }
  }

  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }

  static Future<void> clearAll() async {
    final boxes = [
      HiveKeys.adminProfileBox,
      HiveKeys.aerodromesBox,
      HiveKeys.airportManagersBox,
      HiveKeys.inspectionHeadBox,
      HiveKeys.inspectionTeamBox,
      HiveKeys.aircraftBox,
      HiveKeys.evaluationReportsBox,
    ];

    for (final boxName in boxes) {
      try {
        // Try to clear if box is open
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          // If not open, try to delete
          await Hive.deleteBoxFromDisk(boxName);
        }
      } catch (_) {
        // Silently ignore errors during clear/delete
      }
    }
  }

  // ── Box getters ───────────────────────────────────────────────────────────
  static Box<AdminProfile> get adminBox {
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) {
      throw HiveError(
        'Admin box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.adminProfileBox);
  }

  static Box<Aerodrome> get aerodromeBox {
    if (!Hive.isBoxOpen(HiveKeys.aerodromesBox)) {
      throw HiveError(
        'Aerodrome box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.aerodromesBox);
  }

  static Box<AirportManager> get managerBox {
    if (!Hive.isBoxOpen(HiveKeys.airportManagersBox)) {
      throw HiveError(
        'Manager box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.airportManagersBox);
  }

  static Box<InspectionHead> get inspectionHeadBox {
    if (!Hive.isBoxOpen(HiveKeys.inspectionHeadBox)) {
      throw HiveError(
        'Inspection head box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.inspectionHeadBox);
  }

  static Box<InspectionMember> get inspectionMemberBox {
    if (!Hive.isBoxOpen(HiveKeys.inspectionTeamBox)) {
      throw HiveError(
        'Inspection member box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.inspectionTeamBox);
  }

  static Box<Aircraft> get aircraftBox {
    if (!Hive.isBoxOpen(HiveKeys.aircraftBox)) {
      throw HiveError(
        'Aircraft box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.aircraftBox);
  }

  static Box<EvaluationReport> get evaluationBox {
    if (!Hive.isBoxOpen(HiveKeys.evaluationReportsBox)) {
      throw HiveError(
        'Evaluation box not initialized. Call HiveService.init() first',
      );
    }
    return Hive.box(HiveKeys.evaluationReportsBox);
  }

  // ── Admin Profile ─────────────────────────────────────────────────────────

  /// Safe getter that attempts to open box if not available
  static Future<Box<AdminProfile>?> _getAdminBoxSafe() async {
    try {
      if (Hive.isBoxOpen(HiveKeys.adminProfileBox)) {
        return Hive.box(HiveKeys.adminProfileBox);
      }
      // Try to open if not open
      return await Hive.openBox<AdminProfile>(HiveKeys.adminProfileBox);
    } catch (e) {
      print('⚠ Could not access admin box: $e');
      return null;
    }
  }

  /// Save admin using their **email** as the storage key.
  /// This allows multiple admins, each identified by their email.
  static Future<void> saveAdminProfile(AdminProfile profile) async {
    // Ensure initialization
    if (!_initialized) {
      await init();
    }

    final box = await _getAdminBoxSafe();
    if (box == null) {
      print('⚠ WARNING: Admin box not available - save failed');
      return;
    }

    try {
      final key = profile.email.trim().toLowerCase();
      await box.put(key, profile);
      print('✓ Admin profile saved: $key');
    } catch (e) {
      print('⚠ Error saving admin profile: $e');
    }
  }

  /// Get admin profile by email (case-insensitive).
  /// Falls back to legacy 'admin' key for older data.
  static AdminProfile? getAdminByEmail(String email) {
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) {
      return null;
    }
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
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) {
      return null;
    }
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
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) {
      return [];
    }
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

/*
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_keys.dart';

import 'package:falcon_system/data/models/admin_profile.dart';
import 'package:falcon_system/data/models/aerodrome.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:falcon_system/data/models/evaluation_report.dart';
import 'package:falcon_system/data/models/inspection_head.dart';
import 'package:falcon_system/data/models/inspection_member.dart';

import 'package:falcon_system/data/sections/apron_element_score.dart';
import 'package:falcon_system/data/sections/apron_evaluation.dart';

import 'package:falcon_system/data/sections/met_element_score.dart';
import 'package:falcon_system/data/sections/met_evaluation.dart';

import 'package:falcon_system/data/sections/rffs_element_score.dart';
import 'package:falcon_system/data/sections/rffs_evaluation.dart';

import 'package:falcon_system/data/sections/taxiway_element_score.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';

class HiveService {
  HiveService._();

  static bool _initialized = false;

  /// ─────────────────────────────────────────────
  /// Current Logged In Admin
  /// ─────────────────────────────────────────────
  static String? _currentAdminEmail;

  static String? get currentAdminEmail => _currentAdminEmail;

  static void setCurrentAdminEmail(String email) {
    _currentAdminEmail = email.trim().toLowerCase();
  }

  /// ─────────────────────────────────────────────
  /// Initialize Hive
  /// ─────────────────────────────────────────────
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _registerAdapters();

    await _openBoxes();

    _initialized = true;

    debugPrint('✓ Hive initialized successfully');
  }

  /// ─────────────────────────────────────────────
  /// Register Adapters Safely
  /// ─────────────────────────────────────────────
  static void _registerAdapters() {
    _registerAdapterSafely(
      0,
      () => Hive.registerAdapter(AdminProfileAdapter()),
    );

    _registerAdapterSafely(1, () => Hive.registerAdapter(AerodromeAdapter()));

    _registerAdapterSafely(
      2,
      () => Hive.registerAdapter(AirportManagerAdapter()),
    );

    _registerAdapterSafely(
      3,
      () => Hive.registerAdapter(InspectionHeadAdapter()),
    );

    _registerAdapterSafely(
      4,
      () => Hive.registerAdapter(InspectionMemberAdapter()),
    );

    _registerAdapterSafely(5, () => Hive.registerAdapter(AircraftAdapter()));

    _registerAdapterSafely(
      6,
      () => Hive.registerAdapter(EvaluationReportAdapter()),
    );

    _registerAdapterSafely(
      7,
      () => Hive.registerAdapter(TaxiwayElementScoreAdapter()),
    );

    _registerAdapterSafely(
      8,
      () => Hive.registerAdapter(TaxiwayEvaluationAdapter()),
    );

    _registerAdapterSafely(
      9,
      () => Hive.registerAdapter(MetElementScoreAdapter()),
    );

    _registerAdapterSafely(
      10,
      () => Hive.registerAdapter(MetEvaluationAdapter()),
    );

    _registerAdapterSafely(
      11,
      () => Hive.registerAdapter(ApronElementScoreAdapter()),
    );

    _registerAdapterSafely(
      12,
      () => Hive.registerAdapter(ApronEvaluationAdapter()),
    );

    _registerAdapterSafely(
      13,
      () => Hive.registerAdapter(RffsElementScoreAdapter()),
    );

    _registerAdapterSafely(
      14,
      () => Hive.registerAdapter(RffsEvaluationAdapter()),
    );
  }

  static void _registerAdapterSafely(int typeId, VoidCallback register) {
    if (!Hive.isAdapterRegistered(typeId)) {
      register();
      debugPrint('✓ Adapter $typeId registered');
    }
  }

  /// ─────────────────────────────────────────────
  /// Open Boxes
  /// ─────────────────────────────────────────────
  static Future<void> _openBoxes() async {
    await _openBoxSafely<AdminProfile>(HiveKeys.adminProfileBox);

    await _openBoxSafely<Aerodrome>(HiveKeys.aerodromesBox);

    await _openBoxSafely<AirportManager>(HiveKeys.airportManagersBox);

    await _openBoxSafely<InspectionHead>(HiveKeys.inspectionHeadBox);

    await _openBoxSafely<InspectionMember>(HiveKeys.inspectionTeamBox);

    await _openBoxSafely<Aircraft>(HiveKeys.aircraftBox);

    await _openBoxSafely<EvaluationReport>(HiveKeys.evaluationReportsBox);
  }

  /// ─────────────────────────────────────────────
  /// Open Box Safely
  /// ─────────────────────────────────────────────
  static Future<void> _openBoxSafely<T>(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        debugPrint('✓ Box already open: $boxName');
        return;
      }

      await Hive.openBox<T>(boxName);

      debugPrint('✓ Opened box: $boxName');
    } catch (e) {
      debugPrint('⚠ Error opening box $boxName');
      debugPrint(e.toString());

      try {
        await Hive.deleteBoxFromDisk(boxName);

        await Hive.openBox<T>(boxName);

        debugPrint('✓ Recreated corrupted box: $boxName');
      } catch (e) {
        debugPrint('❌ Failed recreating box: $boxName');
        debugPrint(e.toString());
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// Close Hive
  /// ─────────────────────────────────────────────
  static Future<void> close() async {
    await Hive.close();

    _initialized = false;

    debugPrint('✓ Hive closed');
  }

  /// ─────────────────────────────────────────────
  /// Clear All Data
  /// ─────────────────────────────────────────────
  static Future<void> clearAll() async {
    final boxes = [
      HiveKeys.adminProfileBox,
      HiveKeys.aerodromesBox,
      HiveKeys.airportManagersBox,
      HiveKeys.inspectionHeadBox,
      HiveKeys.inspectionTeamBox,
      HiveKeys.aircraftBox,
      HiveKeys.evaluationReportsBox,
    ];

    for (final boxName in boxes) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          await Hive.deleteBoxFromDisk(boxName);
        }

        debugPrint('✓ Cleared box: $boxName');
      } catch (e) {
        debugPrint('⚠ Failed clearing box: $boxName');
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// Typed Boxes
  /// ─────────────────────────────────────────────

  static Box<AdminProfile> get adminBox =>
      Hive.box<AdminProfile>(HiveKeys.adminProfileBox);

  static Box<Aerodrome> get aerodromeBox =>
      Hive.box<Aerodrome>(HiveKeys.aerodromesBox);

  static Box<AirportManager> get managerBox =>
      Hive.box<AirportManager>(HiveKeys.airportManagersBox);

  static Box<InspectionHead> get inspectionHeadBox =>
      Hive.box<InspectionHead>(HiveKeys.inspectionHeadBox);

  static Box<InspectionMember> get inspectionMemberBox =>
      Hive.box<InspectionMember>(HiveKeys.inspectionTeamBox);

  static Box<Aircraft> get aircraftBox =>
      Hive.box<Aircraft>(HiveKeys.aircraftBox);

  static Box<EvaluationReport> get evaluationBox =>
      Hive.box<EvaluationReport>(HiveKeys.evaluationReportsBox);

  /// ─────────────────────────────────────────────
  /// Admin Methods
  /// ─────────────────────────────────────────────

  static Future<void> saveAdminProfile(AdminProfile profile) async {
    final key = profile.email.trim().toLowerCase();

    await adminBox.put(key, profile);

    debugPrint('✓ Admin saved: $key');
  }

  static AdminProfile? getAdminByEmail(String email) {
    final key = email.trim().toLowerCase();

    final admin = adminBox.get(key);

    if (admin != null) {
      return admin;
    }

    for (final item in adminBox.values) {
      if (item.email.trim().toLowerCase() == key) {
        return item;
      }
    }

    return null;
  }

  static AdminProfile? getAdminProfile() {
    if (_currentAdminEmail == null) {
      if (adminBox.isEmpty) return null;

      return adminBox.values.first;
    }

    return getAdminByEmail(_currentAdminEmail!);
  }

  static List<AdminProfile> getAllAdmins() {
    return adminBox.values.toList();
  }

  /// ─────────────────────────────────────────────
  /// Generic CRUD Helpers
  /// ─────────────────────────────────────────────

  static Future<void> putItem<T>(Box<T> box, dynamic key, T item) async {
    await box.put(key, item);
  }

  static Future<void> deleteItem<T>(Box<T> box, dynamic key) async {
    await box.delete(key);
  }

  static List<T> getAllItems<T>(Box<T> box) {
    return box.values.toList();
  }
}

*/
