using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FacilityService.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class SqlInitial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ManagerInfo",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    FullName = table.Column<string>(type: "TEXT", nullable: false),
                    Email = table.Column<string>(type: "TEXT", nullable: false),
                    PhoneNumber = table.Column<string>(type: "TEXT", nullable: false),
                    CitizenId = table.Column<string>(type: "TEXT", nullable: false),
                    CitizenImageFront_Url = table.Column<string>(type: "TEXT", nullable: false),
                    CitizenImageFront_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    CitizenImageFront_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                    CitizenImageBack_Url = table.Column<string>(type: "TEXT", nullable: false),
                    CitizenImageBack_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    CitizenImageBack_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                    BankCardFront_Url = table.Column<string>(type: "TEXT", nullable: false),
                    BankCardFront_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    BankCardFront_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                    BankCardBack_Url = table.Column<string>(type: "TEXT", nullable: false),
                    BankCardBack_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    BankCardBack_IsMain = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ManagerInfo", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BusinessLicensePhotos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Url = table.Column<string>(type: "TEXT", nullable: false),
                    PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                    ManagerInfoId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BusinessLicensePhotos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BusinessLicensePhotos_ManagerInfo_ManagerInfoId",
                        column: x => x.ManagerInfoId,
                        principalTable: "ManagerInfo",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Facilities",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    FacilityName = table.Column<string>(type: "TEXT", nullable: false),
                    Description = table.Column<string>(type: "TEXT", nullable: false),
                    FacebookUrl = table.Column<string>(type: "TEXT", nullable: true),
                    Policy = table.Column<string>(type: "TEXT", nullable: false),
                    CourtsAmount = table.Column<int>(type: "INTEGER", nullable: false),
                    MinPrice = table.Column<decimal>(type: "TEXT", nullable: false),
                    MaxPrice = table.Column<decimal>(type: "TEXT", nullable: false),
                    DetailAddress = table.Column<string>(type: "TEXT", nullable: false),
                    Province = table.Column<string>(type: "TEXT", nullable: false),
                    Location_Latitude = table.Column<double>(type: "REAL", nullable: false),
                    Location_Longitude = table.Column<double>(type: "REAL", nullable: false),
                    RatingAvg = table.Column<float>(type: "REAL", nullable: false),
                    TotalRatings = table.Column<int>(type: "INTEGER", nullable: false),
                    ActiveAt_Monday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Monday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Tuesday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Tuesday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Wednesday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Wednesday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Thursday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Thursday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Friday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Friday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Saturday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Saturday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Sunday_HourFrom = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    ActiveAt_Sunday_HourTo = table.Column<TimeOnly>(type: "TEXT", nullable: true),
                    State = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    ManagerInfoId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Facilities", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Facilities_ManagerInfo_ManagerInfoId",
                        column: x => x.ManagerInfoId,
                        principalTable: "ManagerInfo",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FacilityPhotos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Url = table.Column<string>(type: "TEXT", nullable: false),
                    PublicId = table.Column<string>(type: "TEXT", nullable: true),
                    IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                    FacilityId = table.Column<Guid>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FacilityPhotos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FacilityPhotos_Facilities_FacilityId",
                        column: x => x.FacilityId,
                        principalTable: "Facilities",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BusinessLicensePhotos_ManagerInfoId",
                table: "BusinessLicensePhotos",
                column: "ManagerInfoId");

            migrationBuilder.CreateIndex(
                name: "IX_Facilities_ManagerInfoId",
                table: "Facilities",
                column: "ManagerInfoId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FacilityPhotos_FacilityId",
                table: "FacilityPhotos",
                column: "FacilityId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BusinessLicensePhotos");

            migrationBuilder.DropTable(
                name: "FacilityPhotos");

            migrationBuilder.DropTable(
                name: "Facilities");

            migrationBuilder.DropTable(
                name: "ManagerInfo");
        }
    }
}
