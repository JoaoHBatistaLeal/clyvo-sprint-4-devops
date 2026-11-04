import os
import shutil
import diagrams
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, FancyArrowPatch, Ellipse
from matplotlib.offsetbox import OffsetImage, AnnotationBbox
from PIL import Image

def get_res_root():
    d_root = os.path.dirname(diagrams.__file__)
    c1 = os.path.join(d_root, "resources")
    c2 = os.path.join(os.path.dirname(d_root), "resources")
    if os.path.exists(c1):
        return c1
    if os.path.exists(c2):
        return c2
    return c1

RES_ROOT = get_res_root()

def find_icon(*relative_candidates):
    for rel in relative_candidates:
        full = os.path.join(RES_ROOT, *rel.split("/"))
        if os.path.exists(full):
            return full
    return None

ICONS = {
    "github": find_icon("onprem/vcs/github.png"),
    "devops": find_icon("azure/devops/devops.png", "azure/devops/pipelines.png"),
    "pipelines": find_icon("azure/devops/pipelines.png"),
    "repos": find_icon("azure/devops/repos.png"),
    "artifacts": find_icon("azure/devops/artifacts.png"),
    "agent": find_icon("azure/compute/container-instances.png", "azure/devops/pipelines.png"),
    "azure": find_icon("azure/general/all-resources.png", "azure/compute/app-services.png"),
    "app_service": find_icon("azure/compute/app-services.png"),
    "service_plan": find_icon("azure/compute/app-service-plans.png", "azure/compute/app-services.png"),
    "keyvault": find_icon("azure/security/key-vaults.png", "azure/general/all-resources.png"),
    "postgres": find_icon("azure/database/database-for-postgresql-servers.png", "onprem/database/postgresql.png"),
    "sql": find_icon("azure/database/sql-databases.png", "azure/database/database-for-postgresql-servers.png"),
    "user": find_icon("onprem/client/user.png", "azure/identity/users.png"),
    "users": find_icon("onprem/client/users.png", "azure/identity/users.png"),
    "client": find_icon("onprem/client/client.png", "generic/device/mobile.png"),
}

def place_icon(ax, icon_key, xy, zoom=0.30, zorder=10):
    path = ICONS.get(icon_key)
    if path and os.path.exists(path):
        img = Image.open(path).convert("RGBA")
        img = img.resize((128, 128), Image.Resampling.LANCZOS)
        oi = OffsetImage(img, zoom=zoom)
        ab = AnnotationBbox(oi, xy, frameon=False, zorder=zorder)
        ax.add_artist(ab)
        return True
    return False

def draw_rounded_box(ax, x, y, w, h, facecolor='#F3F3F3', edgecolor='#9E9E9E', lw=1.6, radius=2.5, linestyle='-', alpha=1.0, zorder=2):
    patch = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0.1,rounding_size={radius}",
        facecolor=facecolor, edgecolor=edgecolor, linewidth=lw, linestyle=linestyle, alpha=alpha, zorder=zorder
    )
    ax.add_patch(patch)
    return patch

def draw_num_circle(ax, x, y, num, zorder=20):
    c = Circle((x, y), 2.2, facecolor='#FFFFFF', edgecolor='#424242', linewidth=1.6, zorder=zorder)
    ax.add_patch(c)
    ax.text(x, y, str(num), fontsize=9.0, fontweight='bold', color='#212121', ha='center', va='center', zorder=zorder+1)

def draw_ortho_arrow(ax, pts, color='#37474F', lw=1.5, linestyle='-', zorder=12):
    if len(pts) > 2:
        xs = [p[0] for p in pts[:-1]]
        ys = [p[1] for p in pts[:-1]]
        ax.plot(xs, ys, color=color, lw=lw, linestyle=linestyle, zorder=zorder)
    arrow = FancyArrowPatch(
        pts[-2], pts[-1],
        connectionstyle="arc3,rad=0.0",
        arrowstyle='-|>,head_length=5.5,head_width=3.4',
        color=color, linewidth=lw, linestyle=linestyle, zorder=zorder
    )
    ax.add_patch(arrow)

fig, ax = plt.subplots(figsize=(24, 13.5), dpi=150)
ax.set_xlim(0, 240)
ax.set_ylim(0, 135)
ax.axis('off')
fig.patch.set_facecolor('#FFFFFF')

