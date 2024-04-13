import mongoose from "mongoose";

import userSchema from "../schemas/user_schema.js";

const User = mongoose.model("User", userSchema);
export default User;
