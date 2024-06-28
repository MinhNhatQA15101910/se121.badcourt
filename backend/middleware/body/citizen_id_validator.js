// Validate citizen id
const citizenIdValidator = (req, res, next) => {
  console.log("Citizen id validator middleware:");
  console.log("- Citizen id: " + req.body.citizen_id);

  try {
    const citizenId = req.body.citizen_id;

    if (!citizenId) {
      return res.status(400).json({ msg: "Citizen id is required." });
    }

    const regex = /^\d{14}$/;
    if (!regex.text(citizenId)) {
      return res.status(400).json({ msg: "Invalid citizen id." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default citizenIdValidator;
