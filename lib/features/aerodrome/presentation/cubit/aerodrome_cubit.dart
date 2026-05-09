import 'package:flutter_bloc/flutter_bloc.dart';
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
}
