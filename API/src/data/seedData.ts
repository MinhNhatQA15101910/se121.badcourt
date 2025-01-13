import mongoose from "mongoose";
import User from "../models/user";
import { userData } from "./data";
import { hashSync } from "bcrypt";
import {
  CLOUDINARY_API_KEY,
  CLOUDINARY_API_SECRET,
  CLOUDINARY_CLOUD_NAME,
  SALT_ROUNDS,
} from "../secrets";
import { v2 as cloudinary } from "cloudinary";

cloudinary.config({
  cloud_name: CLOUDINARY_CLOUD_NAME,
  api_key: CLOUDINARY_API_KEY,
  api_secret: CLOUDINARY_API_SECRET,
});

export const seedData = async () => {
  try {
    await seedUsers();
  } catch (error) {
    console.error("Error seeding data:", error);
    mongoose.connection.close();
  }
};

const seedUsers = async () => {
  const users = await User.find();
  if (users.length === 0) {
    let index = 1;
    for (let user of userData) {
      user.password = hashSync("Pa$$w0rd", +SALT_ROUNDS);
      let newUser = new User(user);
      newUser = await newUser.save();

      const result = await cloudinary.uploader.upload(
        `src/data/resources/users/${index}.jpg`,
        {
          folder: `BadCourt-prod/users/${newUser._id}`,
          resource_type: "image",
        }
      );

      newUser.image = {
        url: result.url,
        publicId: result.public_id,
        isMain: true,
        type: "image",
      };
      await newUser.save();
    }
    console.log("Users seeded successfully");
  }
};
