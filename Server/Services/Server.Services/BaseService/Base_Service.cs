using System.Linq.Expressions;
using Server.Repositories;

namespace Server.Services
{
    public class Base_Service<T>(IRepo<T> genericRepository) : IBase_Service<T>  where T : class
    {
        
        #region Add Region
        /// <summary>
        /// Add Range of record
        /// </summary>
        /// <param name="entities"></param>
        /// <returns></returns>
        public async Task<string> AddRange(IEnumerable<T> entities)
        {
            try
            {
                await genericRepository.AddRangeAsync(entities);
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);
            }
        }
        
        /// <summary>
        /// Add one
        /// </summary>
        /// <param name="entity"></param>
        /// <returns></returns>
        public async Task<string> AddOne(T entity)
        {
            try
            {
                await genericRepository.AddAsync(entity);
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);  
            }
        }
        #endregion

        #region Delete Region

        /// <summary>
        /// Find range of records and delete them in bulk 
        /// </summary>
        /// <param name="predicate"></param>
        /// <returns></returns>
        public async Task<string> FindAndDelete(Expression<Func<T, bool>> predicate)
        {
            try
            {
                var Records= await genericRepository.FindAsync(predicate);
                if (Records.Any())
                {
                    genericRepository.RemoveRange(Records);
                }
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);
            }
        }

        /// <summary>
        /// Delete function 
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<string> Delete(dynamic id)
        {
            try
            {
                var tempRecord = await genericRepository.FindAsync(id);
                if (tempRecord == null) return $"{typeof(T).Name} with the {id} is  not Found sorry...!";
                await genericRepository.Remove(id);
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);
            }
        }
        /// <summary>
        /// Remove Range 
        /// </summary>
        /// <param name="entities"></param>
        /// <returns></returns>
        public string RemoveRange(IEnumerable<T> entities)
        {
            try
            {
                genericRepository.RemoveRange(entities);
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);
            }
        }

        #endregion
        
        #region Update Region
        /// <summary>
        /// Update One record
        /// </summary>
        /// <param name="entity"></param>
        /// <returns></returns>
        public string Update(T entity)
        {
            try
            {
                genericRepository.Update(entity);
                return "OK";
            }
            catch (Exception e)
            {
              return ReturnException(e);
            }
        }
        
        /// <summary>
        /// Update single entity prop only 
        /// </summary>
        /// <param name="data"></param>
        /// <param name="includeProperties"></param>
        /// <exception cref="Exception"></exception>
        public string UpdateOne(T data, params Expression<Func<T, object>>[] includeProperties)
        {
            try
            {
                genericRepository.UpdateOne(data,includeProperties);
                return "OK";
            }
            catch (Exception ex)
            {
                return ReturnException(ex);
            }
        }
        
        /// <summary>
        /// Update
        /// </summary>
        /// <param name="data"></param>
        /// <param name="includeProperties"></param>
        /// <exception cref="Exception"></exception>
        public string UpdateAll(IEnumerable<T> data, params Expression<Func<T, object>>[] includeProperties)
        {
            try
            {
                genericRepository.UpdateAll(data,includeProperties);   
                return "OK";
            }
            catch (Exception ex)
            {
                return ReturnException(ex);
            }
        }
        /// <summary>
        /// Update
        /// </summary>
        /// <param name="data"></param>
        /// <exception cref="Exception"></exception>
        public string UpdateBulk(IEnumerable<T> data)
        {
            try
            {
                genericRepository.UpdateBulk(data);
                return "OK";
            }
            catch (Exception ex)
            {
                return ReturnException(ex); 
            }
        }
        #endregion
        
        #region Get Region
        /// <summary>
        /// Find range of records
        /// </summary>
        /// <param name="predicate"></param>
        /// <returns></returns>
        public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
        { 
            return await genericRepository.FindAsync(predicate);
        }
        
        /// <summary>
        /// Get All Records
        /// </summary>
        /// <returns></returns>
        public async Task<IEnumerable<T>> GetAll()
        {
            return await genericRepository.GetAllAsync();
        }
        /// <summary>
        /// Fine one with predicate 
        /// </summary>
        /// <param name="predicate"></param>
        /// <returns></returns>
        public async Task<T> FindOne(Expression<Func<T, bool>> predicate)
        {
            return await genericRepository.FindOneAsync(predicate);
        }
        
       #endregion
       
        /// <summary>
        /// Return Formatted Exception in the services
        /// </summary>
        /// <param name="ex"></param>
        /// <returns></returns>
        public string ReturnException(Exception e)
        {
            string retValue="OK";
            if(e!= null)
            {
               retValue = "Exception " +e.Message + "\n" + e.InnerException?.Message + "\n" + e.InnerException?.InnerException?.Message;
            }
            return retValue;
        }
    }

}
