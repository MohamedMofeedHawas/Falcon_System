/*import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final Uuid _uuid = const Uuid();

  ManagerCubit() : super(ManagerInitial()) {
    loadManagers();
  }

  Future<void> loadManagers() async {
    emit(ManagerLoading());
    try {
      final managers = HiveService.managerBox.values
          .cast<AirportManager>()
          .toList();
      emit(ManagerLoaded(managers));
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> addManager(AirportManager manager) async {
    emit(ManagerLoading());
    try {
      manager.id = _uuid.v4();
      manager.createdAt = DateTime.now();
      await HiveService.managerBox.put(manager.id, manager);
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> updateManager(AirportManager manager) async {
    emit(ManagerLoading());
    try {
      manager.updatedAt = DateTime.now();
      await HiveService.managerBox.put(manager.id, manager);
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> deleteManager(String id) async {
    emit(ManagerLoading());
    try {
      await HiveService.managerBox.delete(id);
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  List<dynamic> searchManagers(String query) {
    if (state is ManagerLoaded) {
      final managers = (state as ManagerLoaded).managers;
      if (query.isEmpty) return managers;
      return managers
          .where(
            (m) =>
                m.fullName.contains(query) || m.employeeNumber.contains(query),
          )
          .toList();
    }
    return [];
  }

  AirportManager? getManagerById(String id) {
    return HiveService.managerBox.get(id);
  }
}*/
import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final Uuid _uuid = const Uuid();

  ManagerCubit() : super(ManagerInitial()) {
    loadManagers();
  }

  // ── الحالة الحالية للقائمة (cached for search without re-emit) ──────────
  List<AirportManager> _allManagers = [];
  List<AirportManager> get allManagers => List.unmodifiable(_allManagers);

  Future<void> loadManagers() async {
    emit(ManagerLoading());
    try {
      _allManagers =
          HiveService.managerBox.toMap().entries
              .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
              .map((entry) => entry.value)
              .cast<AirportManager>()
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(ManagerLoaded(List.from(_allManagers)));
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> addManager(AirportManager manager) async {
    emit(ManagerLoading());
    try {
      final newManager = manager.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await HiveService.managerBox.put(
        HiveService.scopedKey(newManager.id),
        newManager,
      );
      await loadManagers();
      emit(ManagerSuccess('تم إضافة القائد بنجاح'));
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> updateManager(AirportManager manager) async {
    emit(ManagerLoading());
    try {
      final updated = manager.copyWith(updatedAt: DateTime.now());
      await HiveService.managerBox.put(HiveService.scopedKey(updated.id), updated);
      await loadManagers();
      emit(ManagerSuccess('تم تحديث بيانات القائد بنجاح'));
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  Future<void> deleteManager(String id) async {
    emit(ManagerLoading());
    try {
      await HiveService.managerBox.delete(HiveService.scopedKey(id));
      await loadManagers();
    } catch (e) {
      emit(ManagerError(e.toString()));
    }
  }

  List<AirportManager> searchManagers(String query) {
    if (query.trim().isEmpty) return List.from(_allManagers);
    final q = query.trim().toLowerCase();
    return _allManagers
        .where(
          (m) =>
              m.fullName.toLowerCase().contains(q) ||
              m.employeeNumber.toLowerCase().contains(q) ||
              m.phoneNumbers.any((p) => p.contains(q)),
        )
        .toList();
  }

  AirportManager? getManagerById(String id) {
    return HiveService.managerBox.get(HiveService.scopedKey(id));
  }
}
