using AuthService.Core.Application;
using AuthService.Core.Application.Behaviors;
using AuthService.Core.Application.Consumers;
using AuthService.Core.Application.Interfaces;
using AuthService.Core.Application.Services;
using AuthService.Core.Domain.Repositories;
using AuthService.Infrastructure.Configuration;
using AuthService.Infrastructure.Persistence;
using AuthService.Infrastructure.Persistence.Repositories;
using AuthService.Infrastructure.Services;
using AuthService.Presentation.Middlewares;
using FluentValidation;
using MassTransit;
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
                config.GetConnectionString("AuthDbConnection"),
                options => options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery)
            );
        });
        services.AddScoped<IUserRepository, UserRepository>();

        // Services
        services.AddSingleton<PincodeStore>();
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IFileService, FileService>();

        // Middleware
        services.AddScoped<ExceptionHandlingMiddleware>();

        // MediatR
        var applicationAssembly = typeof(AssemblyReference).Assembly;
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssemblies(applicationAssembly));
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
        services.AddValidatorsFromAssembly(applicationAssembly);

        // MassTransit and RabbitMQ
        services.AddMassTransit(x =>
        {
            x.AddConsumer<UserOnlineConsumer>();
            x.AddConsumer<UserOfflineConsumer>();

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("AuthService-user-online-queue", e =>
                {
                    e.ConfigureConsumer<UserOnlineConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("AuthService-user-offline-queue", e =>
                {
                    e.ConfigureConsumer<UserOfflineConsumer>(ctx);
                });
            });
        });

        // Others
        services.AddAutoMapper(applicationAssembly);

        return services;
    }
}
