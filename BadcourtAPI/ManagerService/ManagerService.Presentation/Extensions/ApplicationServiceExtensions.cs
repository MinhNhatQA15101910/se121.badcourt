using FluentValidation;
using ManagerService.Application;
using ManagerService.Application.Interfaces.ServiceClients;
using ManagerService.Infrastructure.Services.Configurations;
using ManagerService.Infrastructure.Services.ServiceClients;
using ManagerService.Presentation.Middlewares;
using MediatR;

namespace ManagerService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        services.AddScoped<ExceptionHandlingMiddleware>();

        return services
            .AddExternalServices(configuration)
            .AddApplication();
    }

    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        return services;
    }

    public static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<ApiEndpoints>(configuration.GetSection(nameof(ApiEndpoints)));

        services.AddHttpClient<ICourtServiceClient, CourtServiceClient>();
        services.AddHttpClient<IOrderServiceClient, OrderServiceClient>();

        return services;
    }
}
