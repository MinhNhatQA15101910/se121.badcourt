using BadCourtAPI.Data;
using BadCourtAPI.Features.Behaviors;
using BadCourtAPI.Interfaces.Services;
using BadCourtAPI.Middlewares;
using BadCourtAPI.Services;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace BadCourtAPI.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();

        // Database and repositories
        services.AddDbContext<DataContext>(options =>
        {
            options.UseSqlite(config.GetConnectionString("DefaultConnection"));
        });

        // Services
        services.AddScoped<ITokenService, TokenService>();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        // MediatR
        var applicationAssembly = typeof(Program).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        // Others
        services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

        return services;
    }
}
