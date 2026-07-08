import 'package:mobx/mobx.dart';
import 'package:pgold_app/services/api_service.dart';

part 'pin_store.g.dart';

class PinStore = _PinStore with _$PinStore;

abstract class _PinStore with Store {
  final ApiService _apiService;

  _PinStore(this._apiService);

  @observable
  String pinDigits = '';

  @observable
  int attempts = 0;

  @observable
  bool isVerifying = false;

  @observable
  String? verificationError;

  @observable
  bool isVerified = false;

  @computed
  bool get isLocked => attempts >= 3;

  @computed
  int get remainingAttempts => 3 - attempts;

  @computed
  int get pinLength => pinDigits.length;

  @computed
  bool get canAttempt => !isLocked && !isVerifying;

  @action
  void addDigit(String digit) {
    if (pinDigits.length >= 4 || isLocked) return;
    pinDigits += digit;
    verificationError = null;
  }

  @action
  void removeDigit() {
    if (pinDigits.isEmpty) return;
    pinDigits = pinDigits.substring(0, pinDigits.length - 1);
    verificationError = null;
  }

  @action
  Future<void> verifyPin() async {
    if (!canAttempt || pinDigits.length != 4) return;

    isVerifying = true;
    verificationError = null;

    final result = await _apiService.verifyTransactionPin(pinDigits);

    result.when(
      success: (_) {
        isVerified = true;
        isVerifying = false;
        pinDigits = '';
      },
      failure: (message) {
        attempts++;
        verificationError = message;
        isVerifying = false;
        pinDigits = '';
      },
    );
  }

  @action
  void reset() {
    pinDigits = '';
    attempts = 0;
    isVerifying = false;
    verificationError = null;
    isVerified = false;
  }
}
