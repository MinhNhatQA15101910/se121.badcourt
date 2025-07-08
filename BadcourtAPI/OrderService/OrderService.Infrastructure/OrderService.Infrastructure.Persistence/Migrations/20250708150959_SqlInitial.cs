using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrderService.Infrastructure.Persistence.Migrations;

/// <inheritdoc />
public partial class SqlInitial : Migration
{
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Ratings",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                UserId = table.Column<Guid>(type: "uuid", nullable: false),
                Username = table.Column<string>(type: "text", nullable: false),
                UserImageUrl = table.Column<string>(type: "text", nullable: true),
                FacilityId = table.Column<string>(type: "text", nullable: false),
                Stars = table.Column<int>(type: "integer", nullable: false),
                Feedback = table.Column<string>(type: "text", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Ratings", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "Orders",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uuid", nullable: false),
                UserId = table.Column<Guid>(type: "uuid", nullable: false),
                Username = table.Column<string>(type: "text", nullable: false),
                UserImageUrl = table.Column<string>(type: "text", nullable: true),
                FacilityOwnerId = table.Column<string>(type: "text", nullable: false),
                FacilityId = table.Column<string>(type: "text", nullable: false),
                FacilityName = table.Column<string>(type: "text", nullable: false),
                CourtId = table.Column<string>(type: "text", nullable: false),
                CourtName = table.Column<string>(type: "text", nullable: false),
                Province = table.Column<string>(type: "text", nullable: false),
                Address = table.Column<string>(type: "text", nullable: false),
                DateTimePeriod_HourFrom = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                DateTimePeriod_HourTo = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                Price = table.Column<decimal>(type: "numeric", nullable: false),
                State = table.Column<string>(type: "text", nullable: false),
                ImageUrl = table.Column<string>(type: "text", nullable: false),
                PaymentIntentId = table.Column<string>(type: "text", nullable: false),
                RatingId = table.Column<Guid>(type: "uuid", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Orders", x => x.Id);
                table.ForeignKey(
                    name: "FK_Orders_Ratings_RatingId",
                    column: x => x.RatingId,
                    principalTable: "Ratings",
                    principalColumn: "Id");
            });

        migrationBuilder.CreateIndex(
            name: "IX_Orders_RatingId",
            table: "Orders",
            column: "RatingId");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "Orders");

        migrationBuilder.DropTable(
            name: "Ratings");
    }
}
