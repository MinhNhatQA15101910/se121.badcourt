export class FileDto {
  _id?: string = "";
  url: string = "";
  isMain: boolean = false;
  type: string = "";

  public static mapFrom(file: any): FileDto {
    return new FileDto(file);
  }

  private constructor(file: any) {
    this._id = file === null ? "" : file._id;
    this.url = file === null ? "" : file.url;
    this.isMain = file === null ? false : file.isMain;
    this.type = file === null ? "" : file.type;
  }
}
