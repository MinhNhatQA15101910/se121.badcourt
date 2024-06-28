// Validate new password
const newPasswordValidator = (req, res, next) => {
  console.log("New password validator middleware:");
  console.log("- New password: " + req.body.new_password);

  try {
    const newPassword = req.body.new_password;

    if (!newPassword) {
      return res.status(400).json({ msg: "Password is required." });
    }

    let isValid = newPassword.length >= 8;

    if (!isValid) {
      return res
        .status(400)
        .json({ msg: "Password must be at least 8 characters long." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default newPasswordValidator;
