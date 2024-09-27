import mongoose from "mongoose";
import { UserSchema } from "../schemas/users";

const User = mongoose.model("User", UserSchema);

export default User;
