/*import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../data/models/aerodrome.dart';

part 'aerodrome_state.dart';

class AerodromeCubit extends Cubit<AerodromeState> {
  AerodromeCubit() : super(AerodromeInitial());

  Box<Aerodrome> get _aerodromeBox => HiveService.aerodromeBox;

  Future<void> loadAerodromes() async {
    emit(AerodromeLoading());
    try {
      final aerodromes = _aerodromeBox.values.toList();
      emit(AerodromeLoaded(aerodromes: aerodromes));
    } catch (e) {
      emit(AerodromeError(message: e.toString()));
    }
  }

  Future<void> addAerodrome(Aerodrome aerodrome) async {
    emit(AerodromeLoading());
    try {
      await _aerodromeBox.put(aerodrome.id, aerodrome);
      final aerodromes = _aerodromeBox.values.toList();
      emit(AerodromeLoaded(aerodromes: aerodromes));
    } catch (e) {
      emit(AerodromeError(message: e.toString()));
    }
  }

  Future<void> updateAerodrome(Aerodrome aerodrome) async {
    emit(AerodromeLoading());
    try {
      await _aerodromeBox.put(aerodrome.id, aerodrome);
      final aerodromes = _aerodromeBox.values.toList();
      emit(AerodromeLoaded(aerodromes: aerodromes));
    } catch (e) {
      emit(AerodromeError(message: e.toString()));
    }
  }

  Future<void> deleteAerodrome(String id) async {
    emit(AerodromeLoading());
    try {
      await _aerodromeBox.delete(id);
      final aerodromes = _aerodromeBox.values.toList();
      emit(AerodromeLoaded(aerodromes: aerodromes));
    } catch (e) {
      emit(AerodromeError(message: e.toString()));
    }
  }

  Aerodrome? getAerodromeById(String id) => _aerodromeBox.get(id);

  List<dynamic> searchAerodromes(String query) {
    if (state is AerodromeLoaded) {
      final aerodromes = (state as AerodromeLoaded).aerodromes;
      return aerodromes.where((a) {
        if (a is Aerodrome) {
          return a.arabicName.contains(query) ||
              a.englishName.contains(query) ||
              a.icaoCode.contains(query);
        }
        return false;
      }).toList();
    }
    return [];
  }
}*/
import 'package:falcon_system/features/aerodrome/presentation/screens/aerdrome_seed.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// ← مسار ملف الـ seed
import '../../../../core/services/hive_service.dart';
import '../../../../data/models/aerodrome.dart';

part 'aerodrome_state.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// AerodromeCubit
/// ─────────────────────────────────────────────────────────────────────────
class AerodromeCubit extends Cubit<AerodromeState> {
  AerodromeCubit() : super(AerodromeInitial());

  Box<Aerodrome> get _box => HiveService.aerodromeBox;

  // ── حالة الفلتر الحالية (null = الكل) ────────────────────────────────
  String? _activeFilter;
  String get activeFilter => _activeFilter ?? 'الكل';

  // ══════════════════════════════════════════════════════════════════════
  // LOAD  (تحميل + seed عند الحاجة)
  // ══════════════════════════════════════════════════════════════════════

  Future<void> loadAerodromes() async {
    emit(AerodromeLoading());
    try {
      // ── Seed بيانات مطارات مصر عند أول تشغيل ─────────────────────────
      if (_ownedAerodromes().isEmpty) {
        await _seedEgyptianAerodromes();
      }

      _emitFiltered();
    } catch (e) {
      emit(AerodromeError(message: 'فشل تحميل بيانات المطارات: $e'));
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // CRUD
  // ══════════════════════════════════════════════════════════════════════

  Future<void> addAerodrome(Aerodrome aerodrome) async {
    emit(AerodromeLoading());
    try {
      await _box.put(HiveService.scopedKey(aerodrome.id), aerodrome);
      _emitFiltered();
    } catch (e) {
      emit(AerodromeError(message: 'فشل إضافة المطار: $e'));
    }
  }

  Future<void> updateAerodrome(Aerodrome aerodrome) async {
    emit(AerodromeLoading());
    try {
      await _box.put(HiveService.scopedKey(aerodrome.id), aerodrome);
      _emitFiltered();
    } catch (e) {
      emit(AerodromeError(message: 'فشل تعديل بيانات المطار: $e'));
    }
  }

  Future<void> deleteAerodrome(String id) async {
    emit(AerodromeLoading());
    try {
      await _box.delete(HiveService.scopedKey(id));
      _emitFiltered();
    } catch (e) {
      emit(AerodromeError(message: 'فشل حذف المطار: $e'));
    }
  }

  Aerodrome? getAerodromeById(String id) => _box.get(HiveService.scopedKey(id));

  // ══════════════════════════════════════════════════════════════════════
  // FILTER  (تصفية حسب نوع المطار)
  // ══════════════════════════════════════════════════════════════════════

  void applyFilter(String? type) {
    // null أو 'الكل' → عرض الجميع
    _activeFilter = (type == null || type == 'الكل') ? null : type;
    _emitFiltered();
  }

  // ══════════════════════════════════════════════════════════════════════
  // SEARCH
  // ══════════════════════════════════════════════════════════════════════

  List<Aerodrome> searchAerodromes(String query) {
    if (state is! AerodromeLoaded) return [];
    final q = query.toLowerCase().trim();
    return (state as AerodromeLoaded).displayedAerodromes.where((a) {
      return a.arabicName.contains(q) ||
          a.englishName.toLowerCase().contains(q) ||
          a.icaoCode.toLowerCase().contains(q) ||
          a.city.contains(q) ||
          a.governorate.contains(q);
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════════════
  // STATISTICS
  // ══════════════════════════════════════════════════════════════════════

  Map<String, int> getTypeCounts() {
    final all = _ownedAerodromes();
    final Map<String, int> counts = {};
    for (final a in all) {
      counts[a.airportType] = (counts[a.airportType] ?? 0) + 1;
    }
    return counts;
  }

  // ══════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════

  void _emitFiltered() {
    final all = _ownedAerodromes();
    final filtered = _activeFilter == null
        ? all
        : all.where((a) => a.airportType == _activeFilter).toList();

    emit(
      AerodromeLoaded(
        allAerodromes: all,
        displayedAerodromes: filtered,
        activeFilter: _activeFilter,
      ),
    );
  }

  Future<void> _seedEgyptianAerodromes() async {
    for (final aerodrome in AerodromeSeed.egyptianAerodromes) {
      await _box.put(HiveService.scopedKey(aerodrome.id), aerodrome);
    }
  }

  List<Aerodrome> _ownedAerodromes() {
    return _box.toMap().entries
        .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
        .map((entry) => entry.value)
        .toList();
  }
}
