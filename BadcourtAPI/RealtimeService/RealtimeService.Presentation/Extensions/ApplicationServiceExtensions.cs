using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using RealtimeService.Infrastructure.Persistence.Repositories;
using RealtimeService.Presentation.ApiRepositories;
using RealtimeService.Presentation.SignalR;

namespace RealtimeService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddSignalR();

        services.AddSingleton<PresenceTracker>();

        return services.AddPersistence(configuration)
            .AddApplication(configuration);
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<ApiEndpoints>(
            configuration.GetSection(nameof(ApiEndpoints))
        );

        services.AddHttpClient<IUserApiRepository, UserApiRepository>();

        services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

        return services;
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
