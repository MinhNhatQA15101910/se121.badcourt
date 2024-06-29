import jwt from "jsonwebtoken";

import User from "../../models/user.js";

const playerValidator = async (req, res, next) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) {
      return res.status(401).json({ msg: "No auth token, access denied." });
    }

    const verified = jwt.verify(token, process.env.PASSWORD_KEY);
    if (!verified) {
      return res
        .status(401)
        .json({ msg: "Token verification failed, authorization denied." });
    }

    const user = await User.findById(verified.id);
    if (user.role === "manager") {
      return res.status(401).json({ msg: "You are not a player!" });
    }

    req.user = verified.id;
    req.token = token;

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default playerValidator;
