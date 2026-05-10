/*part of 'team_cubit.dart';

abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<InspectionHead> head;
  final List<InspectionMember> members;

  TeamLoaded({required this.head, required this.members});
}

class TeamError extends TeamState {
  final String message;

  TeamError(this.message);
}*/
part of 'team_cubit.dart';

abstract class TeamState {}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<InspectionHead> head;
  final List<InspectionMember> members;
  TeamLoaded({required this.head, required this.members});
}

class TeamSuccess extends TeamState {
  final String message;
  TeamSuccess(this.message);
}

class TeamError extends TeamState {
  final String message;
  TeamError(this.message);
}
