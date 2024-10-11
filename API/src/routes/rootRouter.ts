import { Router } from "express";
import authRoutes from "./authRoutes";

const rootRouter: Router = Router();

rootRouter.use("/auth", authRoutes);

export default rootRouter;
