import mongoose from "mongoose";
import { AppPostSchema } from "../schemas/posts/appPost.schema";

const Post = mongoose.model("Post", AppPostSchema);

export default Post;
