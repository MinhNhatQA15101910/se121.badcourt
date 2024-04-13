import mongoose from "mongoose";

const userSchema = mongoose.Schema({
  firstName: {
    required: true,
    type: String,
    trim: true,
  },
  lastName: {
    required: true,
    type: String,
    trim: true,
  },
  phoneNumber: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        const re = /^\d{10}$/;
        return value.match(re);
      },
      message: "Please enter a valid phone number.",
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
      message: "Please enter a long password",
    },
  },
  role: {
    type: String,
    trim: true,
    default: "user",
  },
});

export default userSchema;
