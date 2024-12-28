import { z } from "zod";

export const ChangePasswordSchema = z.object({
  currentPassword: z.string().min(8).max(50),
  newPassword: z.string().min(8).max(50),
});
