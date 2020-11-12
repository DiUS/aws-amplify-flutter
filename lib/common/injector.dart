import 'package:amplify/bloc/auth_bloc.dart';
import 'package:amplify/bloc/storage_bloc.dart';
import 'package:amplify/data/sources/file_repo.dart';
import 'package:amplify/data/sources/user_repo.dart';
import 'package:amplify/features/signin/auth_event_handler.dart';
import 'package:amplify/services/analytics_service.dart';
import 'package:amplify/services/cloud_service.dart';
import 'package:get_it/get_it.dart';

final injector = GetIt.instance;

void setupInjector() {
  injector.registerSingleton<CloudService>(CloudService());
  injector.registerFactory<AnalyticsService>(() => AnalyticsService());

  injector.registerSingleton<AuthEventHandler>(AuthEventHandler());

  injector.registerSingleton<UserRepo>(UserRepo());
  injector.registerSingleton<FileRepo>(FileRepo());

  injector.registerSingleton<AuthBloc>(AuthBloc());
  injector.registerFactory<StorageBloc>(() => StorageBloc());
}
