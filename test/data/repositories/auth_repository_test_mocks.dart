import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<PostgrestList> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<PostgrestList> {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class FakeFile extends Fake implements File {}

class FakeFileOptions extends Fake implements FileOptions {}

class FakePostgrestMapTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final Future<PostgrestMap> _future;

  FakePostgrestMapTransformBuilder(PostgrestMap response)
    : _future = Future.value(response);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

class FakePostgrestNullableMapTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap?> {
  final Future<PostgrestMap?> _future;

  FakePostgrestNullableMapTransformBuilder(PostgrestMap? response)
    : _future = Future.value(response);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap? value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

class FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<PostgrestList> {
  final Future<PostgrestList> _future;

  FakePostgrestFilterBuilder([PostgrestList? response])
    : _future = Future.value(response ?? []);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

class FakePostgrestErrorTransformBuilder extends Fake
    implements PostgrestTransformBuilder<PostgrestMap> {
  final Future<PostgrestMap> _future;

  FakePostgrestErrorTransformBuilder(Object error)
    : _future = Future<PostgrestMap>.error(error);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestMap value) onValue, {
    Function? onError,
  }) {
    return _future.then(onValue, onError: onError);
  }
}

void registerAuthRepositoryTestFallbacks() {
  registerFallbackValue(FakeFile());
  registerFallbackValue(const FileOptions());
}
