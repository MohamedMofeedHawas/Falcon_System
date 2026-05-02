part of 'manager_cubit.dart';

abstract class ManagerState {}

class ManagerInitial extends ManagerState {}

class ManagerLoading extends ManagerState {}

class ManagerLoaded extends ManagerState {
  final List<AirportManager> managers;

  ManagerLoaded(this.managers);
}

class ManagerError extends ManagerState {
  final String message;

  ManagerError(this.message);
}
