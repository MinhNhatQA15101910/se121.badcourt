import mongoose from "mongoose";

const AppCommentSchema = new mongoose.Schema({
  userId: {
    required: true,
    type: String,
    trim: true,
  },
  postId: {
    required: true,
    type: String,
    trim: true,
  },
  content: {
    required: true,
    type: String,
    trim: true,
  },
  likesCount: {
    type: Number,
    default: 0,
  },
  createdAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
  updatedAt: {
    type: Number,
    required: true,
    default: Date.now(),
  },
});

export default AppCommentSchema;
