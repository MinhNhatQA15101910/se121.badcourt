import { injectable } from "inversify";
import { IMailService } from "../interfaces/services/IMail.service";
import nodemailer, { Transporter } from "nodemailer";
import {
  BADCOURT_DISPLAY_NAME,
  BADCOURT_EMAIL,
  BADCOURT_PASSWORD,
} from "../secrets";
import fs from "fs";

@injectable()
export class MailService implements IMailService {
  private _transporter: Transporter;

  constructor() {
    this._transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465,
      secure: true,
      auth: {
        user: BADCOURT_EMAIL,
        pass: BADCOURT_PASSWORD,
      },
    });
  }

  sendVerifyEmail(
    email: string,
    pincode: string,
    callback: (err: Error | null, info: any) => void
  ): void {
    const html = fs
      .readFileSync("assets/emailContent.html", "utf8")
      .replace("{{pincode}}", pincode)
      .replace("{{hideEmail}}", this.hideEmail(email));

    var mailOptions = {
      from: {
        name: BADCOURT_DISPLAY_NAME,
        address: BADCOURT_EMAIL,
      },
      to: email,
      subject: "BADCOURT ACCOUNT VERIFICATION",
      html,
    };

    this._transporter.sendMail(mailOptions, callback);
  }

  private hideEmail(email: string) {
    const [username, domain] = email.split("@");
    const hiddenUsername = `${username[0]}${"*".repeat(username.length - 2)}${
      username[username.length - 1]
    }`;
    return `${hiddenUsername}@${domain}`;
  }
}
