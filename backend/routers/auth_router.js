// Packages
import bcryptjs from "bcryptjs";
import express from "express";
import jwt from "jsonwebtoken";
import nodemailer from "nodemailer";

// Models
import User from "../models/user.js";

// Body middleware
import usernameValidator from "../middleware/body/username_validator.js";
import emailValidator from "../middleware/body/email_validator.js";
import passwordValidator from "../middleware/body/password_validator.js";
import roleValidator from "../middleware/body/role_validator.js";
import pincodeValidator from "../middleware/body/pincode_validator.js";
import newPasswordValidator from "../middleware/body/new_password_validator.js";

// Header middleware
import authValidator from "../middleware/header/auth_validator.js";

const authRouter = express.Router();

// Sign up route
authRouter.post(
  "/sign-up",
  usernameValidator,
  emailValidator,
  passwordValidator,
  roleValidator,
  async (req, res) => {
    try {
      const { username, email, password, role } = req.body;

      const existingUser = await User.findOne({ email, role });
      if (existingUser)
        return res
          .status(400)
          .json({ msg: "User with the same email already exists!" });

      const hashedPassword = await bcryptjs.hash(
        password,
        Number(process.env.SALT_ROUNDS)
      );

      let user = new User({
        username,
        email,
        role,
        password: hashedPassword,
      });
      user = await user.save();
      res.json(user);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Login as player route
authRouter.post(
  "/login-as-player",
  emailValidator,
  passwordValidator,
  async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await User.findOne({ email, role: "player" });
      if (!user) {
        return res
          .status(400)
          .json({ msg: "Player with this email does not exist." });
      }

      const isMatch = await bcryptjs.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ msg: "Incorrect password." });
      }

      const token = jwt.sign({ id: user._id }, process.env.PASSWORD_KEY);
      res.json({ token, ...user._doc });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Login as manager route
authRouter.post(
  "/login-as-manager",
  emailValidator,
  passwordValidator,
  async (req, res) => {
    try {
      const { email, password } = req.body;

      const user = await User.findOne({ email, role: "manager" });
      if (!user) {
        return res
          .status(400)
          .json({ msg: "Manager with this email does not exist." });
      }

      const isMatch = await bcryptjs.compare(password, user.password);
      if (!isMatch) {
        return res.status(400).json({ msg: "Incorrect password." });
      }

      const token = jwt.sign({ id: user._id }, process.env.PASSWORD_KEY);
      res.json({ token, ...user._doc });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Log in with google route
authRouter.post(
  "/login/google",
  emailValidator,
  passwordValidator,
  usernameValidator,
  async (req, res) => {
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
  }
);

// Validate email route
authRouter.post("/email-exists", emailValidator, async (req, res) => {
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
authRouter.post(
  "/send-email",
  emailValidator,
  pincodeValidator,
  async (req, res) => {
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
  }
);

// Change password
authRouter.patch(
  "/change-password",
  emailValidator,
  newPasswordValidator,
  async (req, res) => {
    try {
      const { email, new_password } = req.body;
      console.log(req.body);

      let existingUser = await User.findOne({ email });
      if (!existingUser) {
        return res
          .status(400)
          .json({ msg: "User with this email does not exist." });
      }

      const hashedPassword = await bcryptjs.hash(new_password, 8);

      existingUser.password = hashedPassword;

      existingUser = await existingUser.save();
      res.json(existingUser);
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  }
);

// Validate token
authRouter.post("/token-is-valid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");

    if (!token) {
      return res.json(false);
    }

    const verified = jwt.verify(token, process.env.PASSWORD_KEY);
    if (!verified) {
      return res.json(false);
    }

    const user = await User.findById(verified.id);
    if (!user) {
      return res.json(false);
    }

    return res.json(true);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get user data route
authRouter.get("/user", authValidator, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

// Function to hide email characters
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
