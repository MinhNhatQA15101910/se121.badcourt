import { FileDto } from "./fileDto";

export class NewPostDto {
  userId?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources?: FileDto[] = [];
}
