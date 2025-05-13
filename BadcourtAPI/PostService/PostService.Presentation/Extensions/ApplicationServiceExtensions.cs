using FluentValidation;
using MediatR;
using PostService.Application;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.Persistence.Configurations;
using PostService.Infrastructure.Persistence.Repositories;
using PostService.Presentation.Middlewares;

namespace PostService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        services.AddScoped<ExceptionHandlingMiddleware>();

        return services.AddPersistence(config)
            .AddApplication();
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<PostDatabaseSettings>(config.GetSection(nameof(PostDatabaseSettings)));

        services.AddScoped<IPostRepository, PostRepository>();

        return services;
    }

    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        services.AddAutoMapper(applicationAssembly);

        return services;
    }
}
