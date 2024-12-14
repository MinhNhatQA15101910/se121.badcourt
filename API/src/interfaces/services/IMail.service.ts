export interface IMailService {
  sendVerifyEmail(
    email: string,
    pincode: string,
    callback: (err: Error | null, info: any) => void
  ): void;
}
