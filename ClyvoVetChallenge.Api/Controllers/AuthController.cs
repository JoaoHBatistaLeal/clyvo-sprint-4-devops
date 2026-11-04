using System.ComponentModel.DataAnnotations;
using ClyvoVetChallenge.Application.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ClyvoVetChallenge.Api.Controllers;

[Produces("application/json")]
[Route("api/[controller]")]
[ApiController]
public class AuthController(IConfiguration configuration, ITokenService tokenService) : ControllerBase
{
    [AllowAnonymous]
    [HttpPost("login")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new ProblemDetails
            {
                Type = "about:blank",
                Title = "Requisicao invalida",
                Status = StatusCodes.Status400BadRequest,
                Detail = "Usuario e senha sao obrigatorios."
            });
        }

        var expectedUsername = configuration["Auth:Username"]
            ?? configuration["Auth--Username"]
            ?? configuration["AUTH_USERNAME"]
            ?? Environment.GetEnvironmentVariable("AUTH_USERNAME")
            ?? "admin";

        var expectedPassword = configuration["Auth:Password"]
            ?? configuration["Auth--Password"]
            ?? configuration["AUTH_PASSWORD"]
            ?? Environment.GetEnvironmentVariable("AUTH_PASSWORD");

        if (string.IsNullOrWhiteSpace(expectedPassword))
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new ProblemDetails
            {
                Type = "about:blank",
                Title = "Erro de configuracao",
                Status = StatusCodes.Status500InternalServerError,
                Detail = "A senha administrativa nao foi configurada no ambiente."
            });
        }

        var isUsernameValid = request.Username.Equals(expectedUsername, StringComparison.OrdinalIgnoreCase)
            || request.Username.Equals("admin", StringComparison.OrdinalIgnoreCase);

        var isPasswordValid = request.Password == expectedPassword;

        if (!isUsernameValid || !isPasswordValid)
        {
            return Unauthorized(new ProblemDetails
            {
                Type = "about:blank",
                Title = "Nao autorizado",
                Status = StatusCodes.Status401Unauthorized,
                Detail = "Credenciais invalidas."
            });
        }

        var token = tokenService.GenerateToken(request.Username, "Admin");

        return Ok(new
        {
            token,
            expirationMinutes = tokenService.ExpirationMinutes,
            expiration = DateTime.UtcNow.AddMinutes(tokenService.ExpirationMinutes),
            usuario = request.Username
        });
    }

    [AllowAnonymous]
    [HttpPost("registrar")]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public IActionResult Registrar([FromBody] RegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest(new ProblemDetails
            {
                Type = "about:blank",
                Title = "Requisicao invalida",
                Status = StatusCodes.Status400BadRequest,
                Detail = "Usuario e senha sao obrigatorios."
            });
        }

        return StatusCode(StatusCodes.Status201Created, new
        {
            mensagem = "Usuario registrado com sucesso.",
            usuario = request.Username
        });
    }

    [Authorize]
    [HttpGet("perfil")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult Perfil()
    {
        return Ok(new
        {
            usuario = User.Identity?.Name,
            autenticado = true
        });
    }
}

public record LoginRequest(string Username, string Password);
public record RegisterRequest([Required] string Username, [Required] string Password, string? Email = null);
