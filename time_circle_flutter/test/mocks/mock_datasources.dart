import 'package:mocktail/mocktail.dart';

import 'package:time_circle/core/network/network_info.dart';
import 'package:time_circle/data/datasources/remote/moment_remote_datasource.dart';
import 'package:time_circle/data/datasources/local/moment_local_datasource.dart';
import 'package:time_circle/domain/entities/moment.dart';

// Mock classes
class MockMomentRemoteDataSource extends Mock
    implements MomentRemoteDataSource {}

class MockMomentLocalDataSource extends Mock implements MomentLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// Fake classes for registerFallbackValue
class FakeMoment extends Fake implements Moment {}

class FakeCacheInfo extends Fake implements CacheInfo {}
