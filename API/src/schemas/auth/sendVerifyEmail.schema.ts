import { z } from "zod";

export const SendVerifyEmailSchema = z.object({
  email: z.string().email(),
  pincode: z.string().length(6).regex(/^\d+$/),
});
