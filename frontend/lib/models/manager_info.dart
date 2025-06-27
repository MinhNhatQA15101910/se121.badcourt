import 'package:frontend/models/file_dto.dart';

class ManagerInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String citizenId;
  final FileDto citizenImageFront;
  final FileDto citizenImageBack;
  final FileDto bankCardFront;
  final FileDto bankCardBack;
  final List<FileDto> businessLicenseImages;

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
    FileDto? citizenImageFront,
    FileDto? citizenImageBack,
    FileDto? bankCardFront,
    FileDto? bankCardBack,
    List<FileDto>? businessLicenseImages,
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
      citizenImageFront: FileDto.fromMap(map['citizenImageFront'] ?? {}),
      citizenImageBack: FileDto.fromMap(map['citizenImageBack'] ?? {}),
      bankCardFront: FileDto.fromMap(map['bankCardFront'] ?? {}),
      bankCardBack: FileDto.fromMap(map['bankCardBack'] ?? {}),
      businessLicenseImages: List<FileDto>.from(
        (map['businessLicenseImages'] ?? [])
            .map((img) => FileDto.fromMap(img)),
      ),
    );
  }
}
