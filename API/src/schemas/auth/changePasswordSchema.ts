import { z } from "zod";

export const ChangePasswordSchema = z.object({
  email: z.string().email(),
  role: z.enum(["player", "manager"]).default("player"),
  newPassword: z.string().min(8).max(50),
});
