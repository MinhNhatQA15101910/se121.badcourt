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
  createdAt: {
    type: Number,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    default: Date.now(),
  },
});
