export class PaginationHeader {
  private currentPage: number;
  private itemsPerPage: number;
  private totalItems: number;
  private totalPages: number;

  constructor(
    currentPage: number,
    itemsPerPage: number,
    totalItems: number,
    totalPages: number
  ) {
    this.currentPage = currentPage;
    this.itemsPerPage = itemsPerPage;
    this.totalItems = totalItems;
    this.totalPages = totalPages;
  }
}
