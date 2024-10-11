import { z } from "zod";

export const SignupSchema = z.object({
  username: z.string().min(6),
  email: z.string().email(),
  password: z.string().min(8),
  imageUrl: z.string().optional(),
  role: z.enum(["player", "manager"]).default("player"),
});

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
