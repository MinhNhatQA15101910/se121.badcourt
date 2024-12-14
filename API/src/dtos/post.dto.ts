export class PostDto {
  _id: string = "";
  publisherId: string = "";
  publisherUsername: string = "";
  publisherImageUrl?: string = "";
  title: string = "";
  description: string = "";
  category: "advertise" | "findPlayer" = "advertise";
  resources: string[] = [];
}
