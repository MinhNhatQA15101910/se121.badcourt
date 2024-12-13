import mongoose from "mongoose";
import { AppPostSchema } from "../schemas/post/appPostSchema";

const Post = mongoose.model("Post", AppPostSchema);

export default Post;
