using AdminService.Application;
using AdminService.Application.Interfaces.ServiceClients;
using AdminService.Infrastructure.Services.Configurations;
using AdminService.Infrastructure.Services.ServiceClients;
using AdminService.Presentation.Middlewares;
using FluentValidation;
using MediatR;

namespace AdminService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        services.AddScoped<ExceptionHandlingMiddleware>();

        return services
            .AddExternalServices(configuration)
            .AddApplication(configuration);
    }

    private static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration configuration)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        return services;
    }

    private static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<ApiEndpoints>(configuration.GetSection(nameof(ApiEndpoints)));

        services.AddHttpClient<IOrderServiceClient, OrderServiceClient>();

        return services;
    }
}
