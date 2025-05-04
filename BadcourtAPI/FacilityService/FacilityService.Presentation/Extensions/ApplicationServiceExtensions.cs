using FacilityService.Core.Application;
using FacilityService.Core.Application.Behaviors;
using FacilityService.Core.Application.Consumers;
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

        // Options pattern
        services.Configure<FacilityDatabaseSettings>(config.GetSection(nameof(FacilityDatabaseSettings)));
        services.Configure<CloudinarySettings>(config.GetSection(nameof(CloudinarySettings)));

        // Repositories
        services.AddScoped<IFacilityRepository, FacilityRepository>();

        // Services
        services.AddScoped<IFileService, FileService>();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        // MediatR
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

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

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("court-created-queue", e =>
                {
                    e.ConfigureConsumer<CourtCreatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("court-updated-queue", e =>
                {
                    e.ConfigureConsumer<CourtUpdatedConsumer>(ctx);
                });
            });
        });

        // Others
        services.AddAutoMapper(applicationAssembly);

        return services;
    }
}
