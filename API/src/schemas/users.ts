import mongoose from "mongoose";
import { z } from "zod";

export const UserSchema = new mongoose.Schema({
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
  imageUrl: {
    type: String,
    trim: true,
  },
  role: {
    type: String,
    trim: true,
    default: "player",
  },
});

export const SignupSchema = z.object({
  username: z.string().min(6),
  email: z.string().email(),
  password: z.string().min(8),
  imageUrl: z.string().optional(),
  role: z.enum(["player", "manager"]).default("player"),
});

export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export const ValidateEmailSchema = z.object({
  email: z.string().email(),
});
