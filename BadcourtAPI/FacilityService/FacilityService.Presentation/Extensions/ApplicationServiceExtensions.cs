using FacilityService.Core.Application;
using FacilityService.Core.Application.Behaviors;
using FacilityService.Core.Application.Consumers;
using FacilityService.Core.Application.ExternalServices;
using FacilityService.Core.Application.ExternalServices.Clients;
using FacilityService.Core.Application.ExternalServices.Interfaces;
using FacilityService.Core.Application.Interfaces;
using FacilityService.Core.Domain.Repositories;
using FacilityService.Infrastructure.Configuration;
using FacilityService.Infrastructure.Persistence.Repositories;
using FacilityService.Infrastructure.Services;
using FacilityService.Presentation.Middlewares;
using FluentValidation;
using MassTransit;
using MediatR;
using StackExchange.Redis;

namespace FacilityService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        // Redis
        services.AddStackExchangeRedisCache(options =>
        {
            options.Configuration = config["RedisCacheSettings:Configuration"];
            options.InstanceName = config["RedisCacheSettings:InstanceName"];
        });

        services.AddSingleton<IConnectionMultiplexer>(sp =>
            ConnectionMultiplexer.Connect(config["RedisCacheSettings:Configuration"]!));

        // MassTransit
        services.AddMassTransit(x =>
        {
            x.AddConsumer<CourtCreatedConsumer>();
            x.AddConsumer<CourtUpdatedConsumer>();
            x.AddConsumer<FacilityRatedConsumer>();

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("FacilityService-court-created-queue", e =>
                {
                    e.ConfigureConsumer<CourtCreatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("FacilityService-court-updated-queue", e =>
                {
                    e.ConfigureConsumer<CourtUpdatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("FacilityService-facility-rated-queue", e =>
                {
                    e.ConfigureConsumer<FacilityRatedConsumer>(ctx);
                });
            });
        });

        return services.AddApplication(config)
            .AddPersistence(config)
            .AddExternalServices(config);
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        services.AddAutoMapper(applicationAssembly);

        services.Configure<ApiEndpoints>(configuration.GetSection(nameof(ApiEndpoints)));

        services.AddHttpClient<IUserServiceClient, UserServiceClient>();
        services.AddHttpClient<IOrderServiceClient, OrderServiceClient>();

        return services;
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<FacilityDatabaseSettings>(
            configuration.GetSection(nameof(FacilityDatabaseSettings))
        );

        services.AddScoped<IFacilityRepository, FacilityRepository>();

        return services;
    }

    public static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<CloudinarySettings>(config.GetSection(nameof(CloudinarySettings)));

        services.AddScoped<IFileService, FileService>();

        return services;
    }
}