for gx in [46, 118, 184]:
    ax.plot([gx, gx], [18, 126], color='#D0D7DE', lw=0.9, linestyle=(0, (3, 3)), zorder=1)

draw_rounded_box(ax, 4, 126.5, 232, 6.8, facecolor='#1E293B', edgecolor='#0F172A', lw=1.5, radius=1.5, zorder=3)
ax.text(8, 130.0, "ARQUITETURA EM NUVEM & ESTEIRA CI/CD — CLYVOVET (BYTECARE) | SPRINT 4 (FIAP 2TDSPG)", fontsize=12.5, fontweight='bold', color='#FFFFFF', ha='left', va='center', zorder=4)
ax.text(232, 130.0, "Subscription: 2026-2TDSPJ-JOAO-H-BATISTA-LEAL-RM564361  |  RG: rg-clyvo-sprint4 (canadacentral)", fontsize=8.8, fontweight='bold', color='#38BDF8', ha='right', va='center', zorder=4)

draw_rounded_box(ax, 122, 112.5, 56, 11.5, facecolor='#FFFFFF', edgecolor='#0284C7', lw=1.5, radius=2.0, zorder=6)
place_icon(ax, "user", (128.5, 118.2), zoom=0.30, zorder=10)
ax.text(134.5, 120.2, "Persona: Usuário Final / Professor Avaliador", fontsize=8.5, fontweight='bold', color='#0F172A', ha='left', va='center', zorder=10)
ax.text(134.5, 116.2, "• Consome API em Produção via HTTPS (/swagger, /wellcome, /health)\n• Executa CRUD Completo (POST, GET, PUT, DELETE) e valida via SELECT", fontsize=7.2, color='#334155', ha='left', va='center', zorder=10)

draw_rounded_box(ax, 6, 20, 174, 90, facecolor='#F3F3F3', edgecolor='#9E9E9E', lw=1.8, radius=6.0, zorder=2)

place_icon(ax, "github", (36, 102.5), zoom=0.32, zorder=10)
ax.text(40.5, 103.3, "https://github.com/JoaoHBatistaLeal/clyvo-sprint-4-devops.git", fontsize=8.2, fontweight='bold', color='#0F172A', ha='left', va='center')
ax.text(40.5, 100.3, "Branch Principal: master (Default)  •  Código Limpo (Zero Segredos / Sem Docker)", fontsize=7.0, color='#475569', ha='left', va='center')

ax.text(36, 94.8, "Integração Dual-Push\n(GitHub + Azure Repos)", fontsize=7.0, fontweight='bold', color='#1E293B', ha='center', va='center')
draw_ortho_arrow(ax, [(36, 99.2), (36, 96.5)], color='#212121')

draw_rounded_box(ax, 27.5, 86.2, 34, 5.0, facecolor='#FFFFFF', edgecolor='#CBD5E1', lw=1.2, radius=0.8, zorder=6)
place_icon(ax, "devops", (30.8, 88.7), zoom=0.20, zorder=10)
ax.text(46.0, 89.4, "Azure DevOps: OrgJJEGG", fontsize=8.0, fontweight='bold', color='#0078D4', ha='center', va='center', zorder=10)
ax.text(46.0, 87.3, "Project: Sprint 4 - Azure DevOps", fontsize=6.8, fontweight='bold', color='#334155', ha='center', va='center', zorder=10)

place_icon(ax, "users", (16.5, 72.5), zoom=0.32, zorder=10)
ax.text(16.5, 67.5, "Persona:\nDesenvolvedor", fontsize=7.5, fontweight='bold', color='#0F172A', ha='center', va='center')

draw_rounded_box(ax, 13.5, 57.5, 6.0, 4.8, facecolor='#E3F2FD', edgecolor='#1976D2', lw=1.6, radius=0.5, zorder=8)
ax.plot([16.5, 16.5], [57.5, 56.0], color='#1976D2', lw=2.0, zorder=8)
ax.plot([14.8, 18.2], [56.0, 56.0], color='#1976D2', lw=2.0, zorder=8)
ax.text(16.5, 59.9, "✓", fontsize=14, fontweight='bold', color='#43A047', ha='center', va='center', zorder=9)

