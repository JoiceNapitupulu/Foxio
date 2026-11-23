using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace Foxio.API.Controllers;

[ApiController]
public abstract class BaseApiController : ControllerBase
{
    protected Guid GetUserId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(idStr) || !Guid.TryParse(idStr, out var userId))
        {
            throw new UnauthorizedAccessException("User tidak terautentikasi.");
        }
        return userId;
    }
}
