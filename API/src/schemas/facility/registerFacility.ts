import { z } from "zod";

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
