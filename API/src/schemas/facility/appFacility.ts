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
  latitude: {
    type: Number,
    required: true,
    validate: {
      validator: (latitude: number) => latitude >= -90 && latitude <= 90,
      message: "Invalid latitude. It must be between -90 and 90.",
    },
  },
  longitude: {
    type: Number,
    required: true,
    validate: {
      validator: (longitude: number) => longitude >= -180 && longitude <= 180,
      message: "Invalid longitude. It must be between -180 and 180.",
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
