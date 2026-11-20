using Server.Domains;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server.Services
{
    public interface IJwt_Service
    {
        string GenerateToken(App_User user);
    }
}
