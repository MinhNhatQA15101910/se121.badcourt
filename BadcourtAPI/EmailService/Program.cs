using EmailService.Extensions;

var builder = Host.CreateApplicationBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);

var host = builder.Build();

host.Run();
