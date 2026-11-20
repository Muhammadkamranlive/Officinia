using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Service.Database;

namespace Server.Repositories;

public class Repo<T> : IRepo<T> where T : class
{
        protected readonly AppDbContext _context;
        private readonly DbSet<T>       _dbSet;

        public Repo(AppDbContext context)
        {
            _context = context;
            _dbSet   = context.Set<T>();
        }

        public async Task<T?> GetByIdAsync(int id)
        {
            return await _dbSet.FindAsync(id);
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _dbSet.AsNoTracking().ToListAsync();
        }

        public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
        {
            return await _dbSet.AsNoTracking().Where(predicate).ToListAsync();
        }
        
        public async Task<T> FindOneAsync(Expression<Func<T, bool>> predicate)
        {
            return await _dbSet.AsNoTracking().Where(predicate).FirstOrDefaultAsync();
        }

        public async Task<T> AddAsync(T entity)
        {
            await _dbSet.AddAsync(entity);
            
            return entity;
        }

        public async Task AddRangeAsync(IEnumerable<T> entities)
        {
            await _dbSet.AddRangeAsync(entities);
        }

        public void Update(T entity)
        {
            _dbSet.Update(entity);
        }
        
        public void UpdateBulk(IEnumerable<T> entity)
        {
            _dbSet.UpdateRange(entity);
        }

        public void Remove(T entity)
        {
            _dbSet.Remove(entity);
        }

        public void RemoveRange(IEnumerable<T> entities)
        {
            _dbSet.RemoveRange(entities);
        }
        
        public void UpdateAll(IEnumerable<T> data, params Expression<Func<T, object>>[] includeProperties)
        {
            foreach (T datum in data)
            {
                EntityEntry<T> entityEntry = _dbSet.Entry(datum);
                foreach (Expression<Func<T, object>> propertyExpression in includeProperties)
                {
                    entityEntry.Property(propertyExpression).IsModified = true;
                }
            }
        }
        
        public void UpdateOne(T data, params Expression<Func<T, object>>[] includeProperties)
        {
                EntityEntry<T> entityEntry = _dbSet.Entry(data);
                foreach (Expression<Func<T, object>> propertyExpression in includeProperties)
                {
                    entityEntry.Property(propertyExpression).IsModified = true;
                }
        }
        
}