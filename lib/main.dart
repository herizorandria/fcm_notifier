import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wizi_learn/injection_container.dart';
import 'package:wizi_learn/presentation/bloc/auth/auth_bloc.dart';
import 'package:wizi_learn/route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authBloc = await InjectionContainer.init();

  runApp(MyApp(authBloc: authBloc));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp(
        title: 'Wizi Learn',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}