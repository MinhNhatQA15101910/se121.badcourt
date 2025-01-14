import { FileDto } from "../files/file.dto";

export class ManagerInfoDto {
  fullName: string = "";
  email: string = "";
  phoneNumber: string = "";
  citizenId: string = "";
  citizenImageFront?: FileDto;
  citizenImageBack?: FileDto;
  bankCardFront?: FileDto;
  bankCardBack?: FileDto;
  businessLicenseImages: FileDto[] = [];

  public static mapFrom(managerInfo: any): ManagerInfoDto {
    return new ManagerInfoDto(managerInfo);
  }

  private constructor(managerInfo: any) {
    this.fullName = managerInfo === null ? "" : managerInfo.fullName;
    this.email = managerInfo === null ? "" : managerInfo.email;
    this.phoneNumber = managerInfo === null ? "" : managerInfo.phoneNumber;
    this.citizenId = managerInfo === null ? "" : managerInfo.citizenId;
    this.citizenImageFront =
      managerInfo === null
        ? undefined
        : FileDto.mapFrom(managerInfo.citizenImageFront);
    this.citizenImageBack =
      managerInfo === null
        ? undefined
        : FileDto.mapFrom(managerInfo.citizenImageBack);
    this.bankCardFront =
      managerInfo === null
        ? undefined
        : FileDto.mapFrom(managerInfo.bankCardFront);
    this.bankCardBack =
      managerInfo === null
        ? undefined
        : FileDto.mapFrom(managerInfo.bankCardBack);
    this.businessLicenseImages =
      managerInfo === null
        ? []
        : managerInfo.businessLicenseImages.map((file: any) =>
            FileDto.mapFrom(file)
          );
  }
}
