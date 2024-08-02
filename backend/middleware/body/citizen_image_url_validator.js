// Validate citizen image url
const citizenImageUrlValidator = (req, res, next) => {
  console.log("Citizen image url validator middleware:");
  console.log("- Front url: " + req.body.citizen_image_url_front);
  console.log("- Back url: " + req.body.citizen_image_url_back);

  try {
    const { citizen_image_url_front, citizen_image_url_back } = req.body;

    if (!citizen_image_url_front || !citizen_image_url_back) {
      return res.status(400).json({ msg: "Citizen image url is required." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default citizenImageUrlValidator;
