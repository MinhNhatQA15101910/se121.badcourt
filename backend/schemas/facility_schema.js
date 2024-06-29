import { isValidPhoneNumber } from "libphonenumber-js";
import mongoose from "mongoose";

import activeSchema from "./active_schema.js";
import managerInfoSchema from "./manager_info_schema.js";

const facilitySchema = mongoose.Schema({
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
  description: { type: String, trim: true, required: true },
  policy: { type: String, trim: true, required: true },
  courts_amount: {
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
      validator: (latitude) => latitude >= -90 && latitude <= 90,
      message: "Invalid latitude. It must be between -90 and 90.",
    },
  },
  longitude: {
    type: Number,
    required: true,
    validate: {
      validator: (longitude) => longitude >= -180 && longitude <= 180,
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
  manager_info: managerInfoSchema,
});

export default facilitySchema;
