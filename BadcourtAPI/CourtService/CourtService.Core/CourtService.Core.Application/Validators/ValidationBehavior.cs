using CourtService.Core.Application.Commands;
using FluentValidation;
using MediatR;

namespace CourtService.Core.Application.Validators;

public class ValidationBehavior<TRequest, TResponse>(
    IEnumerable<IValidator<TRequest>> validators
) : IPipelineBehavior<TRequest, TResponse>
    where TRequest : class, ICommand<TResponse>
{
    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
    {
        if (!validators.Any()) return await next(cancellationToken);

        var context = new ValidationContext<TRequest>(request);

        var errorsDictionary = validators
            .Select(v => v.Validate(context))
            .SelectMany(result => result.Errors)
            .Where(failure => failure != null)
            .GroupBy(
                failure => failure.PropertyName,
                failure => failure.ErrorMessage,
                (propertyName, errorMessage) => new
                {
                    Key = propertyName,
                    Value = errorMessage.Distinct().ToArray()
                }
            )
            .ToDictionary(failure => failure.Key, failure => failure.Value);

        if (errorsDictionary.Count != 0)
        {
            throw new SharedKernel.Exceptions.ValidationException(errorsDictionary);
        }

        return await next(cancellationToken);
    }
}
