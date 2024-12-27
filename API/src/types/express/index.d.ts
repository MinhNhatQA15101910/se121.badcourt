export {};

declare global {
  namespace Express {
    export interface Request {
      user?: User;
      email?: string;
      role?: string;
      action?: string;
      facility?: Facility
    }
  }
}
