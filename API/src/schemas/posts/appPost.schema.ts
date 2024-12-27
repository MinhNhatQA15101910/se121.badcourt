import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";

export const AppPostSchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  title: { type: String, trim: true, required: true },
  description: { type: String, trim: true, required: true },
  category: { type: String, trim: true, default: "advertise" },
  resources: [FileSchema],
  likesCount: { type: Number, default: 0 },
  likedUsers: [{ type: String }],
  createdAt: {
    type: Number,
    require: true,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    require: true,
    default: Date.now(),
  },
});
