using FluentValidation;
using MediatR;
using PostService.Application;
using PostService.Application.ApiRepositories;
using PostService.Application.Interfaces;
using PostService.Domain.Interfaces;
using PostService.Infrastructure.ExternalServices.Configurations;
using PostService.Infrastructure.ExternalServices.Services;
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
            .AddExternalServices(config)
            .AddApplication(config);
    }

    public static IServiceCollection AddPersistence(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<PostDatabaseSettings>(config.GetSection(nameof(PostDatabaseSettings)));

        services.AddScoped<IPostRepository, PostRepository>();

        return services;
    }

    public static IServiceCollection AddApplication(this IServiceCollection services, IConfiguration config)
    {
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        services.AddAutoMapper(applicationAssembly);

        services.Configure<ApiEndpoints>(config.GetSection(nameof(ApiEndpoints)));

        services.AddHttpClient<IUserApiRepository, UserApiRepository>();

        return services;
    }

    public static IServiceCollection AddExternalServices(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<CloudinarySettings>(config.GetSection(nameof(CloudinarySettings)));

        services.AddScoped<IFileService, FileService>();

        return services;
    }
}
