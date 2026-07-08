class User {
  final String id;
  final String name;
  final double walletBalance;
  final String kycLevel;

  const User({
    required this.id,
    required this.name,
    required this.walletBalance,
    required this.kycLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      walletBalance: (json['wallet_balance'] as num).toDouble(),
      kycLevel: json['kyc_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wallet_balance': walletBalance,
      'kyc_level': kycLevel,
    };
  }
}
