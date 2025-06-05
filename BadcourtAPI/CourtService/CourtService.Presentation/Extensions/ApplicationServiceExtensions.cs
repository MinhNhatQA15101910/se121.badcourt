using CourtService.Core.Application;
using CourtService.Core.Application.ApiRepositories;
using CourtService.Core.Application.Consumers;
using CourtService.Core.Application.Validators;
using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using CourtService.Infrastructure.Persistence.Repositories;
using CourtService.Presentation.Middlewares;
using FluentValidation;
using MassTransit;
using MediatR;
using StackExchange.Redis;

namespace CourtService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        services.AddScoped<ExceptionHandlingMiddleware>();

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
            x.AddConsumer<OrderCreatedConsumer>();

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("CourtService-order-created-queue", e =>
                {
                    e.ConfigureConsumer<OrderCreatedConsumer>(ctx);
                });
            });
        });

        return services.AddPersistence(config).AddApplication(config);
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration config)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        services.AddAutoMapper(applicationAssembly);

        services.AddSingleton<ApiEndpoints>();

        services.AddHttpClient<IFacilityApiRepository, FacilityApiRepository>();

        return services;
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<CourtDatabaseSettings>(config.GetSection(nameof(CourtDatabaseSettings)));

        services.AddScoped<ICourtRepository, CourtRepository>();

        return services;
    }
}
