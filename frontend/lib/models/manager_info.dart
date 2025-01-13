import 'package:frontend/models/image_custom.dart';

class ManagerInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String citizenId;
  final ImageCustom citizenImageFront;
  final ImageCustom citizenImageBack;
  final ImageCustom bankCardFront;
  final ImageCustom bankCardBack;
  final List<ImageCustom> businessLicenseImages;

  ManagerInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.citizenId,
    required this.citizenImageFront,
    required this.citizenImageBack,
    required this.bankCardFront,
    required this.bankCardBack,
    required this.businessLicenseImages,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'citizenId': citizenId,
      'citizenImageFront': citizenImageFront.toMap(),
      'citizenImageBack': citizenImageBack.toMap(),
      'bankCardFront': bankCardFront.toMap(),
      'bankCardBack': bankCardBack.toMap(),
      'businessLicenseImages':
          businessLicenseImages.map((img) => img.toMap()).toList(),
    };
  }

  ManagerInfo copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? citizenId,
    ImageCustom? citizenImageFront,
    ImageCustom? citizenImageBack,
    ImageCustom? bankCardFront,
    ImageCustom? bankCardBack,
    List<ImageCustom>? businessLicenseImages,
  }) {
    return ManagerInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      citizenId: citizenId ?? this.citizenId,
      citizenImageFront: citizenImageFront ?? this.citizenImageFront,
      citizenImageBack: citizenImageBack ?? this.citizenImageBack,
      bankCardFront: bankCardFront ?? this.bankCardFront,
      bankCardBack: bankCardBack ?? this.bankCardBack,
      businessLicenseImages:
          businessLicenseImages ?? this.businessLicenseImages,
    );
  }

  factory ManagerInfo.fromMap(Map<String, dynamic> map) {
    return ManagerInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      citizenId: map['citizenId'] ?? '',
      citizenImageFront: ImageCustom.fromMap(map['citizenImageFront'] ?? {}),
      citizenImageBack: ImageCustom.fromMap(map['citizenImageBack'] ?? {}),
      bankCardFront: ImageCustom.fromMap(map['bankCardFront'] ?? {}),
      bankCardBack: ImageCustom.fromMap(map['bankCardBack'] ?? {}),
      businessLicenseImages: List<ImageCustom>.from(
        (map['businessLicenseImages'] ?? [])
            .map((img) => ImageCustom.fromMap(img)),
      ),
    );
  }
}
