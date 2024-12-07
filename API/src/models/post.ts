import mongoose from "mongoose";
import { AppPostSchema } from "../schemas/post/appPost";

const Post = mongoose.model("Post", AppPostSchema);

export default Post;
