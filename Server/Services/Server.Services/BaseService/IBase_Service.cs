using System.Linq.Expressions;
namespace Server.Services
{
    public interface IBase_Service<T> where T : class
    {
        Task<string> Delete(dynamic id);
        Task<string> FindAndDelete(Expression<Func<T, bool>> predicate);
        string RemoveRange(IEnumerable<T> entities);
        Task<string> AddRange(IEnumerable<T> entities);
        Task<string> AddOne(T entity);
        string Update(T entity);
        string UpdateOne(T data, params Expression<Func<T, object>>[] includeProperties);
        string UpdateAll(IEnumerable<T> data, params Expression<Func<T, object>>[] includeProperties);
        string UpdateBulk(IEnumerable<T> data);
        Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
        Task<IEnumerable<T>> GetAll();
        Task<T> FindOne(Expression<Func<T, bool>> predicate);
    }
}
