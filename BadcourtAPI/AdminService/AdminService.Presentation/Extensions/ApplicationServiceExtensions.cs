using AdminService.Presentation.Middlewares;

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
        return services;
    }

    private static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration configuration)
    {
        return services;
    }
}
