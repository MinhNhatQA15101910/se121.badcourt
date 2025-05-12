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
            name: "Orders",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "TEXT", nullable: false),
                UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                CourtId = table.Column<string>(type: "TEXT", nullable: false),
                Address = table.Column<string>(type: "TEXT", nullable: false),
                DateTimePeriod_HourFrom = table.Column<DateTime>(type: "TEXT", nullable: false),
                DateTimePeriod_HourTo = table.Column<DateTime>(type: "TEXT", nullable: false),
                Price = table.Column<decimal>(type: "TEXT", nullable: false),
                State = table.Column<int>(type: "INTEGER", nullable: false),
                Image_Url = table.Column<string>(type: "TEXT", nullable: false),
                Image_PublicId = table.Column<string>(type: "TEXT", nullable: true),
                Image_IsMain = table.Column<bool>(type: "INTEGER", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Orders", x => x.Id);
            });
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "Orders");
    }
}
