import mongoose from "mongoose";
import { AppUserSchema } from "../schemas/user/appUser";

const User = mongoose.model("User", AppUserSchema);

export default User;
