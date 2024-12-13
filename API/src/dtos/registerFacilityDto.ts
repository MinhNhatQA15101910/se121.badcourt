import { FileDto } from "./fileDto";

export interface RegisterFacilityDto {
  userId?: string;
  facilityName: string;
  lat: number;
  lon: number;
  description: string;
  policy: string;
  detailAddress: string;
  province: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  citizenId: string;
  facebookUrl?: string | undefined;
  facilityImages?: FileDto[];
  citizenImageFront?: FileDto;
  citizenImageBack?: FileDto;
  bankCardFront?: FileDto;
  bankCardBack?: FileDto;
  businessLicenseImages?: FileDto[];
}
