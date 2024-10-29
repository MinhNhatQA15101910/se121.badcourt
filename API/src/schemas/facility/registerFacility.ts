import { z } from "zod";

export interface FileDto {
  url: string;
  isMain: boolean;
  publicId: string;
}

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
};

export const RegisterFacilitySchema = z.object({
  facilityName: z.string(),
  lat: z.preprocess(
    (l) => parseFloat(z.string().parse(l)),
    z.number().min(-90).max(90)
  ),
  lon: z.preprocess(
    (l) => parseFloat(z.string().parse(l)),
    z.number().min(-180).max(180)
  ),
  description: z.string(),
  policy: z.string(),
  detailAddress: z.string(),
  province: z.string(),
  facebookUrl: z.string().optional(),
  fullName: z.string(),
  email: z.string().email(),
  phoneNumber: z.string().min(10).regex(/^\d+$/),
  citizenId: z.string().min(12).max(12).regex(/^\d+$/),
});
