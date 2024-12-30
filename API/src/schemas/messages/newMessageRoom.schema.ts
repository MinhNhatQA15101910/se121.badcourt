import { z } from "zod";

export const NewMessageRoomSchema = z.object({
  roomName: z.string().optional(),
  users: z.array(z.string()).min(1),
});
