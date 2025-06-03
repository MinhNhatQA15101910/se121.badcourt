using RealtimeService.Domain.Interfaces;
using RealtimeService.Presentation.Extensions;
using RealtimeService.Presentation.SignalR;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

var app = builder.Build();

app.UseCors("CorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

app.MapHub<PresenceHub>("hubs/presence");
app.MapHub<MessageHub>("hubs/message");
app.MapHub<GroupHub>("hubs/group");
app.MapHub<NotificationHub>("hubs/notification");

using var scope = app.Services.CreateScope();
var services = scope.ServiceProvider;
try
{
    var connectionRepository = services.GetRequiredService<IConnectionRepository>();
    var groupRepository = services.GetRequiredService<IGroupRepository>();
    var messageRepository = services.GetRequiredService<IMessageRepository>();

    await connectionRepository.DeleteAllAsync();
}
catch (Exception ex)
{
    var logger = services.GetRequiredService<ILogger<Program>>();
    logger.LogError(ex, "An error occurred during migration");
}

app.Run();
