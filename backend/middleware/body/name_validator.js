// Validate name
const nameValidator = (req, res, next) => {
  console.log("Name validator middleware:");
  console.log("- Name: " + req.body.name);

  try {
    const name = req.body.name;

    if (!name) {
      return res.status(400).json({ msg: "Name is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default nameValidator;
