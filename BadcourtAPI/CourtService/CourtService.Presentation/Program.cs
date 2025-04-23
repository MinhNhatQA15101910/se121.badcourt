using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Persistence;
using CourtService.Presentation.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);

var app = builder.Build();

app.MapControllers();

using var scope = app.Services.CreateScope();
var services = scope.ServiceProvider;
try
{
    var courtRepository = services.GetRequiredService<ICourtRepository>();

    await Seed.SeedCourtsAsync(courtRepository);
}
catch (Exception ex)
{
    var logger = services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occurred during migration");
}

app.Run();
