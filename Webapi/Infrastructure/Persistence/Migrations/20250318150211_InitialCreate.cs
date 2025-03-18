using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Persistence.Migrations;

/// <inheritdoc />
public partial class InitialCreate : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "AspNetRoles",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                Name = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                NormalizedName = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                ConcurrencyStamp = table.Column<string>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetRoles", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "AspNetUsers",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                UserName = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                NormalizedUserName = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                Email = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                NormalizedEmail = table.Column<string>(type: "TEXT", maxLength: 256, nullable: true),
                EmailConfirmed = table.Column<bool>(type: "INTEGER", nullable: false),
                PasswordHash = table.Column<string>(type: "TEXT", nullable: true),
                SecurityStamp = table.Column<string>(type: "TEXT", nullable: true),
                ConcurrencyStamp = table.Column<string>(type: "TEXT", nullable: true),
                PhoneNumber = table.Column<string>(type: "TEXT", nullable: true),
                PhoneNumberConfirmed = table.Column<bool>(type: "INTEGER", nullable: false),
                TwoFactorEnabled = table.Column<bool>(type: "INTEGER", nullable: false),
                LockoutEnd = table.Column<DateTimeOffset>(type: "TEXT", nullable: true),
                LockoutEnabled = table.Column<bool>(type: "INTEGER", nullable: false),
                AccessFailedCount = table.Column<int>(type: "INTEGER", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetUsers", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "Facilities",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                FacilityName = table.Column<string>(type: "TEXT", nullable: false),
                Description = table.Column<string>(type: "TEXT", nullable: false),
                FacebookUrl = table.Column<string>(type: "TEXT", nullable: true),
                Policy = table.Column<string>(type: "TEXT", nullable: false),
                CourtsAmount = table.Column<int>(type: "INTEGER", nullable: false),
                MinPrice = table.Column<decimal>(type: "TEXT", nullable: false),
                MaxPrice = table.Column<decimal>(type: "TEXT", nullable: false),
                DetailAddress = table.Column<string>(type: "TEXT", nullable: false),
                Location = table.Column<string>(type: "TEXT", nullable: false),
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
                ManagerInfo_FullName = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_Email = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_PhoneNumber = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_CitizenId = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_CitizenImageFront_Url = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_CitizenImageFront_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                ManagerInfo_CitizenImageFront_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                ManagerInfo_CitizenImageBack_Url = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_CitizenImageBack_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                ManagerInfo_CitizenImageBack_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                ManagerInfo_BankCardFront_Url = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_BankCardFront_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                ManagerInfo_BankCardFront_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                ManagerInfo_BankCardBack_Url = table.Column<string>(type: "TEXT", nullable: false),
                ManagerInfo_BankCardBack_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                ManagerInfo_BankCardBack_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                State = table.Column<int>(type: "INTEGER", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Facilities", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "AspNetRoleClaims",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                RoleId = table.Column<Guid>(type: "TEXT", nullable: false),
                ClaimType = table.Column<string>(type: "TEXT", nullable: true),
                ClaimValue = table.Column<string>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                table.ForeignKey(
                    name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                    column: x => x.RoleId,
                    principalTable: "AspNetRoles",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "AspNetUserClaims",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                ClaimType = table.Column<string>(type: "TEXT", nullable: true),
                ClaimValue = table.Column<string>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                table.ForeignKey(
                    name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                    column: x => x.UserId,
                    principalTable: "AspNetUsers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "AspNetUserLogins",
            columns: table => new
            {
                LoginProvider = table.Column<string>(type: "TEXT", nullable: false),
                ProviderKey = table.Column<string>(type: "TEXT", nullable: false),
                ProviderDisplayName = table.Column<string>(type: "TEXT", nullable: true),
                UserId = table.Column<Guid>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                table.ForeignKey(
                    name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                    column: x => x.UserId,
                    principalTable: "AspNetUsers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "AspNetUserRoles",
            columns: table => new
            {
                UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                RoleId = table.Column<Guid>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                table.ForeignKey(
                    name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                    column: x => x.RoleId,
                    principalTable: "AspNetRoles",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                    column: x => x.UserId,
                    principalTable: "AspNetUsers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "AspNetUserTokens",
            columns: table => new
            {
                UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                LoginProvider = table.Column<string>(type: "TEXT", nullable: false),
                Name = table.Column<string>(type: "TEXT", nullable: false),
                Value = table.Column<string>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                table.ForeignKey(
                    name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                    column: x => x.UserId,
                    principalTable: "AspNetUsers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "UserPhotos",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                Url = table.Column<string>(type: "TEXT", nullable: false),
                PublicId = table.Column<string>(type: "TEXT", nullable: true),
                IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                UserId = table.Column<Guid>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_UserPhotos", x => x.Id);
                table.ForeignKey(
                    name: "FK_UserPhotos_AspNetUsers_UserId",
                    column: x => x.UserId,
                    principalTable: "AspNetUsers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "Facilities_BusinessLicenseImages",
            columns: table => new
            {
                ManagerInfoFacilityId = table.Column<Guid>(type: "TEXT", nullable: false),
                Id = table.Column<int>(type: "INTEGER", nullable: false),
                Url = table.Column<string>(type: "TEXT", nullable: false),
                PublicId = table.Column<string>(type: "TEXT", nullable: true),
                IsMain = table.Column<bool>(type: "INTEGER", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Facilities_BusinessLicenseImages", x => new { x.ManagerInfoFacilityId, x.Id });
                table.ForeignKey(
                    name: "FK_Facilities_BusinessLicenseImages_Facilities_ManagerInfoFacilityId",
                    column: x => x.ManagerInfoFacilityId,
                    principalTable: "Facilities",
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
            name: "IX_AspNetRoleClaims_RoleId",
            table: "AspNetRoleClaims",
            column: "RoleId");

        migrationBuilder.CreateIndex(
            name: "RoleNameIndex",
            table: "AspNetRoles",
            column: "NormalizedName",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_AspNetUserClaims_UserId",
            table: "AspNetUserClaims",
            column: "UserId");

        migrationBuilder.CreateIndex(
            name: "IX_AspNetUserLogins_UserId",
            table: "AspNetUserLogins",
            column: "UserId");

        migrationBuilder.CreateIndex(
            name: "IX_AspNetUserRoles_RoleId",
            table: "AspNetUserRoles",
            column: "RoleId");

        migrationBuilder.CreateIndex(
            name: "EmailIndex",
            table: "AspNetUsers",
            column: "NormalizedEmail");

        migrationBuilder.CreateIndex(
            name: "UserNameIndex",
            table: "AspNetUsers",
            column: "NormalizedUserName",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_FacilityPhotos_FacilityId",
            table: "FacilityPhotos",
            column: "FacilityId");

        migrationBuilder.CreateIndex(
            name: "IX_UserPhotos_UserId",
            table: "UserPhotos",
            column: "UserId");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "AspNetRoleClaims");

        migrationBuilder.DropTable(
            name: "AspNetUserClaims");

        migrationBuilder.DropTable(
            name: "AspNetUserLogins");

        migrationBuilder.DropTable(
            name: "AspNetUserRoles");

        migrationBuilder.DropTable(
            name: "AspNetUserTokens");

        migrationBuilder.DropTable(
            name: "Facilities_BusinessLicenseImages");

        migrationBuilder.DropTable(
            name: "FacilityPhotos");

        migrationBuilder.DropTable(
            name: "UserPhotos");

        migrationBuilder.DropTable(
            name: "AspNetRoles");

        migrationBuilder.DropTable(
            name: "Facilities");

        migrationBuilder.DropTable(
            name: "AspNetUsers");
    }
}
