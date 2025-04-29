using AuthService.Core.Application;
using AuthService.Core.Application.Behaviors;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Services;
using AuthService.Core.Domain.Repositories;
using AuthService.Infrastructure.Configuration;
using AuthService.Infrastructure.Persistence;
using AuthService.Infrastructure.Persistence.Repositories;
using AuthService.Infrastructure.Services;
using AuthService.Presentation.Middlewares;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using StackExchange.Redis;

namespace AuthService.Presentation.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.AddControllers();
        services.AddHttpContextAccessor();

        // Options pattern
        services.Configure<CloudinarySettings>(config.GetSection("CloudinarySettings"));
        services.Configure<EmailSenderSettings>(config.GetSection("EmailSenderSettings"));
        services.Configure<MongoDbSettings>(config.GetSection("MongoDbSettings"));

        // Database and repositories
        services.AddDbContext<DataContext>(options =>
        {
            options.UseSqlite(
                config.GetConnectionString("DefaultConnection"),
                options => options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)
            );
        });
        services.AddScoped<IUserRepository, UserRepository>();

        // Services
        services.AddSingleton<PincodeStore>();
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IFileService, FileService>();

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
