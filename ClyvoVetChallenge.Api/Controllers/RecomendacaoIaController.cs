using ClyvoVetChallenge.Application.DTOs;
using ClyvoVetChallenge.Application.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace ClyvoVetChallenge.Api.Controllers;

using Microsoft.AspNetCore.Authorization;

[AllowAnonymous]
[ApiController]
[Route("api/[controller]")]
public class RecomendacaoIaController(IRecomendacaoIaService recomendacaoIaService) : ControllerBase
{
    [HttpPost("avaliar")]
    [ProducesResponseType(typeof(RecomendacaoIaResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Avaliar([FromBody] RecomendacaoIaRequest request, CancellationToken cancellationToken)
    {
        var response = await recomendacaoIaService.GerarRecomendacaoAsync(request, cancellationToken);
        return Ok(response);
    }

    [HttpGet("animal/{animalId:guid}")]
    [ProducesResponseType(typeof(IEnumerable<RecomendacaoIaResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterHistoricoPorAnimal(Guid animalId, CancellationToken cancellationToken)
    {
        var response = await recomendacaoIaService.ObterHistoricoPorAnimalAsync(animalId, cancellationToken);
        return Ok(response);
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<RecomendacaoIaResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterTodos(CancellationToken cancellationToken)
    {
        var response = await recomendacaoIaService.ObterTodosHistoricosAsync(cancellationToken);
        return Ok(response);
    }
}

