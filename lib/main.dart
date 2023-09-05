import 'package:appsms/cubit/receiversPhoneNumber/receivers_phone_numbers_cubit.dart';
import 'package:appsms/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'cubit/messages/list_messages_cubit.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      /* builder: ((context, child) {
        return MultiRepositoryProvider(providers: [], child: child!);
      }), */
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ReceiversPhoneNumbersCubit()),
          BlocProvider(create: (context) => ListMessagesCubit()),
        ],
        child: const SafeArea(child: HomePage()),
      ),
    );
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
