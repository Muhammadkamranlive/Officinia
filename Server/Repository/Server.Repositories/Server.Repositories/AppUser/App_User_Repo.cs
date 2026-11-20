using Server.Domains;
using Service.Database;

namespace Server.Repositories;

public class App_User_Repo:Repo<App_User>,IApp_User_Repo
{
    public App_User_Repo(AppDbContext context) : base(context)
    {
    }
}