enum ReportReason {
  erroneousTransfer,
  suspectedFraud,
  wrongAmount,
  duplicateTransaction,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.erroneousTransfer:
        return 'Erroneous transfer';
      case ReportReason.suspectedFraud:
        return 'Suspected fraud';
      case ReportReason.wrongAmount:
        return 'Wrong amount';
      case ReportReason.duplicateTransaction:
        return 'Duplicate transaction';
      case ReportReason.other:
        return 'Other';
    }
  }
}

class Report {
  final String id;
  final String transactionId;
  final ReportReason reason;
  final String description;
  final String date;

  const Report({
    required this.id,
    required this.transactionId,
    required this.reason,
    required this.description,
    required this.date,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      reason: ReportReason.values.firstWhere(
        (e) => e.name == (json['reason'] as String),
      ),
      description: json['description'] as String,
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'reason': reason.name,
      'description': description,
      'date': date,
    };
  }
}
