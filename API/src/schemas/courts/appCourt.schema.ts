// import mongoose from "mongoose";

// const AppFacilitySchema = new mongoose.Schema({
//   facilityId: {
//     required: true,
//     type: String,
//     trim: true,
//   },
//   courtName: {
//     required: true,
//     type: String,
//     trim: true,
//   },
//   description: { type: String, trim: true, required: true },
//   policy: { type: String, trim: true, required: true },
//   courtsAmount: {
//     type: Number,
//     default: 0,
//   },
//   minPrice: {
//     type: Number,
//     default: 0,
//   },
//   maxPrice: {
//     type: Number,
//     default: 0,
//   },
//   detailAddress: {
//     required: true,
//     type: String,
//     trim: true,
//   },
//   province: {
//     required: true,
//     type: String,
//     trim: true,
//   },
//   location: {
//     type: { type: String, enum: ["Point"], required: true },
//     coordinates: { type: [Number], required: true },
//   },
//   ratingAvg: {
//     type: Number,
//     default: 0,
//   },
//   totalRating: {
//     type: Number,
//     default: 0,
//   },
//   activeAt: { type: ActiveSchema, default: null },
//   createdAt: {
//     type: Number,
//     required: true,
//     default: Date.now(),
//   },
//   facilityImages: [FileSchema],
//   managerInfo: ManagerInfoSchema,
//   state: {
//     type: String,
//     trim: true,
//     default: "Pending",
//   },
//   updatedAt: {
//     type: Number,
//     required: true,
//     default: Date.now(),
//   },
// });
