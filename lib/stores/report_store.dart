import 'package:mobx/mobx.dart';
import 'package:pgold_app/models/report.dart';
import 'package:pgold_app/services/api_service.dart';

part 'report_store.g.dart';

class ReportStore = _ReportStore with _$ReportStore;

abstract class _ReportStore with Store {
  final ApiService _apiService;

  _ReportStore(this._apiService);

  @observable
  ReportReason? selectedReason;

  @observable
  String description = '';

  @observable
  bool isSubmitting = false;

  @observable
  String? submissionError;

  @observable
  Report? submittedReport;

  @computed
  int get descriptionCharCount => description.length;

  @computed
  String? get descriptionError {
    if (description.isEmpty) return null;
    if (description.length < 20) {
      return 'Description must be at least 20 characters.';
    }
    if (description.length > 250) {
      return 'Description must not exceed 250 characters.';
    }
    return null;
  }

  @computed
  bool get isFormValid =>
      selectedReason != null &&
      description.length >= 20 &&
      description.length <= 250;

  @action
  void setReason(ReportReason reason) {
    selectedReason = reason;
  }

  @action
  void setDescription(String value) {
    description = value;
  }

  @action
  Future<void> submitReport(String transactionId) async {
    if (!isFormValid || isSubmitting) return;

    isSubmitting = true;
    submissionError = null;

    final result = await _apiService.submitTransactionReport(
      transactionId: transactionId,
      reason: selectedReason!,
      description: description,
    );

    result.when(
      success: (report) {
        submittedReport = report;
        isSubmitting = false;
      },
      failure: (message) {
        submissionError = message;
        isSubmitting = false;
      },
    );
  }

  @action
  void reset() {
    selectedReason = null;
    description = '';
    isSubmitting = false;
    submissionError = null;
    submittedReport = null;
  }
}