ax.text(16.5, 53.8, "DESKTOP (WORKSTATION)", fontsize=7.2, fontweight='bold', color='#1E293B', ha='center')
ax.text(
    16.5, 46.5,
    "• IDE: VS Code / Visual Studio\n"
    "• Solution: ClyvoVetChallenge.sln\n"
    "• Stack: C# / .NET 9.0 (ASP.NET Core)\n"
    "• ORM: EF Core 9 + Npgsql\n"
    "• Testes: 140 xUnit (104 Unit + 36 Int)\n"
    "• IaC: infra/criar-infra.ps1",
    fontsize=6.6, fontweight='bold', color='#334155', ha='center', va='center'
)

draw_rounded_box(ax, 28, 25, 42, 60, facecolor='#E1D5E7', edgecolor='#9673A6', lw=1.8, radius=3.5, zorder=4)
ax.text(49, 82.5, "Pipeline: ClyvoVet-CI-CD (azure-pipelines.yml)", fontsize=7.8, fontweight='bold', color='#4A148C', ha='center', va='center', zorder=6)

place_icon(ax, "repos", (36, 72.5), zoom=0.32, zorder=10)
ax.text(36, 67.2, "Azure Repos Git\n(branch: master)", fontsize=6.8, fontweight='bold', color='#212121', ha='center', va='center')

draw_ortho_arrow(ax, [(20.5, 72.5), (32.5, 72.5)], color='#212121')
draw_num_circle(ax, 26.0, 72.5, 1)

draw_ortho_arrow(ax, [(36, 92.8), (36, 76.2)], color='#212121')
draw_num_circle(ax, 36.0, 80.0, 2)

place_icon(ax, "pipelines", (52.5, 72.5), zoom=0.34, zorder=10)
draw_ortho_arrow(ax, [(39.5, 72.5), (48.8, 72.5)], color='#212121')
draw_num_circle(ax, 44.2, 72.5, 3)

ax.text(52.5, 66.8, "Trigger (Gatilho Automático)\nbranch: master", fontsize=6.8, fontweight='bold', color='#212121', ha='center', va='center')
ax.text(52.5, 61.8, "STAGE 1: BuildTestes (CI)\nJob: BuildTest", fontsize=7.5, fontweight='bold', color='#4A148C', ha='center', va='center')
ax.text(
    52.5, 55.2,
    "• UseDotNet@2 (SDK 9.x)\n"
    "• dotnet restore & build (Release)\n"
    "• dotnet test (140 Testes xUnit)\n"
    "• dotnet publish & ArchiveFiles",
    fontsize=6.5, fontweight='bold', color='#212121', ha='center', va='center'
)
draw_num_circle(ax, 52.5, 48.2, 4)

place_icon(ax, "agent", (52.5, 39.0), zoom=0.34, zorder=10)
ax.text(
    52.5, 31.0,
    "Agent Pool: Default\n"
    "• Agente: agent-clyvo-sprint4\n"
    "• OS: Windows  |  .NET 9 CLI",
    fontsize=6.8, fontweight='bold', color='#212121', ha='center', va='center'
)

place_icon(ax, "artifacts", (65.0, 74.5), zoom=0.34, zorder=10)
ax.text(65.0, 69.2, "PublishPipelineArtifact\nArtefato: 'app'", fontsize=6.6, fontweight='bold', color='#212121', ha='center', va='center')
ax.text(
    71.2, 74.5,
    "app.zip\n"
    "• ClyvoVetChallenge.Api.dll\n"
    "• ClyvoVetChallenge.*.pdb\n"
    "• appsettings.json\n"
    "• web.config",
    fontsize=6.4, fontweight='bold', color='#212121', ha='left', va='center'
)
draw_ortho_arrow(ax, [(56.0, 72.5), (61.5, 72.5), (61.5, 74.5)], color='#212121')
draw_num_circle(ax, 65.0, 81.5, 5)

place_icon(ax, "pipelines", (88.0, 62.5), zoom=0.35, zorder=10)
draw_ortho_arrow(ax, [(70.0, 70.0), (88.0, 70.0), (88.0, 66.5)], color='#212121')

