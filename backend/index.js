import env from "dotenv";
import express from "express";
import mongoose from "mongoose";

import authRouter from "./routers/auth_router.js";

import facilityRouter from "./routers/manager/facility_router.js";

const app = express();
env.config();

app.use(express.static("public"));
app.use(express.json());

app.use(authRouter);

app.use(facilityRouter);

app.get("/", (req, res) => {
  res.render("index.ejs", { port: process.env.PORT });
});

mongoose
  .connect(process.env.DB_URL)
  .then(() => {
    console.log("Connecting Successfully.");
  })
  .catch((err) => {
    console.log(err);
  });

app.listen(process.env.PORT, "0.0.0.0", () => {
  console.log(`Server running on http://localhost:${process.env.PORT}`);
});
