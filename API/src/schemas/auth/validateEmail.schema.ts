import { z } from "zod";

export const ValidateEmailSchema = z.object({
  email: z.string().email(),
  role: z.enum(["player", "manager"]).default("player"),
});
