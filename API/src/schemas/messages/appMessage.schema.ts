import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";

export const AppMessageSchema = new mongoose.Schema({
  content: {
    type: String,
    trim: true,
  },
  resources: [FileSchema],
  senderId: {
    required: true,
    type: String,
    trim: true,
  },
  roomId: {
    required: true,
    type: String,
    trim: true,
  },
  createdAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
});
