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
import 'package:falcon_system/data/sections/runway_element_score.dart';
import 'package:falcon_system/data/sections/runway_evaluation.dart';
import 'package:falcon_system/data/sections/sms_element_score.dart';
import 'package:falcon_system/data/sections/sms_evaluation.dart';
import 'package:falcon_system/data/sections/taxiway_element_score.dart';
import 'package:falcon_system/data/sections/taxiway_evaluation.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_keys.dart';

/// ──────────────────────────────────────────────────────────────────────────
/// HiveService — singleton Hive manager (three-level box-open safety)
///
/// ROOT CAUSE of "box X is already open" errors
/// ─────────────────────────────────────────────
/// Hive.openBox<T>() throws if the box is already open, even if it's open
/// with the same type T. This happens when:
///   a) init() is called more than once (hot-reload, reinit after logout).
///   b) A Cubit / Repository calls Hive.openBox<T>() directly in addition
///      to HiveService.init() — both paths race to open the same box.
///
/// THE FIX — _openBox<T>() uses three progressive guards so it CANNOT throw:
///   Level 1  isBoxOpen()  check  → return immediately (zero I/O).
///   Level 2  catch HiveError "already open" → adopt the existing box.
///   Level 3  corruption recovery (clear → reopen → delete+recreate).
/// ──────────────────────────────────────────────────────────────────────────
class HiveService {
  HiveService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static String? _currentAdminEmail;
  static String? get currentAdminEmail => _currentAdminEmail;
  static void setCurrentAdminEmail(String email) =>
      _currentAdminEmail = email.trim().toLowerCase();

  // ══════════════════════════════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> init() async {
    if (_initialized) {
      debugPrint('HiveService: already initialized — skipping init');
      // Still verify boxes are open, in case of hot reload
      for (final name in _boxNames) {
        if (!Hive.isBoxOpen(name)) {
          debugPrint('  ⚠ Box "$name" unexpectedly closed — reopening');
          // Reopen without type checking to avoid type mismatch errors
          try {
            await Hive.openBox(name);
          } catch (e) {
            debugPrint('  ⚠ Could not reopen "$name": $e');
          }
        }
      }
      return;
    }

    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
    _initialized = true;
    debugPrint('✓ HiveService ready');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADAPTERS
  // ══════════════════════════════════════════════════════════════════════════

  static void _registerAdapters() {
    _reg(0, () => Hive.registerAdapter(AdminProfileAdapter()));
    _reg(1, () => Hive.registerAdapter(AerodromeAdapter()));
    _reg(2, () => Hive.registerAdapter(AirportManagerAdapter()));
    _reg(3, () => Hive.registerAdapter(InspectionHeadAdapter()));
    _reg(4, () => Hive.registerAdapter(InspectionMemberAdapter()));
    _reg(5, () => Hive.registerAdapter(AircraftAdapter()));
    _reg(6, () => Hive.registerAdapter(EvaluationReportAdapter()));
    _reg(7, () => Hive.registerAdapter(TaxiwayElementScoreAdapter()));
    _reg(8, () => Hive.registerAdapter(TaxiwayEvaluationAdapter()));
    _reg(9, () => Hive.registerAdapter(MetElementScoreAdapter()));
    _reg(10, () => Hive.registerAdapter(MetEvaluationAdapter()));
    _reg(11, () => Hive.registerAdapter(ApronElementScoreAdapter()));
    _reg(12, () => Hive.registerAdapter(ApronEvaluationAdapter()));
    _reg(13, () => Hive.registerAdapter(RffsElementScoreAdapter()));
    _reg(14, () => Hive.registerAdapter(RffsEvaluationAdapter()));
    _reg(15, () => Hive.registerAdapter(SmsElementScoreAdapter()));
    _reg(16, () => Hive.registerAdapter(SmsEvaluationAdapter()));
    _reg(17, () => Hive.registerAdapter(NavaidsElementScoreAdapter()));
    _reg(18, () => Hive.registerAdapter(NavaidsEvaluationAdapter()));
    _reg(19, () => Hive.registerAdapter(RunwayElementScoreAdapter()));
    _reg(20, () => Hive.registerAdapter(RunwayEvaluationAdapter()));
  }

