part of 'evaluation_cubit.dart';

abstract class EvaluationState {
  const EvaluationState();
}

class EvaluationInitial extends EvaluationState {}

class EvaluationLoading extends EvaluationState {}

class EvaluationLoaded extends EvaluationState {
  final List<dynamic> evaluations;

  const EvaluationLoaded({required this.evaluations});
}

class EvaluationError extends EvaluationState {
  final String message;

  const EvaluationError({required this.message});
}
