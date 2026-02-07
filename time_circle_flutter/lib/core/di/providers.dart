import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/sync_service.dart';
import '../storage/database/app_database.dart';
import '../storage/database/daos/moments_dao.dart';
import '../storage/database/daos/letters_dao.dart';
import '../../data/datasources/remote/moment_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/moment_local_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/letter_local_datasource.dart';
import '../../domain/repositories/moment_repository.dart';
import '../../data/repositories/moment_repository_impl.dart';

// ============== Core Infrastructure ==============

/// Flutter Secure Storage for tokens
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// App Database (Drift) - Singleton
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Network Info for connectivity checks
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

/// API Client for HTTP requests
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

// ============== DAOs ==============

/// Moments DAO
final momentsDaoProvider = Provider<MomentsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.momentsDao;
});

/// Letters DAO
final lettersDaoProvider = Provider<LettersDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.lettersDao;
});

// ============== Remote Data Sources ==============

/// Moment Remote Data Source
final momentRemoteDataSourceProvider = Provider<MomentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MomentRemoteDataSourceImpl(apiClient);
});

/// Auth Remote Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

// ============== Local Data Sources ==============

/// Moment Local Data Source
final momentLocalDataSourceProvider = Provider<MomentLocalDataSource>((ref) {
  final momentsDao = ref.watch(momentsDaoProvider);
  final database = ref.watch(appDatabaseProvider);
  return MomentLocalDataSourceImpl(momentsDao, database);
});

/// Auth Local Data Source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final database = ref.watch(appDatabaseProvider);
  return AuthLocalDataSourceImpl(secureStorage, database);
});

/// Letter Local Data Source
final letterLocalDataSourceProvider = Provider<LetterLocalDataSource>((ref) {
  final lettersDao = ref.watch(lettersDaoProvider);
  final database = ref.watch(appDatabaseProvider);
  return LetterLocalDataSourceImpl(lettersDao, database);
});

// ============== Repositories ==============

/// Moment Repository
final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  final remoteDataSource = ref.watch(momentRemoteDataSourceProvider);
  final localDataSource = ref.watch(momentLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return MomentRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// ============== Services ==============

/// Sync Service - handles background sync
final syncServiceProvider =
    StateNotifierProvider<SyncService, SyncServiceState>((ref) {
      final momentRepository = ref.watch(momentRepositoryProvider);
      final networkInfo = ref.watch(networkInfoProvider);
      return SyncService(
        momentRepository: momentRepository,
        networkInfo: networkInfo,
      );
    });

// ============== Auth State ==============

/// Current Circle ID (for repository operations)
final currentCircleIdProvider = StateProvider<String?>((ref) => null);

/// Current User ID
final currentUserIdProvider = StateProvider<String?>((ref) => null);
