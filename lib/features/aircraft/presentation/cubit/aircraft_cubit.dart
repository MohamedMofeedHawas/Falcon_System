import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/data/models/aircraft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'aircraft_state.dart';

class AircraftCubit extends Cubit<AircraftState> {
  final Uuid _uuid = const Uuid();

  AircraftCubit() : super(AircraftInitial()) {
    loadAircraft();
  }

  Future<void> loadAircraft() async {
    emit(AircraftLoading());
    try {
      final aircraft = HiveService.aircraftBox.toMap().entries
          .where((entry) => HiveService.isOwnedByCurrentAdmin(entry.key))
          .map((entry) => entry.value)
          .cast<Aircraft>()
          .toList();
      emit(AircraftLoaded(aircraft));
    } catch (e) {
      emit(AircraftError(e.toString()));
    }
  }

  Future<void> addAircraft(Aircraft aircraft) async {
    emit(AircraftLoading());
    try {
      aircraft.id = _uuid.v4();
      aircraft.createdAt = DateTime.now();
      await HiveService.aircraftBox.put(
        HiveService.scopedKey(aircraft.id),
        aircraft,
      );
      await loadAircraft();
    } catch (e) {
      emit(AircraftError(e.toString()));
    }
  }

  Future<void> updateAircraft(Aircraft aircraft) async {
    emit(AircraftLoading());
    try {
      aircraft.updatedAt = DateTime.now();
      await HiveService.aircraftBox.put(
        HiveService.scopedKey(aircraft.id),
        aircraft,
      );
      await loadAircraft();
    } catch (e) {
      emit(AircraftError(e.toString()));
    }
  }

  Future<void> deleteAircraft(String id) async {
    emit(AircraftLoading());
    try {
      await HiveService.aircraftBox.delete(HiveService.scopedKey(id));
      await loadAircraft();
    } catch (e) {
      emit(AircraftError(e.toString()));
    }
  }

  List<dynamic> searchAircraft(String query) {
    if (state is AircraftLoaded) {
      final aircraft = (state as AircraftLoaded).aircraft;
      if (query.isEmpty) return aircraft;
      return aircraft
          .where(
            (a) =>
                a.registrationNumber.contains(query) ||
                a.manufacturer.toLowerCase().contains(query.toLowerCase()) ||
                a.model.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    return [];
  }

  Aircraft? getAircraftById(String id) {
    return HiveService.aircraftBox.get(HiveService.scopedKey(id));
  }
}
