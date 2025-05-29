using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using RealtimeService.Presentation.SignalR;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.WithOrigins("http://192.168.1.237:4000")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials(); // Required for SignalR
    });
});

var app = builder.Build();

app.UseCors("CorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapHub<PresenceHub>("hubs/presence");
app.MapHub<MessageHub>("hubs/message");
app.MapHub<GroupHub>("hubs/group");

using var scope = app.Services.CreateScope();
var services = scope.ServiceProvider;
try
{
    var connectionRepository = services.GetRequiredService<IConnectionRepository>();
    var groupRepository = services.GetRequiredService<IGroupRepository>();
    var messageRepository = services.GetRequiredService<IMessageRepository>();

    await connectionRepository.DeleteAllAsync();
    // await groupRepository.DeleteAllConnectionsAsync();
}
catch (Exception ex)
{
    var logger = services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occurred during migration");
}

app.Run();
