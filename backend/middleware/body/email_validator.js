// Validate email
const emailValidator = (req, res, next) => {
  console.log("Email validator middleware:");
  console.log("- Email: " + req.body.email);

  try {
    const email = req.body.email;

    if (!email) {
      return res.status(400).json({ msg: "Email is required." });
    }

    let isValid = email
      .toLowerCase()
      .match(
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      );

    if (!isValid) {
      return res.status(400).json({ msg: "Invalid email address." });
    }

    next();
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export default emailValidator;
