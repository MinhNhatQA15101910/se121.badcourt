import mongoose from "mongoose";

export const FileSchema = new mongoose.Schema({
  url: {
    required: true,
    type: String,
    trim: true,
  },
  isMain: {
    required: true,
    type: Boolean,
    default: true,
  },
  publicId: {
    required: true,
    type: String,
    trim: true,
  },
});
