namespace Server.Repositories;

public interface ITxn_Manager_Repo
{
    Task Transaction();
    Task Commit();
    Task Rollback();
    Task<int> SaveAsync();

}