import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/airport_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  ManagerCubit(this._hiveService) : super(ManagerInitial()) {
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
}
