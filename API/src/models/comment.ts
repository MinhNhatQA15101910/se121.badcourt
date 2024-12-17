import mongoose from "mongoose";
import AppCommentSchema from "../schemas/comments/appComment.schema";

const Comment = mongoose.model("Comment", AppCommentSchema);

export default Comment;
