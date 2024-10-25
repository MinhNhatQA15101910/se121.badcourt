import "reflect-metadata";
import express, { Express } from "express";
import { DB_URL, PORT } from "./secrets";
import rootRouter from "./routes/rootRouter";
import { errorMiddleware } from "./middlewares/errorMiddleware";
import mongoose from "mongoose";

const app: Express = express();

app.use(express.json());

app.use("/api", rootRouter);

app.use(errorMiddleware);

mongoose
  .connect(DB_URL)
  .then(() => {
    console.log("Connecting Successfully.");
  })
  .catch((err) => {
    console.log(err);
  });

app.listen(PORT, () => {
  console.log(`Server is running on: http://localhost:${PORT}`);
});
