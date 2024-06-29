// Validate description
const descriptionValidator = (req, res, next) => {
  console.log("Description validator middleware:");
  console.log("- Description: " + req.body.description);

  try {
    const description = req.body.description;

    if (!description) {
      return res.status(400).json({ msg: "Description is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default descriptionValidator;
