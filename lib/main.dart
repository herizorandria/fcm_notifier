import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_event.dart';
import 'core/routes/app_router.dart';
import 'core/constants/route_constants.dart';
import 'features/auth/auth_injection_container.dart' as auth_injection;
import 'features/auth/data/repositories/auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await auth_injection.initAuthDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => auth_injection.sl<AuthRepository>(),
        ),
      ],
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          authRepository: context.read<AuthRepository>(),
        )..add(CheckAuthEvent()),
        child: MaterialApp(
          title: 'Wizi Learn',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          scrollBehavior: CustomScrollBehavior(), // 👈 Ajout du comportement de scroll personnalisé
          initialRoute: RouteConstants.splash,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Colors.orange.shade200,
      child: child,
    );
  }
}
