enum TransactionStatus { successful, pending, failed, reversed }

enum TransactionDirection { credit, debit }

enum TransactionType {
  walletFunding,
  withdrawal,
  giftCardTrade,
  cryptoTrade;

  String get displayName {
    switch (this) {
      case TransactionType.walletFunding:
        return 'Wallet Funding';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.giftCardTrade:
        return 'Gift Card Trade';
      case TransactionType.cryptoTrade:
        return 'Crypto Trade';
    }
  }

  static TransactionType fromString(String value) {
    switch (value) {
      case 'wallet_funding':
        return TransactionType.walletFunding;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'gift_card_trade':
        return TransactionType.giftCardTrade;
      case 'crypto_trade':
        return TransactionType.cryptoTrade;
      default:
        throw ArgumentError('Unknown transaction type: $value');
    }
  }
}

class Transaction {
  final String id;
  final String reference;
  final String title;
  final double amount;
  final double fee;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionDirection direction;
  final String description;
  final String date;
  final bool hasActiveReport;

  const Transaction({
    required this.id,
    required this.reference,
    required this.title,
    required this.amount,
    required this.fee,
    required this.type,
    required this.status,
    required this.direction,
    required this.description,
    required this.date,
    required this.hasActiveReport,
  });

  bool get canBeReported =>
      (status == TransactionStatus.successful ||
          status == TransactionStatus.pending) &&
      !hasActiveReport;

  String? get reportBlockedReason {
    if (hasActiveReport) {
      return 'This transaction already has an active report.';
    }
    if (status == TransactionStatus.failed) {
      return 'This transaction cannot be reported because it failed.';
    }
    if (status == TransactionStatus.reversed) {
      return 'This transaction cannot be reported because it was reversed.';
    }
    return null;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      reference: json['reference'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      type: TransactionType.fromString(json['type'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
      ),
      direction: TransactionDirection.values.firstWhere(
        (e) => e.name == (json['direction'] as String),
      ),
      description: json['description'] as String,
      date: json['date'] as String,
      hasActiveReport: json['has_active_report'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'title': title,
      'amount': amount,
      'fee': fee,
      'type': type.name,
      'status': status.name,
      'direction': direction.name,
      'description': description,
      'date': date,
      'has_active_report': hasActiveReport,
    };
  }

  Transaction copyWith({
    String? id,
    String? reference,
    String? title,
    double? amount,
    double? fee,
    TransactionType? type,
    TransactionStatus? status,
    TransactionDirection? direction,
    String? description,
    String? date,
    bool? hasActiveReport,
  }) {
    return Transaction(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      type: type ?? this.type,
      status: status ?? this.status,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      date: date ?? this.date,
      hasActiveReport: hasActiveReport ?? this.hasActiveReport,
    );
  }
}
