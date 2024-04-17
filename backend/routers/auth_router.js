import bcryptjs from "bcryptjs";
import express from "express";
import jwt from "jsonwebtoken";
import nodemailer from "nodemailer";

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
      const token = jwt.sign(
        { id: existingUser._id },
        process.env.PASSWORD_KEY
      );
      return res.json({ token, ...existingUser._doc });
    }

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
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Validate email route
authRouter.post("/email-exists", async (req, res) => {
  try {
    const { email } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.json(true);
    }

    res.json(false);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Send verify email route
authRouter.post("/send-email", async (req, res) => {
  try {
    const { email, pincode } = req.body;

    var transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465,
      secure: true,
      auth: {
        user: process.env.BADCOURT_EMAIL,
        pass: process.env.BADCOURT_PASSWORD,
      },
    });

    var mailOptions = {
      from: process.env.BADCOURT_EMAIL,
      to: email,
      subject: "BadCourt account verify code",
      html: `<h2>BadCourt account</h2>
      <h1 style="color:#23C16B;">Verify code</h1>
      <p>
        Please use the following verify code for the BadCourt account:
        ${hideEmailCharacters(email)}
      </p>
      <p>Security code: <b>${pincode}</b></p>
      <p>
        If you didn't request this code, you can safely ignore this email. Someone
        else might have typed your email address by mistake.
      </p>
      <br />
      <p>Thanks,</p>
      <p>The BadCourt development team.</p>`,
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        res.status(500).json({ error: error.message });
      } else {
        res.json({ msg: "Email sent: " + info.response });
      }
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Change password
authRouter.patch("/change-password", async (req, res) => {
  try {
    const { email, newPassword } = req.body;
    console.log(req.body);

    let existingUser = await User.findOne({ email });
    if (!existingUser) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist." });
    }

    const hashedPassword = await bcryptjs.hash(newPassword, 8);

    existingUser.password = hashedPassword;

    existingUser = await existingUser.save();
    res.json(existingUser);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

function hideEmailCharacters(email) {
  const [username, domain] = email.split("@");

  const usernameLength = username.length;

  const hiddenCharactersCount = Math.max(usernameLength - 2, 0);

  const hiddenUsername =
    username.substring(0, 1) +
    "*".repeat(hiddenCharactersCount) +
    username.substring(usernameLength - 1);

  const hiddenEmail = hiddenUsername + "@" + domain;

  return hiddenEmail;
}

export default authRouter;
