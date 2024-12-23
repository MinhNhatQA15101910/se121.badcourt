import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";

export const AppMessageRoomSchema = new mongoose.Schema({
  roomName: {
    type: String,
    trim: true,
  },
  roomImage: FileSchema,
  users: [{ type: String }],
  messages: [{ type: String }],
});
