using System.Text;
using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using ClyvoVetChallenge.Api.Exceptions;
using ClyvoVetChallenge.Api.Extensions;
using ClyvoVetChallenge.Api.Health;
using ClyvoVetChallenge.Api.Middlewares;
using ClyvoVetChallenge.Application.Extensions;
using ClyvoVetChallenge.Domain.Entities;
using ClyvoVetChallenge.Infrastructure.Extensions;
using ClyvoVetChallenge.Infrastructure.Persistence;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.IdentityModel.Tokens;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Serilog;
using Serilog.Events;

Env.TraversePath().Load();

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "ClyvoVetChallenge.Api")
    .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] [{CorrelationId}] {Message:lj}{NewLine}{Exception}")
    .WriteTo.File(
        path: "logs/clyvovet-.log",
        rollingInterval: RollingInterval.Day,
        outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] [{CorrelationId}] {Message:lj}{NewLine}{Exception}")
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);

var keyVaultUri = builder.Configuration["KEY_VAULT_URI"]
    ?? Environment.GetEnvironmentVariable("KEY_VAULT_URI")
    ?? builder.Configuration["KeyVault:VaultUri"];

if (string.IsNullOrEmpty(keyVaultUri))
{
    var keyVaultName = builder.Configuration["KEY_VAULT_NAME"]
        ?? Environment.GetEnvironmentVariable("KEY_VAULT_NAME");
    if (!string.IsNullOrEmpty(keyVaultName))
    {
        keyVaultUri = $"https://{keyVaultName}.vault.azure.net/";
    }
}

if (!string.IsNullOrEmpty(keyVaultUri))
{
    try
    {
        builder.Configuration.AddAzureKeyVault(
            new Uri(keyVaultUri),
            new DefaultAzureCredential());
        Log.Information("Azure Key Vault configurado com sucesso a partir de {VaultUri}", keyVaultUri);
    }
    catch (Exception ex)
    {
        Log.Warning(ex, "Nao foi possivel carregar segredos do Azure Key Vault ({VaultUri}). Continuando com variaveis de ambiente.", keyVaultUri);
    }
}

var customPort = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrEmpty(customPort))
{
    builder.WebHost.UseUrls($"http://*:{customPort}");
}

builder.Host.UseSerilog();

var useSqlite = builder.Configuration.GetValue<bool>("Database:UseSqlite");
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? builder.Configuration.GetConnectionString("OracleConnection")
    ?? builder.Configuration["ConnectionStrings:DefaultConnection"]
    ?? builder.Configuration["ConnectionStrings:OracleConnection"]
    ?? builder.Configuration["ConnectionStrings__DefaultConnection"]
    ?? builder.Configuration["ConnectionStrings__OracleConnection"]
    ?? builder.Configuration["ConnectionStrings--DefaultConnection"]
    ?? builder.Configuration["DbConnectionString"];

if (string.IsNullOrWhiteSpace(connectionString))
{
    var dbHost = builder.Configuration["DB_HOST"] ?? Environment.GetEnvironmentVariable("DB_HOST");
    var dbPort = builder.Configuration["DB_PORT"] ?? Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
    var dbName = builder.Configuration["DB_NAME"] ?? Environment.GetEnvironmentVariable("DB_NAME") ?? "db_bytecare";
    var dbUser = builder.Configuration["DB_USER"] ?? Environment.GetEnvironmentVariable("DB_USER") ?? "postgres";
    var dbPass = builder.Configuration["DB_PASSWORD"] ?? Environment.GetEnvironmentVariable("DB_PASSWORD");

    if (!string.IsNullOrWhiteSpace(dbHost) && !string.IsNullOrWhiteSpace(dbPass))
    {
        var csBuilder = new System.Data.Common.DbConnectionStringBuilder
        {
            ["Host"] = dbHost,
            ["Port"] = dbPort,
            ["Database"] = dbName,
            ["Username"] = dbUser,
            ["Password"] = dbPass
        };
        connectionString = csBuilder.ConnectionString;
    }
}

