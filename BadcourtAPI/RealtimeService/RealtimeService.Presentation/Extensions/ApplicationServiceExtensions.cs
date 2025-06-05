using FluentValidation;
using MediatR;
using RealtimeService.Application;
using RealtimeService.Application.ApiRepositories;
using RealtimeService.Application.Interfaces;
using RealtimeService.Domain.Interfaces;
using RealtimeService.Infrastructure.ExternalServices.Configurations;
using RealtimeService.Infrastructure.ExternalServices.Services;
using RealtimeService.Infrastructure.Persistence.Configurations;
using RealtimeService.Infrastructure.Persistence.Repositories;
using RealtimeService.Presentation.Middlewares;
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

        services.AddControllers();
        services.AddHttpContextAccessor();
        services.AddSignalR();

        services.AddScoped<ExceptionHandlingMiddleware>();

        services.AddSingleton<PresenceTracker>();

        return services.AddPersistence(configuration)
            .AddExternalServices(configuration)
            .AddApplication(configuration);
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        services.AddAutoMapper(applicationAssembly);

        services.Configure<ApiEndpoints>(configuration.GetSection(nameof(ApiEndpoints)));

        services.AddHttpClient<IUserApiRepository, UserApiRepository>();

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
