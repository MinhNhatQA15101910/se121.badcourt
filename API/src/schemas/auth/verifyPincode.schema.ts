import { z } from "zod";

export const VerifyPincodeSchema = z.object({
  pincode: z.string().min(6).max(6).regex(/^\d+$/),
});
