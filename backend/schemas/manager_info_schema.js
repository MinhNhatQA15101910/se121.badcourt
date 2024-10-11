import { isValidPhoneNumber } from "libphonenumber-js";
import mongoose from "mongoose";

const managerInfoSchema = mongoose.Schema({
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

export default managerInfoSchema;
