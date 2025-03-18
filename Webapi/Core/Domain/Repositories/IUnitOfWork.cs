namespace Domain.Repositories;

public interface IUnitOfWork
{
    IUserRepository UserRepository { get; }
    Task<bool> Complete();
}
