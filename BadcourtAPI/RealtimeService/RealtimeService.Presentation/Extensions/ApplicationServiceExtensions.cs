using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.Persistence.Configurations;
using RealtimeService.Infrastructure.Persistence.Repositories;
using RealtimeService.Presentation.ApiRepositories;
using RealtimeService.Presentation.Configurations;
using RealtimeService.Presentation.Interfaces;
using RealtimeService.Presentation.Services;
using RealtimeService.Presentation.SignalR;

namespace RealtimeService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("CorsPolicy", policy =>
            {
                policy.WithOrigins("http://192.168.1.83:4000")
                    .AllowAnyHeader()
                    .AllowAnyMethod()
                    .AllowCredentials();
            });
        });

        services.AddSignalR();

        services.AddSingleton<PresenceTracker>();

        return services.AddPersistence(configuration)
            .AddExternalServices(configuration)
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
        services.AddScoped<IConnectionRepository, ConnectionRepository>();
        services.AddScoped<IGroupRepository, GroupRepository>();
        services.AddScoped<INotificationRepository, NotificationRepository>();

        return services;
    }

    public static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<CloudinarySettings>(config.GetSection(nameof(CloudinarySettings)));

        services.AddScoped<IFileService, FileService>();

        return services;
    }
}
