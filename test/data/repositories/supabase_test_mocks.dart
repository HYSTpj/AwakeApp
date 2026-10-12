import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabaseリポジトリのテストで共通して使うmocktailのモッククラス群。
/// 複数のテストファイルで同じクラスを別々に定義すると、片方だけ更新して
/// もう片方が古いままになるおそれがあるため、ここに集約している。
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}
