using System.Linq.Expressions;

namespace Server.Repositories;

public interface IRepo<T> where T : class
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
    Task<T> FindOneAsync(Expression<Func<T, bool>> predicate);
    Task<T> AddAsync(T entity);
    Task AddRangeAsync(IEnumerable<T> entities);
    void Update(T entity);
    void UpdateBulk(IEnumerable<T> entity);
    void Remove(T entity);
    void RemoveRange(IEnumerable<T> entities);
    void UpdateAll(IEnumerable<T> data, params Expression<Func<T, object>>[] includeProperties);
    void UpdateOne(T data, params Expression<Func<T, object>>[] includeProperties);
}