import mongoose from "mongoose";
import { AppPostSchema } from "../schemas/posts/appPost";

const Post = mongoose.model("Post", AppPostSchema);

export default Post;
