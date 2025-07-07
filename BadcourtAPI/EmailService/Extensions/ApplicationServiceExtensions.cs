using EmailService.Configurations;
using EmailService.Consumers;
using EmailService.Services;
using MassTransit;

namespace EmailService.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        services.Configure<EmailSenderSettings>(config.GetSection(nameof(EmailSenderSettings)));
        services.AddScoped<IEmailService, Services.EmailService>();

        services.AddMassTransit(x =>
        {
            x.AddConsumer<EmailValidatedConsumer>();
            x.AddConsumer<SignupValidatedConsumer>();
            x.AddConsumer<UserLockedConsumer>();

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("EmailService-email-validated-queue", e =>
                {
                    e.ConfigureConsumer<EmailValidatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("EmailService-signup-validated-queue", e =>
                {
                    e.ConfigureConsumer<SignupValidatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("EmailService-user-locked-queue", e =>
                {
                    e.ConfigureConsumer<UserLockedConsumer>(ctx);
                });
            });
        });

        return services;
    }
}
