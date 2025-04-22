using FacilityService.Core.Domain.Repositories;
using FacilityService.Infrastructure.Persistence;
using FacilityService.Presentation.Extensions;
using FacilityService.Presentation.Middlewares;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

using var scope = app.Services.CreateScope();
var services = scope.ServiceProvider;
try
{
    var facilityRepository = services.GetRequiredService<IFacilityRepository>();

    await Seed.SeedFacilitiesAsync(facilityRepository);
}
catch (Exception ex)
{
    var logger = services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occurred during migration");
}

app.Run();
