import env from "dotenv";
import express from "express";
import mongoose from "mongoose";

const app = express();
env.config();

app.use(express.static("public"));

app.get("/document", (req, res) => {
  res.render("index.ejs", { port: process.env.PORT });
});

mongoose
  .connect(process.env.DB)
  .then(() => {
    console.log("Connecting Successfully.");
  })
  .catch((err) => {
    console.log(err);
  });

app.listen(process.env.PORT, "0.0.0.0", () => {
  console.log(`Server running on http://localhost:${process.env.PORT}`);
});
