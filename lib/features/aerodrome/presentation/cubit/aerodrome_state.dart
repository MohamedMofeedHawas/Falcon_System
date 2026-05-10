/*part of 'aerodrome_cubit.dart';

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
}*/
part of 'aerodrome_cubit.dart';

abstract class AerodromeState {
  const AerodromeState();
}

class AerodromeInitial extends AerodromeState {}

class AerodromeLoading extends AerodromeState {}

/// الحالة الرئيسية — تحمل القائمة الكاملة والقائمة المفلترة
class AerodromeLoaded extends AerodromeState {
  /// جميع المطارات بدون أي فلتر
  final List<Aerodrome> allAerodromes;

  /// القائمة المعروضة (بعد تطبيق الفلتر)
  final List<Aerodrome> displayedAerodromes;

  /// نوع الفلتر النشط حاليًا (null = الكل)
  final String? activeFilter;

  const AerodromeLoaded({
    required this.allAerodromes,
    required this.displayedAerodromes,
    this.activeFilter,
  });

  /// عدد مطارات كل نوع — لعرض الأرقام في الفلتر chips
  Map<String, int> get typeCounts {
    final Map<String, int> counts = {};
    for (final a in allAerodromes) {
      counts[a.airportType] = (counts[a.airportType] ?? 0) + 1;
    }
    return counts;
  }
}

class AerodromeError extends AerodromeState {
  final String message;
  const AerodromeError({required this.message});
}
