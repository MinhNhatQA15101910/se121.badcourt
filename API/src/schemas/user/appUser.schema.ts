import mongoose from "mongoose";
import { FileSchema } from "../file/file.schema";

export const AppUserSchema = new mongoose.Schema({
  username: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        return value.length >= 6;
      },
      message: "Username must be at least 6 characters long.",
    },
  },
  email: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return value.match(re);
      },
      message: "Please enter a valid email address.",
    },
  },
  password: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        return value.length >= 8;
      },
      message: "Password must be at least 8 characters long.",
    },
  },
  image: FileSchema,
  role: {
    type: String,
    trim: true,
    default: "player",
  },
  likedPosts: [{ type: String }],
  likedComments: [{ type: String }],
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
