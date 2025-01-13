export class MessageDto {
  _id: string = "";
  senderId: string = "";
  senderImageUrl: string = "";
  content: string = "";
  resources: string[] = [];
  createdAt: number = Date.now();

  public static mapFrom(message: any): MessageDto {
    return new MessageDto(message);
  }

  private constructor(message: any) {
    this._id = message === null ? "" : message._id;
    this.senderId = message === null ? "" : message.senderId;
    this.content = message === null ? "" : message.content;
    this.resources =
      message === null ? [] : message.resources.map((r: any) => r.url);
    this.createdAt = message === null ? Date.now() : message.updatedAt;
  }
}
