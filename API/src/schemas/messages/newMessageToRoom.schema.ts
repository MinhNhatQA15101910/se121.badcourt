import { z } from "zod";

export const NewMessageToRoomSchema = z.object({
  roomId: z.string(),
  content: z.string(),
});
