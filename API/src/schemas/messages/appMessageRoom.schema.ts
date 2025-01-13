import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";

export const AppMessageRoomSchema = new mongoose.Schema({
  roomName: {
    type: String,
    trim: true,
  },
  roomImage: FileSchema,
  type: {
    type: String,
    trim: true,
    default: "personal",
  },
  users: [{ type: String }],
  createdAt: {
    type: Number,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    default: Date.now(),
  },
});
