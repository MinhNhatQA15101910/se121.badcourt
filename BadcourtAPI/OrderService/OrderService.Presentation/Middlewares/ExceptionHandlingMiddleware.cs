using Newtonsoft.Json;
using SharedKernel.Exceptions;

namespace OrderService.Presentation.Middlewares;

public class ExceptionHandlingMiddleware(
    ILogger<ExceptionHandlingMiddleware> logger
) : IMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        try
        {
            await next(context);
        }
        catch (Exception e)
        {
            logger.LogError(e, e.Message);

            await HandleExceptionAsync(context, e);
        }
    }

    private static async Task HandleExceptionAsync(HttpContext httpContext, Exception exception)
    {
        var statusCode = GetStatusCode(exception);

        var response = new
        {
            title = GetTitle(exception),
            status = statusCode,
            detail = exception.Message,
            errors = GetErrors(exception)
        };

        httpContext.Response.ContentType = "application/json";

        httpContext.Response.StatusCode = statusCode;

        await httpContext.Response.WriteAsync(JsonConvert.SerializeObject(response));
    }

    private static IReadOnlyDictionary<string, string[]>? GetErrors(Exception exception)
    {
        return exception switch
        {
            ValidationException validationException => validationException.ErrorsDictionary,
            _ => null
        };
    }

    private static string GetTitle(Exception exception)
        => exception switch
        {
            SharedKernel.Exceptions.ApplicationException applicationException => applicationException.Title,
            _ => "Server Error"
        };

    private static int GetStatusCode(Exception exception)
        => exception switch
        {
            BadRequestException => StatusCodes.Status400BadRequest,
            UnauthorizedException => StatusCodes.Status401Unauthorized,
            NotFoundException => StatusCodes.Status404NotFound,
            ValidationException => StatusCodes.Status422UnprocessableEntity,
            ForbiddenAccessException => StatusCodes.Status403Forbidden,
            _ => StatusCodes.Status500InternalServerError
        };
}
