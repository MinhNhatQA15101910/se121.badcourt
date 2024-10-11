import { z } from "zod";

export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export const ValidateEmailSchema = z.object({
  email: z.string().email(),
});

export const SendVerifyEmailSchema = z.object({
  email: z.string().email(),
  pincode: z.string().length(6).regex(/^\d+$/),
});
