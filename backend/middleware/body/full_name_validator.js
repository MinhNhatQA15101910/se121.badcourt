// Validate full name
const fullNameValidator = (req, res, next) => {
  console.log("Full name validator middleware:");
  console.log("- Full name: " + req.body.full_name);

  try {
    const fullName = req.body.full_name;

    if (!fullName) {
      return res.status(400).json({ msg: "Full name is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default fullNameValidator;