ax.text(88.0, 56.8, "Trigger Automático (dependsOn: BuildTestes)", fontsize=6.6, fontweight='bold', color='#212121', ha='center')
ax.text(88.0, 52.2, "STAGE 2: Deploy (CD)\nJob: DeployWebApp", fontsize=7.6, fontweight='bold', color='#047857', ha='center', va='center')
ax.text(
    88.0, 45.8,
    "• DownloadPipelineArtifact@2 ('app')\n"
    "• AzureAppServiceSettings@1\n"
    "• AzureWebApp@1 (zipDeploy)",
    fontsize=6.5, fontweight='bold', color='#212121', ha='center', va='center'
)
draw_num_circle(ax, 88.0, 39.5, 6)

draw_rounded_box(ax, 74.5, 23.5, 27.0, 12.5, facecolor='#FFFBEB', edgecolor='#D97706', lw=1.4, radius=1.8, zorder=6)
place_icon(ax, "keyvault", (78.2, 29.8), zoom=0.24, zorder=10)
ax.text(80.8, 33.2, "Service Connection & Library Secrets", fontsize=6.8, fontweight='bold', color='#B45309', ha='left', va='center', zorder=10)
ax.text(
    80.8, 28.2,
    "• Conn: azure-clyvo-sprint4 (ARM)\n"
    "• NOME_WEBAPP = clyvo-sprint4-rm564361\n"
    "• [Secret] OracleConnection (Postgres)\n"
    "• [Secret] JWT_SECRET",
    fontsize=6.1, fontweight='bold', color='#334155', ha='left', va='center', zorder=10
)
draw_ortho_arrow(ax, [(88.0, 36.0), (88.0, 42.0)], color='#D97706', linestyle='--')

rel_ellipse = Ellipse((105.5, 62.5), 11.5, 5.0, facecolor='#FFFFFF', edgecolor='#0078D4', lw=1.4, zorder=8)
ax.add_patch(rel_ellipse)
ax.text(105.5, 62.5, "Relationship\n(ARM + ZipDeploy)", fontsize=6.5, fontweight='bold', color='#0078D4', ha='center', va='center', zorder=9)
draw_ortho_arrow(ax, [(92.0, 62.5), (99.7, 62.5)], color='#212121')
draw_ortho_arrow(ax, [(111.3, 62.5), (120.5, 62.5)], color='#0078D4', linestyle='--')
draw_num_circle(ax, 105.5, 56.2, 7)

draw_rounded_box(ax, 116.0, 23.0, 60.5, 81.0, facecolor='none', edgecolor='#0284C7', lw=1.6, radius=4.5, linestyle=(0, (4, 2)), zorder=4)

draw_rounded_box(ax, 114.0, 99.0, 28.5, 6.2, facecolor='#FFFFFF', edgecolor='#CBD5E1', lw=1.2, radius=1.0, zorder=8)
place_icon(ax, "azure", (118.0, 102.1), zoom=0.28, zorder=10)
ax.text(130.5, 103.0, "Microsoft Azure (PaaS)", fontsize=8.0, fontweight='bold', color='#0078D4', ha='center', va='center', zorder=10)
ax.text(130.5, 100.6, "RG: rg-clyvo-sprint4 (canadacentral)", fontsize=6.6, fontweight='bold', color='#334155', ha='center', va='center', zorder=10)

draw_rounded_box(ax, 120.5, 26.5, 52.0, 70.5, facecolor='#3B8ED0', edgecolor='#1F6AA5', lw=1.8, radius=3.0, zorder=5)
ax.text(146.5, 93.8, "AMBIENTE DE PRODUÇÃO (ASPNETCORE_ENVIRONMENT = Production)", fontsize=8.0, fontweight='bold', color='#FFFFFF', ha='center', va='center', zorder=10)

draw_rounded_box(ax, 124.0, 77.5, 45.0, 13.5, facecolor='#FFFFFF', edgecolor='#BAE6FD', lw=1.3, radius=1.8, zorder=7)
place_icon(ax, "service_plan", (130.0, 84.2), zoom=0.32, zorder=10)
ax.text(135.5, 86.8, "Azure App Service Plan", fontsize=8.2, fontweight='bold', color='#0369A1', ha='left', va='center', zorder=10)
ax.text(
    135.5, 82.0,
    "• Nome: plan-clyvo-sprint4\n"
    "• Tier / SKU: F1 (Free)  |  OS: Windows  |  Região: Canada Central",
    fontsize=6.8, fontweight='bold', color='#334155', ha='left', va='center', zorder=10
)

