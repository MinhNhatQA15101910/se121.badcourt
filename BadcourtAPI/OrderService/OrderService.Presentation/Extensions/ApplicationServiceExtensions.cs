using FluentValidation;
using MassTransit;
using MediatR;
using Microsoft.EntityFrameworkCore;
using OrderService.Core.Application;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Application.Interfaces;
using OrderService.Core.Domain.Repositories;
using OrderService.Infrastructure.Configuration;
using OrderService.Infrastructure.ExternalServices.BackgroundServices;
using OrderService.Infrastructure.ExternalServices.Services;
using OrderService.Infrastructure.Persistence;
using OrderService.Infrastructure.Persistence.Repositories;
using OrderService.Presentation.Middlewares;
using Stripe;

namespace OrderService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        StripeConfiguration.ApiKey = config["StripeSettings:SecretKey"];

        // MassTransit
        services.AddMassTransit(x =>
        {
            x.UsingRabbitMq();
        });

        return services.AddApplication(config)
            .AddPersistence(config)
            .AddExternalServices(config);
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        // MediatR
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        // AutoMapper
        services.AddAutoMapper(applicationAssembly);

        return services;
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<DataContext>(options =>
        {
            options.UseSqlite(
                configuration.GetConnectionString("OrdersDbConnection"),
                options => options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)
            );
        });
        services.AddScoped<IOrderRepository, OrderRepository>();
        services.AddScoped<IRatingRepository, RatingRepository>();

        return services;
    }

    public static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddScoped<IStripeService, StripeService>();

        // Background Services
        services.AddHostedService<UpdateOrderStateBackgroundService>();
        services.AddHostedService<DeletePendingOrdersBackgroundService>();

        // Api Repositories
        services.AddHttpClient<IFacilityApiRepository, FacilityApiRepository>();
        services.AddHttpClient<ICourtApiRepository, CourtApiRepository>();
        services.AddHttpClient<IUserApiRepository, UserApiRepository>();

        // Configuration
        services.Configure<ApiEndpoints>(config.GetSection(nameof(ApiEndpoints)));

        return services;
    }
}
