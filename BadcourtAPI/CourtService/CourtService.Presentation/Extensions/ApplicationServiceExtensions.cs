using CourtService.Core.Application;
using CourtService.Core.Application.Validators;
using CourtService.Core.Domain.Repositories;
using CourtService.Infrastructure.Configuration;
using CourtService.Infrastructure.Persistence.Repositories;
using CourtService.Presentation.Middlewares;
using FluentValidation;
using MediatR;
using StackExchange.Redis;

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

        // Others
        services.AddAutoMapper(applicationAssembly);

        return services;
    }
}
