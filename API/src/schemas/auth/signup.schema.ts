import { z } from "zod";

export const SignupSchema = z.object({
  username: z.string().min(6),
  email: z.string().email(),
  password: z.string().min(8).max(50),
  imageUrl: z.string().optional(),
  role: z.enum(["player", "manager"]).default("player"),
});
