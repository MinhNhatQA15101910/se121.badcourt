export class CommentDto {
  _id: string = "";
  publisherId: string = "";
  publisherUsername: string = "";
  content: string = "";
  createdAt: number = 0;

  public static mapFrom(comment: any): CommentDto {
    return new CommentDto(comment);
  }

  private constructor(comment?: any) {
    this._id = comment === null ? "" : comment._id;
    this.publisherId = comment === null ? "" : comment.userId;
    this.content = comment === null ? "" : comment.content;
    this.createdAt = comment === null ? 0 : comment.createdAt;
  }
}
