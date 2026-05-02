part of 'aircraft_cubit.dart';

abstract class AircraftState {}

class AircraftInitial extends AircraftState {}

class AircraftLoading extends AircraftState {}

class AircraftLoaded extends AircraftState {
  final List<Aircraft> aircraft;

  AircraftLoaded(this.aircraft);
}

class AircraftError extends AircraftState {
  final String message;

  AircraftError(this.message);
}
