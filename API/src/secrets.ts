import dotenv from "dotenv";

dotenv.config({ path: ".env" });

export const PORT = process.env.PORT;
export const SALT_ROUNDS = process.env.SALT_ROUNDS!;
export const DB_URL = process.env.DB_URL!;
export const JWT_SECRET = process.env.JWT_SECRET!;
export const BADCOURT_EMAIL = process.env.BADCOURT_EMAIL!;
export const BADCOURT_DISPLAY_NAME = process.env.BADCOURT_DISPLAY_NAME!;
export const BADCOURT_PASSWORD = process.env.BADCOURT_PASSWORD!;
