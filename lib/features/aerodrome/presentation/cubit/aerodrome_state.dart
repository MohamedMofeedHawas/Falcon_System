part of 'aerodrome_cubit.dart';

abstract class AerodromeState {
  const AerodromeState();
}

class AerodromeInitial extends AerodromeState {}

class AerodromeLoading extends AerodromeState {}

class AerodromeLoaded extends AerodromeState {
  final List<dynamic> aerodromes;

  const AerodromeLoaded({required this.aerodromes});
}

class AerodromeError extends AerodromeState {
  final String message;

  const AerodromeError({required this.message});
}
