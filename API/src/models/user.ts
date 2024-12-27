import mongoose from "mongoose";
import { AppUserSchema } from "../schemas/users/appUser.schema";

const User = mongoose.model("User", AppUserSchema);

export default User;
