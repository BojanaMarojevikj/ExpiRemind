import 'package:envied/envied.dart';

part 'env.g.dart';

@envied
abstract class Env {
  @EnviedField(varName: 'OPENAI_API_KEY')
  static const String key = _Env.key;
}