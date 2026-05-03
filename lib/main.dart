import 'package:falcon_system/core/services/hive_service.dart';
import 'package:falcon_system/core/themes/app_theme.dart';
import 'package:falcon_system/features/aerodrome/presentation/cubit/aerodrome_cubit.dart';
import 'package:falcon_system/features/aircraft/presentation/cubit/aircraft_cubit.dart';
import 'package:falcon_system/features/evaluation/presentation/cubit/evaluation_cubit.dart';
import 'package:falcon_system/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:falcon_system/features/splash/presentation/screens/splash_screen.dart';
import 'package:falcon_system/features/team/presentation/cubit/team_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Hive
  await HiveService.init();

  runApp(const FalconAISApp());
}

class FalconAISApp extends StatelessWidget {
  const FalconAISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AerodromeCubit()),
        BlocProvider(create: (_) => EvaluationCubit()),
        BlocProvider(create: (_) => ManagerCubit()),
        BlocProvider(create: (_) => TeamCubit()),
        BlocProvider(create: (_) => AircraftCubit()),
      ],
      child: MaterialApp(
        title: 'FALCON-AIS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
