using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using RealtimeService.Infrastructure.Persistence.Repositories;
using RealtimeService.Presentation.SignalR;

namespace RealtimeService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSignalR();

        services.AddSingleton<PresenceTracker>();

        return services.AddPersistence(configuration);
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<RealtimeDatabaseSettings>(
            configuration.GetSection(nameof(RealtimeDatabaseSettings))
        );

        services.AddScoped<IMessageRepository, MessageRepository>();

        return services;
    }
}
