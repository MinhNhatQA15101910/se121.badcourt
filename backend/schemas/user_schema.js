import mongoose from "mongoose";

const userSchema = mongoose.Schema({
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
  image_url: {
    type: String,
    trim: true,
  },
  role: {
    type: String,
    trim: true,
    default: "player",
  },
});

export default userSchema;
