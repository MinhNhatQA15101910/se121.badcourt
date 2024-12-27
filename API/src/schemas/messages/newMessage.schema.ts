import { z } from "zod";

export const NewMessageSchema = z.object({
  recipientId: z.string(),
  content: z.string(),
});
