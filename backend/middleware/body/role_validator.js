const roles = ["player", "manager"];

// Validate role
const roleValidator = (req, res, next) => {
  console.log("Role validator middleware:");
  console.log(`- Role: ${req.body.role}`);

  try {
    let { role } = req.body;

    if (role) {
      if (!roles.includes(role)) {
        return res.status(400).json({ msg: "Invalid role." });
      }
    } else {
      req.body.role = "player";
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default roleValidator;