draw_rounded_box(ax, 124.0, 48.0, 45.0, 26.0, facecolor='#FFFFFF', edgecolor='#BAE6FD', lw=1.3, radius=1.8, zorder=7)
place_icon(ax, "app_service", (130.0, 64.5), zoom=0.35, zorder=10)
ax.text(135.5, 69.5, "Azure Web App (API RESTful .NET 9)", fontsize=8.5, fontweight='bold', color='#0078D4', ha='left', va='center', zorder=10)
ax.text(
    135.5, 58.5,
    "• Nome: clyvo-sprint4-rm564361\n"
    "• URL: https://clyvo-sprint4-rm564361.azurewebsites.net\n"
    "• Rotas de Validação e Observabilidade:\n"
    "  - GET /swagger/index.html (OpenAPI UI em Produção)\n"
    "  - GET /wellcome (Prova de CI/CD) & GET /health (Healthy)\n"
    "• Endpoints Core: /api/Dono, /api/Animal, /api/Consulta,\n"
    "  /api/Clinica, /api/Veterinario",
    fontsize=6.6, fontweight='bold', color='#1E293B', ha='left', va='center', zorder=10
)
draw_num_circle(ax, 124.0, 62.5, 8)

draw_rounded_box(ax, 124.0, 29.5, 45.0, 15.0, facecolor='#F0F9FF', edgecolor='#7DD3FC', lw=1.2, radius=1.8, zorder=7)
ax.text(146.5, 41.8, "Application Settings Configuradas via Pipeline CD", fontsize=7.5, fontweight='bold', color='#0369A1', ha='center', va='center', zorder=10)
ax.text(
    146.5, 35.2,
    "• ASPNETCORE_ENVIRONMENT = Production\n"
    "• ConnectionStrings__OracleConnection = $(OracleConnection)\n"
    "• Jwt__Key / JWT_SECRET = $(JWT_SECRET)",
    fontsize=6.6, fontweight='bold', color='#334155', ha='center', va='center', zorder=10
)

draw_ortho_arrow(ax, [(146.5, 112.5), (146.5, 74.0)], color='#0D9488', lw=1.8)
draw_num_circle(ax, 146.5, 107.5, 10)

draw_rounded_box(ax, 186.0, 20.0, 49.0, 90.0, facecolor='#F3F3F3', edgecolor='#9E9E9E', lw=1.8, radius=4.5, zorder=2)

draw_rounded_box(ax, 184.5, 104.5, 36.0, 5.5, facecolor='#0284C7', edgecolor='#0369A1', lw=1.2, radius=0.8, zorder=8)
ax.text(202.5, 107.2, "AZURE DATABASE FOR POSTGRESQL (PaaS)", fontsize=8.0, fontweight='bold', color='#FFFFFF', ha='center', va='center', zorder=9)

place_icon(ax, "postgres", (210.5, 91.5), zoom=0.48, zorder=10)
ax.text(210.5, 83.2, "Flexible Server: pg-clyvo-sprint4", fontsize=8.5, fontweight='bold', color='#0F172A', ha='center', va='center', zorder=10)
ax.text(
    210.5, 77.5,
    "Host: pg-clyvo-sprint4.postgres.database.azure.com\n"
    "Engine: PostgreSQL 16  |  Tier: Standard_B1ms\n"
    "Porta: 5432  |  SSL Mode: Require",
    fontsize=6.8, fontweight='bold', color='#334155', ha='center', va='center', zorder=10
)

draw_rounded_box(ax, 190.0, 24.5, 41.0, 47.0, facecolor='#FFFFFF', edgecolor='#94A3B8', lw=1.4, radius=2.5, zorder=5)
place_icon(ax, "sql", (210.5, 63.0), zoom=0.38, zorder=10)
ax.text(210.5, 56.0, "DATA - PRD: db_clyvovet", fontsize=8.5, fontweight='bold', color='#0369A1', ha='center', va='center', zorder=10)
ax.text(
    210.5, 40.5,
    "Schema Inicializado via script_bd.sql:\n\n"
    "• \"TB_DONO\" (PK: Id, Cpf, Email)\n"
    "• \"TB_ANIMAL\" (PK: Id, FK: DonoId)\n"
    "• \"TB_CONSULTA\" (PK: Id, FK: AnimalId)\n"
    "• \"TB_CLINICA\" & \"TB_VETERINARIO\"\n"
    "• \"TB_PROCEDIMENTO\" & \"TB_AUDIT_LOG\"\n\n"
    "Stored Procedures:\n"
    "• sp_registrar_dono\n"
    "• sp_agendar_consulta",
    fontsize=6.7, fontweight='bold', color='#1E293B', ha='center', va='center', zorder=10
)

