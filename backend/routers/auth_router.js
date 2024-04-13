import bcryptjs from "bcryptjs";
import env from "dotenv";
import express from "express";

import User from "../models/user.js";

const authRouter = express.Router();

// Sign up route
authRouter.post("/user/signup", async (req, res) => {
  try {
    const { firstName, lastName, phoneNumber, email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res
        .status(400)
        .json({ msg: "User with the same email already exists!" });
    }

    if (password.length < 8) {
      return res.status(400).json({ msg: "Password too short!" });
    }

    const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
      firstName,
      lastName,
      phoneNumber,
      email,
      password: hashedPassword,
    });
    user = await user.save();
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default authRouter;
