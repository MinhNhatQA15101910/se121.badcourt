import bcryptjs from "bcryptjs";
import express from "express";
import jwt from "jsonwebtoken";

import User from "../models/user.js";

const authRouter = express.Router();

// Sign up route
authRouter.post("/user/signup", async (req, res) => {
  try {
    const { username, email, password } = req.body;

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
      username,
      email,
      password: hashedPassword,
    });
    user = await user.save();
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Log in route
authRouter.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" });
    }

    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password!" });
    }

    const token = jwt.sign({ id: user._id }, process.env.PASSWORD_KEY);
    res.json({ token, ...user._doc });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Log in with google route
authRouter.post("/login/google", async (req, res) => {
  try {
    const { email, password, username, imageUrl } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      const token = jwt.sign({ id: existingUser._id }, process.env.PASSWORD_KEY);
      res.json({ token, ...existingUser._doc });
    } else {
      const hashedPassword = await bcryptjs.hash(password, 8);

      let user = new User({
        username,
        email,
        password: hashedPassword,
        imageUrl,
      });
      user = await user.save();

      const token = jwt.sign({ id: user._id }, process.env.PASSWORD_KEY);
      res.json({ token, ...user._doc });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default authRouter;
