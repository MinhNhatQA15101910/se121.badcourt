import mongoose from "mongoose";
import { FileSchema } from "../files/file.schema";
import { isValidPhoneNumber } from "libphonenumber-js";

const ManagerInfoSchema = new mongoose.Schema({
  fullName: {
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
  phoneNumber: {
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
  citizenId: {
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
  citizenImageFront: { type: FileSchema, default: null },
  citizenImageBack: { type: FileSchema, default: null },
  bankCardFront: { type: FileSchema, default: null },
  bankCardBack: { type: FileSchema, default: null },
  businessLicenseImages: [FileSchema],
});

export default ManagerInfoSchema;
