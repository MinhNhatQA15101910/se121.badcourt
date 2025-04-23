using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using CourtService.Infrastructure.Persistence.Repositories;

namespace CourtService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();

        // Options pattern
        services.Configure<CourtDatabaseSettings>(config.GetSection(nameof(CourtDatabaseSettings)));

        // Repositories
        services.AddScoped<ICourtRepository, CourtRepository>();

        return services;
    }
}
