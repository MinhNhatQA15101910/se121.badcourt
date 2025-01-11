class ManagerInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String citizenId;
  final String citizenImageUrlFront;
  final String citizenImageUrlBack;
  final String bankCardUrlFront;
  final String bankCardUrlBack;
  final List<String> businessLicenseImageUrls;
  final String id;

  ManagerInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.citizenId,
    required this.citizenImageUrlFront,
    required this.citizenImageUrlBack,
    required this.bankCardUrlFront,
    required this.bankCardUrlBack,
    required this.businessLicenseImageUrls,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'citizenId': citizenId,
      'citizenImageUrlFront': citizenImageUrlFront,
      'citizenImageUrlBack': citizenImageUrlBack,
      'bankCardUrlFront': bankCardUrlFront,
      'bankCardUrlBack': bankCardUrlBack,
      'businessLicenseImageUrls': businessLicenseImageUrls,
      '_id': id,
    };
  }

  factory ManagerInfo.fromMap(Map<String, dynamic> map) {
    return ManagerInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      citizenId: map['citizenId'] ?? '',
      citizenImageUrlFront: map['citizenImageUrlFront'] ?? '',
      citizenImageUrlBack: map['citizenImageUrlBack'] ?? '',
      bankCardUrlFront: map['bankCardUrlFront'] ?? '',
      bankCardUrlBack: map['bankCardUrlBack'] ?? '',
      businessLicenseImageUrls:
          List<String>.from(map['businessLicenseImageUrls'] ?? []),
      id: map['_id'] ?? '',
    );
  }

  ManagerInfo copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? citizenId,
    String? citizenImageUrlFront,
    String? citizenImageUrlBack,
    String? bankCardUrlFront,
    String? bankCardUrlBack,
    List<String>? businessLicenseImageUrls,
    String? id,
  }) {
    return ManagerInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      citizenId: citizenId ?? this.citizenId,
      citizenImageUrlFront: citizenImageUrlFront ?? this.citizenImageUrlFront,
      citizenImageUrlBack: citizenImageUrlBack ?? this.citizenImageUrlBack,
      bankCardUrlFront: bankCardUrlFront ?? this.bankCardUrlFront,
      bankCardUrlBack: bankCardUrlBack ?? this.bankCardUrlBack,
      businessLicenseImageUrls:
          businessLicenseImageUrls ?? this.businessLicenseImageUrls,
      id: id ?? this.id,
    );
  }
}
