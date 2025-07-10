using ManagerService.Presentation.Extensions;
using ManagerService.Presentation.Middlewares;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost1311", policy =>
    {
        policy.WithOrigins("http://localhost:1311")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

app.UseCors("AllowLocalhost1311");

app.UseMiddleware<ExceptionHandlingMiddleware>();

app.UseAuthentication();
app.UseMiddleware<UserStateMiddleware>();
app.UseAuthorization();

app.MapControllers();

app.Run();