if (!string.IsNullOrWhiteSpace(connectionString))
{
    builder.Configuration["ConnectionStrings:DefaultConnection"] = connectionString;
}

if (!useSqlite && string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "A string de conexao com o banco de dados PostgreSQL ('ConnectionStrings:DefaultConnection') nao foi configurada. " +
        "Configure a conexao via Azure Key Vault ('ConnectionStrings--DefaultConnection') ou variavel de ambiente ('ConnectionStrings__DefaultConnection').");
}

builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddApplicationServices();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerCustom();

builder.Services.AddExceptionHandler<GlobalExceptionHandler>();
builder.Services.AddProblemDetails();
builder.Services.AddControllers();

var jwtKey = builder.Configuration["Jwt:Key"]
    ?? builder.Configuration["Jwt--Key"]
    ?? builder.Configuration["JWT_SECRET"]
    ?? builder.Configuration["JwtSecret"]
    ?? builder.Configuration["JWT_KEY"]
    ?? Environment.GetEnvironmentVariable("JWT_SECRET")
    ?? Environment.GetEnvironmentVariable("JWT_KEY");

if (string.IsNullOrWhiteSpace(jwtKey))
{
    throw new InvalidOperationException(
        "A chave secreta JWT ('Jwt:Key') nao foi configurada. " +
        "Configure o segredo via Azure Key Vault ('Jwt--Key' ou 'JwtSecret') ou variavel de ambiente ('JWT_SECRET').");
}

if (jwtKey.Length < 32)
{
    throw new InvalidOperationException(
        "A chave JWT configurada deve possuir no minimo 32 caracteres (256 bits) para garantir assinatura criptografica segura com HmacSha256.");
}

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuers = ["ClyvoVet", "ByteCareApi", builder.Configuration["Jwt:Issuer"] ?? "ClyvoVet"],
        ValidAudiences = ["ClyvoVetUsers", "ByteCareClient", builder.Configuration["Jwt:Audience"] ?? "ClyvoVetUsers"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});

builder.Services.AddAuthorization();

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("ClyvoVetChallenge.Api"))
    .WithTracing(tracing =>
    {
        tracing
            .AddAspNetCoreInstrumentation(options =>
            {
                options.RecordException = true;
            })
            .AddHttpClientInstrumentation()
            .AddEntityFrameworkCoreInstrumentation();
    })
    .WithMetrics(metrics =>
    {
        metrics
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddRuntimeInstrumentation()
            .AddMeter(
                "Microsoft.AspNetCore.Hosting",
                "Microsoft.AspNetCore.Routing",
                "Microsoft.AspNetCore.Server.Kestrel",
                "System.Net.Http",
                "System.Runtime")
            .AddPrometheusExporter();
    });

builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>("database", failureStatus: HealthStatus.Unhealthy, tags: ["db", "ready"])
    .AddUrlGroup(new Uri("https://fiap.com.br"), name: "fiap-portal", failureStatus: HealthStatus.Degraded, tags: ["external", "ready"]);

var app = builder.Build();

Log.Information("ClyvoVet API iniciada com sucesso.");

app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});

app.UseCors("AllowAll");
app.UseMiddleware<CorrelationIdMiddleware>();
app.UseSerilogRequestLogging();
app.UseExceptionHandler();
app.UseOpenTelemetryPrometheusScrapingEndpoint();

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Clyvo Vet API v1");
    c.RoutePrefix = "swagger";
});

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/", () => Results.Ok(new
{
    application = "ClyvoVet API - Sprint 4 DevOps",
    status = "Online",
    swagger = "/swagger/index.html",
    wellcome = "/wellcome",
    health = "/health"
}))
.WithName("Root")
.WithTags("Health")
.AllowAnonymous();

app.MapGet("/wellcome", () => Results.Text("ClyvoVet Sprint 4 - Deploy Automatico Verificado v4"))
   .WithName("Wellcome")
   .WithTags("Health")
   .Produces<string>(StatusCodes.Status200OK)
   .AllowAnonymous();

