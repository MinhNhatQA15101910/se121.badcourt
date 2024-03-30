import express from "express";
import env from "dotenv";

const app = express();
env.config();

app.use(express.static("public"));

app.get("/document", (req, res) => {
  res.render("index.ejs", { port: process.env.PORT });
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on http://localhost:${process.env.PORT}`);
});
