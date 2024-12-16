import { z } from "zod";

export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(50),
  role: z.enum(["player", "manager", "admin"]).default("player"),
});
