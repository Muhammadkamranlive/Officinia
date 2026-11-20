using Server.Domains;
using Server.Models;

namespace Server.Services;

public interface IApp_User_Service:IBase_Service<App_User>
{
    Task<string> Login(LoginDto dto);
    Task<string> Register(RegisterUserModel dto);
}