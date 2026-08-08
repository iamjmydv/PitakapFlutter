import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pitakapflutter/core/providers/app_providers.dart';
import 'package:pitakapflutter/core/resources/keys.dart';

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    return ref
            .watch(sharedPreferencesProvider)
            .getBool(Keys.prefsOnboardingSeen) ??
        false;
  }

  Future<void> markSeen() async {
    state = true;
    await ref
        .read(sharedPreferencesProvider)
        .setBool(Keys.prefsOnboardingSeen, true);
  }
}

final onboardingSeenProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);
