using Server.Domains;
using Server.Models;
using Server.Repositories;
namespace Server.Services;

public class App_User_Service:Base_Service<App_User>, IApp_User_Service
{
        private readonly IApp_User_Repo           _repo;
        private readonly IJwt_Service             _jwtService;
        private readonly IPassword_Hashing_Service _hasherService;
        private readonly ITxn_Manager_Repo        iRepo;
        public App_User_Service
        (
            IApp_User_Repo repo, IJwt_Service jwt, IPassword_Hashing_Service hasher,ITxn_Manager_Repo  Repo
        ) : base(repo)
        {
            _repo          = repo;
            _jwtService    = jwt;
            _hasherService = hasher;
            iRepo          = Repo;

        }
    
        public async Task<string> Register(RegisterUserModel dto)
        {
            try
            {
                var exists = await _repo.FindOneAsync(x => x.Email.ToLower()== dto.Email.ToLower());
                if(exists != null) return "Email already registered.";

                await iRepo.Transaction();
                App_User appUser = new App_User()
                {
                    FirstName    =  dto.FirstName,
                    LastName     =  dto.LastName,
                    Email        =  dto.Email,
                    Role         =  dto.Role,
                    Status       =  "A",   
                    PasswordHash =  _hasherService.HashPassword(dto.Password),
                };
                await _repo.AddAsync(appUser);
                await iRepo.Commit();
                return "OK";
            }
            catch (Exception e)
            {
                return ReturnException(e);
            }
        }

        #region Login
        public async Task<string> Login(LoginDto dto)
        {
            try
            {
                var user = await _repo.FindOneAsync(x =>
                    x.Email.ToLower() == dto.EmailOrPhone.ToLower() || x.PhoneNumber == dto.EmailOrPhone);
                if (user == null)
                    return "Invalid login credentials.";

                await iRepo.Transaction();

                if (!_hasherService.VerifyPassword(dto.Password, user.PasswordHash))
                {
                    user.InvalidLoginTries++;
                    user.FailedLoginCount++;
                    _repo.Update(user);
                    await iRepo.Commit();
                    return "Invalid login credentials.";
                }

                user.LastLoginDate     = DateTime.UtcNow;
                user.InvalidLoginTries = 0;
                _repo.Update(user);
                await iRepo.Commit();
                return _jwtService.GenerateToken(user);
            }
            catch (Exception e)
            {
                return ReturnException(e);  
            }
        }
        #endregion
        
        public string ReturnException(Exception ex)
        {
            //inner exception and exception 
            string finalMesage = ex.Message + ex.StackTrace + ex.InnerException?.InnerException?.Message;
            return finalMesage;
        }
}