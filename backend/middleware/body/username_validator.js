// Validate username
const usernameValidator = (req, res, next) => {
  console.log("Username validator middleware:");
  console.log("- Username: " + req.body.username);

  try {
    const username = req.body.username;

    if (!username) {
      return res.status(400).json({ msg: "Username is required." });
    }

    let isValid = username.length >= 6;

    if (!isValid) {
      return res
        .status(400)
        .json({ msg: "Username must be at least 6 characters long." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default usernameValidator;
