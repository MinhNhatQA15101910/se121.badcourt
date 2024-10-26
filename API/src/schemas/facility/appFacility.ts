import { isValidPhoneNumber } from "libphonenumber-js";
import mongoose from "mongoose";
import { FileSchema } from "../file/fileSchema";
import ActiveSchema from "../active/appActive";

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
  citizenImageFront: FileSchema,
  citizenImageBack: FileSchema,
  bankCardFront: FileSchema,
  bankCardBack: FileSchema,
  businessLicenseImages: [FileSchema],
});

const AppFacilitySchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  name: {
    required: true,
    type: String,
    trim: true,
  },
  facebookUrl: {
    type: String,
    trim: true,
  },
  description: { type: String, trim: true, required: true },
  policy: { type: String, trim: true, required: true },
  courtsAmount: {
    type: Number,
    default: 0,
  },
  minPrice: {
    type: Number,
    default: 0,
  },
  maxPrice: {
    type: Number,
    default: 0,
  },
  detailAddress: {
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
  ratingAvg: {
    type: Number,
    default: 0,
  },
  totalRating: {
    type: Number,
    default: 0,
  },
  activeAt: ActiveSchema,
  registeredAt: {
    type: Number,
    required: true,
    default: new Date(),
  },
  facilityImages: [FileSchema],
  managerInfo: ManagerInfoSchema,
  isApproved: {
    type: Boolean,
    default: false,
  },
});
AppFacilitySchema.index({ location: "2dsphere" });

export default AppFacilitySchema;
