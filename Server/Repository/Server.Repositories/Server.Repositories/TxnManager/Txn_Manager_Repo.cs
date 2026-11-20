using Microsoft.EntityFrameworkCore.Storage;
using Service.Database;

namespace Server.Repositories;

public class Txn_Manager_Repo(AppDbContext context) : ITxn_Manager_Repo
{
    private IDbContextTransaction? _transaction;

    public async Task Transaction()
    {
        if (_transaction != null)
            return;
        _transaction = await context.Database.BeginTransactionAsync();
    }

    public async Task<int> SaveAsync()
    {
        return await context.SaveChangesAsync();
    }

    public async Task Commit()
    {
        await SaveAsync();
        if (_transaction == null)
            return;

        await _transaction.CommitAsync();
        await _transaction.DisposeAsync();
        _transaction = null;
    }

    public async Task Rollback()
    {
        if (_transaction == null)
            return;
        await _transaction.RollbackAsync();
        await _transaction.DisposeAsync();
        _transaction = null;
    }
}