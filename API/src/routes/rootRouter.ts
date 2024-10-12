import { Router } from "express";
import authRoutes from "./authRoutes";
import userRoutes from "./userRoutes";

const rootRouter: Router = Router();

rootRouter.use("/auth", authRoutes);
rootRouter.use("/users", userRoutes);

export default rootRouter;
