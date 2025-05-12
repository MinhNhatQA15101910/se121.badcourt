using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using OrderService.Core.Application;
using OrderService.Core.Application.ApiRepository;
using OrderService.Core.Domain.Repositories;
using OrderService.Infrastructure.Configuration;
using OrderService.Infrastructure.Persistence;
using OrderService.Infrastructure.Persistence.Repositories;
using OrderService.Presentation.Middlewares;

namespace OrderService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        // Database
        services.AddDbContext<DataContext>(options =>
        {
            options.UseSqlite(
                config.GetConnectionString("DefaultConnection"),
                options => options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)
            );
        });
        services.AddScoped<IOrderRepository, OrderRepository>();

        // MediatR
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        // Api Repositories
        services.AddHttpClient<ICourtApiRepository, CourtApiRepository>();

        // Configuration
        services.Configure<ApiEndpoints>(config.GetSection(nameof(ApiEndpoints)));

        return services;
    }
}
