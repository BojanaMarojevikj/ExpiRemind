import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPENAI_API_KEY')
  static const String openaiApiKey = _Env.openaiApiKey;

  @EnviedField(varName: 'BARCODE_LOOKUP_API_KEY')
  static const String barcodeLookupApiKey = _Env.barcodeLookupApiKey;
}
