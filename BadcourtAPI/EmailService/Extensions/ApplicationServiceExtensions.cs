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

            x.UsingRabbitMq((ctx, cfg) =>
            {
                cfg.ReceiveEndpoint("email-created-queue", e =>
                {
                    e.ConfigureConsumer<EmailValidatedConsumer>(ctx);
                });
                cfg.ReceiveEndpoint("signup-validated-queue", e =>
                {
                    e.ConfigureConsumer<SignupValidatedConsumer>(ctx);
                });
            });
        });

        return services;
    }
}
