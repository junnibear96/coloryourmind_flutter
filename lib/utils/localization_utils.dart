import '../state/app_state.dart';

bool get isKorean => appLocaleNotifier.value.languageCode == 'ko';

String tr(String ko, String en) => isKorean ? ko : en;