  static void _reg(int id, VoidCallback fn) {
    if (!Hive.isAdapterRegistered(id)) fn();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOX OPENING
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> _openBoxes() async {
    await _openBox<AdminProfile>(HiveKeys.adminProfileBox);
    await _openBox<Aerodrome>(HiveKeys.aerodromesBox);
    await _openBox<AirportManager>(HiveKeys.airportManagersBox);
    await _openBox<InspectionHead>(HiveKeys.inspectionHeadBox);
    await _openBox<InspectionMember>(HiveKeys.inspectionTeamBox);
    await _openBox<Aircraft>(HiveKeys.aircraftBox);
    await _openBox<EvaluationReport>(HiveKeys.evaluationReportsBox);
  }

  static Future<void> _openBox<T>(String name) async {
    // ── Level 1: already open → nothing to do ────────────────────────────
    if (Hive.isBoxOpen(name)) {
      debugPrint('↩  "$name" already open — reusing');
      return;
    }

    // ── Level 2: normal open, with comprehensive error catch ──────────────
    try {
      await Hive.openBox<T>(name);
      debugPrint('✓  "$name" opened');
      return;
    } catch (e) {
      // Convert error to string and check for "already open" pattern.
      // This is more robust than accessing .message directly.
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('already open')) {
        // Some other code path opened it first — just adopt the existing box.
        debugPrint('↩  "$name" adopted (opened externally)');
        if (Hive.isBoxOpen(name)) return;
      }

      debugPrint('⚠  "$name" error during open: $e');
    }

    // ── Level 3a: box may have reopened during the catch — recheck ────────
    if (Hive.isBoxOpen(name)) return;

    // ── Level 3b: data corruption → clear and reopen ──────────────────────
    try {
      if (Hive.isBoxOpen(name)) return;
      final box = await Hive.openBox<T>(name);
      if (box.isNotEmpty) {
        debugPrint('  → Clearing ${box.length} corrupted records in "$name"');
        await box.clear();
      }
      debugPrint('✓  "$name" recovered (cleared)');
      return;
    } catch (e) {
      debugPrint('⚠  "$name" Level 3b failed: $e');
    }

    if (Hive.isBoxOpen(name)) return;

    // ── Level 3c: nuclear — delete from disk and recreate ─────────────────
    try {
      if (Hive.isBoxOpen(name)) return;
      await Hive.deleteBoxFromDisk(name);
      if (Hive.isBoxOpen(name)) return;
      await Hive.openBox<T>(name);
      debugPrint('✓  "$name" recreated from scratch');
    } catch (e) {
      debugPrint('❌  "$name" could not be initialized: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PUBLIC: ensureOpen — use this in Cubits/Repositories instead of
  //         calling Hive.openBox<T>() directly, which is the root cause.
  // ══════════════════════════════════════════════════════════════════════════

  /// Idempotent box accessor. Safe to call from any Cubit or Repository.
  /// Replaces any direct Hive.openBox<T>() calls in the rest of the app.
  static Future<Box<T>> ensureOpen<T>(String name) async {
    await _openBox<T>(name);
    return Hive.box<T>(name);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
    debugPrint('✓ HiveService closed');
  }

  static Future<void> clearAll() async {
    for (final name in _boxNames) {
      try {
        if (Hive.isBoxOpen(name)) {
          await Hive.box(name).clear();
        } else {
          await Hive.deleteBoxFromDisk(name);
        }
        debugPrint('✓ Cleared "$name"');
      } catch (e) {
        debugPrint('⚠ clearAll "$name": $e');
      }
    }
  }

  static const _boxNames = [
    HiveKeys.adminProfileBox,
    HiveKeys.aerodromesBox,
    HiveKeys.airportManagersBox,
    HiveKeys.inspectionHeadBox,
    HiveKeys.inspectionTeamBox,
    HiveKeys.aircraftBox,
    HiveKeys.evaluationReportsBox,
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // TYPED BOX GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  static Box<AdminProfile> get adminBox => _get(HiveKeys.adminProfileBox);
  static Box<Aerodrome> get aerodromeBox => _get(HiveKeys.aerodromesBox);
  static Box<AirportManager> get managerBox =>
      _get(HiveKeys.airportManagersBox);
  static Box<InspectionHead> get inspectionHeadBox =>
      _get(HiveKeys.inspectionHeadBox);
  static Box<InspectionMember> get inspectionMemberBox =>
      _get(HiveKeys.inspectionTeamBox);
  static Box<Aircraft> get aircraftBox => _get(HiveKeys.aircraftBox);
  static Box<EvaluationReport> get evaluationBox =>
      _get(HiveKeys.evaluationReportsBox);

  static Box<T> _get<T>(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw HiveError(
        'Box "$name" is not open. '
        'Ensure HiveService.init() is awaited before accessing boxes.',
      );
    }
    return Hive.box<T>(name);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> saveAdminProfile(AdminProfile profile) async {
    if (!_initialized) await init();
    try {
      await adminBox.put(profile.email.trim().toLowerCase(), profile);
      debugPrint('✓ Admin saved: ${profile.email}');
    } catch (e) {
      debugPrint('⚠ saveAdminProfile: $e');
    }
  }

  static AdminProfile? getAdminByEmail(String email) {
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) return null;
    final key = email.trim().toLowerCase();
    final direct = adminBox.get(key);
    if (direct is AdminProfile) return direct;
    final legacy = adminBox.get('admin');
    if (legacy is AdminProfile && legacy.email.trim().toLowerCase() == key) {
      return legacy;
    }
    for (final k in adminBox.keys) {
      final p = adminBox.get(k);
      if (p is AdminProfile && p.email.trim().toLowerCase() == key) return p;
    }
    return null;
  }

  static AdminProfile? getAdminProfile() {
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) return null;
    if (_currentAdminEmail != null) {
      final p = getAdminByEmail(_currentAdminEmail!);
      if (p != null) return p;
    }
    final legacy = adminBox.get('admin');
    if (legacy is AdminProfile) return legacy;
    for (final k in adminBox.keys) {
      final p = adminBox.get(k);
      if (p is AdminProfile) return p;
    }
    return null;
  }

  static List<AdminProfile> getAllAdmins() {
    if (!Hive.isBoxOpen(HiveKeys.adminProfileBox)) return [];
    final seen = <String>{};
    return [
      for (final k in adminBox.keys)
        if (adminBox.get(k) is AdminProfile &&
            seen.add((adminBox.get(k) as AdminProfile).id))
          adminBox.get(k) as AdminProfile,
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GENERIC CRUD
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> putItem<T>(Box<T> box, dynamic key, T item) =>
      box.put(key, item);

  static Future<void> deleteItem<T>(Box<T> box, dynamic key) => box.delete(key);

  static List<T> getAllItems<T>(Box<T> box) => box.values.toList();
}