draw_ortho_arrow(ax, [(169.0, 58.0), (190.0, 58.0)], color='#0284C7', lw=2.0)
draw_num_circle(ax, 179.5, 58.0, 9)
ax.text(179.5, 53.5, "EF Core / Npgsql\n(TCP 5432 SSL)", fontsize=6.5, fontweight='bold', color='#0369A1', ha='center', va='center')

draw_ortho_arrow(ax, [(178.0, 118.2), (226.0, 118.2), (226.0, 71.5)], color='#15803D', lw=1.6, linestyle='--')
draw_num_circle(ax, 226.0, 95.0, 11)
ax.text(226.0, 90.0, "Auditoria CRUD\n(SELECT SQL)", fontsize=6.6, fontweight='bold', color='#15803D', ha='center', va='center')

draw_rounded_box(ax, 6, 2.0, 229, 15.5, facecolor='#FFFFFF', edgecolor='#CBD5E1', lw=1.5, radius=1.8, zorder=3)
draw_rounded_box(ax, 6, 13.8, 229, 3.7, facecolor='#1E293B', edgecolor='none', lw=0, radius=1.0, zorder=4)
ax.text(9, 15.6, "FLUXO NUMERADO DA ESTEIRA CI/CD E ARQUITETURA EM NUVEM (ONDE CADA FERRAMENTA ATUA)", fontsize=8.5, fontweight='bold', color='#FFFFFF', ha='left', va='center', zorder=5)

col1 = [
    "1. Commit Local (VS Code / Git): Desenvolvedor altera código C# (.NET 9) e realiza commit na branch master.",
    "2. Dual-Push (GitHub & Azure Repos): Um único git push atualiza simultaneamente o GitHub e o Azure Repos.",
    "3. Trigger CI (Azure Pipelines): Alteração na branch master dispara automaticamente o estágio BuildTestes.",
    "4. Build & Testes (Agent Pool Default): Compila em Release e executa os 140 testes automatizados xUnit."
]
col2 = [
    "5. Publicação de Artefato (Azure Artifacts): Gera e publica o pacote imutável app.zip no pipeline.",
    "6. Trigger CD (Stage Deploy): Sucesso do CI inicia o estágio Deploy e faz download do artefato app.zip.",
    "7. Service Connection & Segredos: Autentica no Azure via azure-clyvo-sprint4 e injeta variáveis secretas.",
    "8. Deploy em Produção (Azure Web App): Publica a API via ZipDeploy no Web App clyvo-sprint4-rm564361."
]
col3 = [
    "9. Persistência PaaS (EF Core / Npgsql): Web App lê e grava no Azure Database for PostgreSQL (db_clyvovet).",
    "10. Consumo HTTPS (Swagger UI): Usuário/Avaliador acessa /wellcome, /health e executa CRUD via REST.",
    "11. Evidência no Banco (Cliente SQL): Comprovação física de INSERT, SELECT, UPDATE e DELETE via SELECT."
]

for idx, col in enumerate([col1, col2, col3]):
    ly = 11.6
    lx = 8.5 + idx * 76.5
    for line in col:
        ax.text(lx, ly, line, fontsize=6.9, fontweight='bold', color='#1E293B', ha='left', va='center', zorder=5)
        ly -= 2.6

plt.tight_layout(pad=0.2)
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out_root = os.path.join(base_dir, "docs", "arquitetura.png")
out_arch = os.path.join(base_dir, "docs", "architecture", "azure_architecture.png")
os.makedirs(os.path.dirname(out_arch), exist_ok=True)
plt.savefig(out_root, dpi=150, facecolor=fig.get_facecolor(), edgecolor='none')
shutil.copyfile(out_root, out_arch)
plt.close()
print("Diagrama gerado com sucesso em docs/arquitetura.png e docs/architecture/azure_architecture.png")
