import { z } from "zod";

export const NewMessageToUserSchema = z.object({
  recipientId: z.string(),
  content: z.string(),
});
