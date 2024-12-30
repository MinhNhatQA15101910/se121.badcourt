import "reflect-metadata";
import express, { Express } from "express";
import { DB_URL, PORT } from "./secrets";
import rootRouter from "./routes/root.routes";
import { errorMiddleware } from "./middlewares/error.middleware";
import mongoose from "mongoose";
import { Server } from "socket.io";
import { socketHandler } from "./websockets/handler";
import cors from "cors";
import { websocketsMiddleware } from "./middlewares/websockets.middleware";

const app: Express = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static("public"));
app.use(cors());

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

const expressServer = app.listen(PORT, () => {
  console.log(`Server is running on: http://localhost:${PORT}`);
});

export const io = new Server(expressServer, {
  cors: {
    origin: "*", // Allow all origins
  },
});

// io.use(websocketsMiddleware);

socketHandler(io);
