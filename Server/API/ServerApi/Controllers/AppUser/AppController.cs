using Server.Services;
using Microsoft.AspNetCore.Mvc;
using Server.Models;

namespace ServerApi.Controllers.AppUser
{

    [Route("api/[controller]")]
    [ApiController]
    public class AppController : ControllerBase
    {
        #region Constructor
        private readonly IApp_User_Service           _userService;
        private readonly ILogger<AppController>      _loggerService;
        public AppController
        (
            IApp_User_Service userService, ILogger<AppController> loggerService
        )
        {
            _userService   = userService;
            _loggerService = loggerService;
        }
        #endregion
        
        
        [HttpPost()]
        [Route("register")]
        public async Task<IActionResult> Register(RegisterUserModel dto)
        {
            var user = await _userService.Register(dto);
            return Ok(new { message = user});
        }

        [HttpPost()]
        [Route("login")]
        public async Task<IActionResult> Login(LoginDto dto)
        {
            var token = await _userService.Login(dto);
            return Ok(new { token });
        }

    }
}
