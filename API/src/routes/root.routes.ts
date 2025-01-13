import { Router } from "express";
import authRoutes from "./auth.routes";
import userRoutes from "./user.routes";
import facilityRoutes from "./facility.routes";
import postRoutes from "./post.routes";
import commentRoutes from "./comment.routes";
import messageRoutes from "./message.routes";
import courtRoutes from "./court.routes";

const rootRoutes: Router = Router();

rootRoutes.use("/auth", authRoutes);
rootRoutes.use("/comments", commentRoutes);
rootRoutes.use("/courts", courtRoutes);
rootRoutes.use("/facilities", facilityRoutes);
rootRoutes.use("/messages", messageRoutes);
rootRoutes.use("/posts", postRoutes);
rootRoutes.use("/users", userRoutes);

export default rootRoutes;
