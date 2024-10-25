import { isValidPhoneNumber } from "libphonenumber-js";
import mongoose from "mongoose";
import activeSchema from "../active/appActive";

const ManagerInfoSchema = new mongoose.Schema({
  full_name: {
    required: true,
    type: String,
    trim: true,
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
      message: "Invalid email address.",
    },
  },
  phone_number: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (phoneNumber) => {
        return isValidPhoneNumber(phoneNumber, "VN");
      },
      message: "Invalid phone number.",
    },
  },
  citizen_id: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (citizenId) => {
        const regex = /^\d{12}$/;
        return regex.test(citizenId);
      },
      message: "Invalid citizen id.",
    },
  },
  citizen_image_url_front: {
    required: true,
    type: String,
    trim: true,
  },
  citizen_image_url_back: {
    required: true,
    type: String,
    trim: true,
  },
  bank_card_url_front: {
    required: true,
    type: String,
    trim: true,
  },
  bank_card_url_back: {
    required: true,
    type: String,
    trim: true,
  },
  business_license_image_urls: [
    {
      required: true,
      type: String,
      trim: true,
    },
  ],
});

export const AppFacilitySchema = new mongoose.Schema({
  user_id: {
    required: true,
    type: String,
    trim: true,
  },
  name: {
    required: true,
    type: String,
    trim: true,
  },
  facebook_url: {
    type: String,
    trim: true,
  },
  description: { type: String, trim: true, required: true },
  policy: { type: String, trim: true, required: true },
  courts_amount: {
    type: Number,
    default: 0,
  },
  min_price: {
    type: Number,
    default: 0,
  },
  max_price: {
    type: Number,
    default: 0,
  },
  detail_address: {
    required: true,
    type: String,
    trim: true,
  },
  province: {
    required: true,
    type: String,
    trim: true,
  },
  location: {
    type: {
      type: String,
      enum: ["Point"],
      required: true,
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  },
  rating_avg: {
    type: Number,
    default: 0,
  },
  total_rating: {
    type: Number,
    default: 0,
  },
  active_at: activeSchema,
  registered_at: {
    type: Number,
    required: true,
  },
  image_urls: [
    {
      required: true,
      type: String,
      trim: true,
    },
  ],
  manager_info: ManagerInfoSchema,
});
AppFacilitySchema.index({ location: "2dsphere" });