app.MapControllers();

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = HealthCheckResponseWriter.WriteJsonResponse
});

app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = HealthCheckResponseWriter.WriteJsonResponse
});

app.MapHealthChecks("/health/live", new HealthCheckOptions
{
    Predicate = _ => false,
    ResponseWriter = HealthCheckResponseWriter.WriteJsonResponse
});

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        if (context.Database.IsNpgsql())
        {
            var maxRetries = 10;
            for (var retry = 1; retry <= maxRetries; retry++)
            {
                try
                {
                    logger.LogInformation("Tentando aplicar migrations no PostgreSQL (tentativa {Retry}/{MaxRetries})...", retry, maxRetries);
                    context.Database.Migrate();
                    if (!context.Donos.Any())
                    {
                        var dono1 = new Dono("Carlos Eduardo Silva", "12345678901", "carlos.silva@clyvovet.com", "11987654321", new DateOnly(1985, 4, 12), "Av. Paulista, 1000 - Bela Vista, Sao Paulo - SP");
                        var dono2 = new Dono("Mariana Ferreira Costa", "98765432100", "mariana.costa@clyvovet.com", "11912345678", new DateOnly(1990, 9, 25), "Rua Augusta, 500 - Consolacao, Sao Paulo - SP");
                        context.Donos.AddRange(dono1, dono2);

                        var clinica1 = new Clinica("12345678000190", "contato@clyvovet.com", "1133334444", "Av. Paulista, 1500 - Sao Paulo - SP", "24 Horas");
                        var clinica2 = new Clinica("98765432000110", "unidade.sul@clyvovet.com", "1155556666", "Av. Ibirapuera, 2000 - Sao Paulo - SP", "08:00 as 20:00");
                        context.Clinicas.AddRange(clinica1, clinica2);

                        var vet1 = new Veterinario("Dr. Roberto Almeida", "CRMV-SP-10234", "Clinica Geral e Cirurgia", "11977778888", "roberto.almeida@clyvovet.com");
                        var vet2 = new Veterinario("Dra. Camila Mendes", "CRMV-SP-20456", "Felinos e Dermatologia", "11966665555", "camila.mendes@clyvovet.com");
                        context.Veterinarios.AddRange(vet1, vet2);

                        var animal1 = new Animal(dono1.Id, "Rex", "Canina", "Golden Retriever", "Macho", new DateOnly(2021, 6, 15), 32.50m);
                        var animal2 = new Animal(dono2.Id, "Mia", "Felina", "Siames", "Femea", new DateOnly(2022, 3, 20), 4.10m);
                        context.Animais.AddRange(animal1, animal2);

                        var consulta1 = new Consulta(animal1.Id, vet1.Id, clinica1.Id, new DateOnly(2026, 11, 10), new TimeOnly(10, 0), "Check-up preventivo anual e vacinacao", "Presencial");
                        var consulta2 = new Consulta(animal2.Id, vet2.Id, clinica2.Id, new DateOnly(2026, 11, 12), new TimeOnly(14, 30), "Avaliacao dermatologica de rotina", "Presencial");
                        context.Consultas.AddRange(consulta1, consulta2);

                        context.Sintomas.AddRange(
                            new Sintoma("Apatia"),
                            new Sintoma("Falta de apetite"),
                            new Sintoma("Tosse")
                        );

                        context.SaveChanges();
                    }
                    logger.LogInformation("Migrations e carga inicial aplicadas com sucesso no PostgreSQL.");
                    break;
                }
                catch (Exception ex) when (retry < maxRetries)
                {
                    logger.LogWarning(ex, "Falha ao conectar ou aplicar migrations no PostgreSQL (tentativa {Retry}/{MaxRetries}). Aguardando 3s...", retry, maxRetries);
                    Thread.Sleep(3000);
                }
            }
        }
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Erro ao aplicar migrations no PostgreSQL durante a inicializacao.");
    }
}

app.Run();

public partial class Program { }
