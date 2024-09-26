import "reflect-metadata";
import express, { Express } from "express";
import { PORT } from "./secrets";

const app: Express = express();

app.use(express.json());

app.listen(PORT, () => {
  console.log(`Server is running on: http://localhost:${PORT}`);
});
