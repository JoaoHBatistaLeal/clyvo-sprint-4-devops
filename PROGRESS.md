### Relatorio Tecnico de Progresso e Engenharia DevOps — Sprint 4 (ClyvoVet / ByteCare)

**Disciplina**: DevOps Tools & Cloud Computing — FIAP 2026
**Turma**: 2TDSPG
**Solucao**: ClyvoVet (ByteCare) — Ecossistema RESTful de Gestao Clinica Veterinaria em .NET 9

**Integrantes do Grupo**:
* Erik Naoki Miyasato — RM: 565771
* Gustavo Arthur Carvalho Sartori — RM: 561650
* Gutemberg Rocha Silva — RM: 562267
* Joao Henrique Batista Leal — RM: 564361
* Juliana da Silva Stigliani — RM: 561171

---

### Visao Geral Executiva

Este documento (`PROGRESS.md`) registra de forma exaustiva todas as intervencoes arquiteturais, de engenharia de software, banco de dados relacional em nuvem, infraestrutura como codigo (IaC) e automacao de Integracao e Entrega Continua (CI/CD) realizadas na **Sprint 4** do projeto **ClyvoVet (ByteCare)**.

Para cada uma das **9 Etapas** executadas, este relatorio detalha:
1. **O que foi feito** (Escopo tecnico e entregaveis gerados);
2. **Como foi feito** (Comandos, ferramentas, fluxos, arquitetura e implementacao);
3. **Por que foi feito** (Motivacao tecnica, requisitos academicos e boas praticas DevSecOps);
4. **Como isso impacta o projeto** (Beneficios diretos em confiabilidade, seguranca, escalabilidade, governanca e experiencia de entrega).

---

### Etapa 1 — Migracao Estrutural, Higienizacao PaaS e Blindagem de Seguranca (DevSecOps)

#### 1. O que foi feito
* Migracao completa da solucao `.NET 9` (`ClyvoVetChallenge.sln` e seus 6 projetos: `Api`, `Domain`, `Application`, `Infrastructure`, `Tests.Unit` e `Tests.Integration`) do repositorio legado (`clyvovet-csharp`) para o repositorio oficial da entrega (`clyvo-sprint-4-devops`).
* Remocao integral de todos os artefatos de containerizacao e scripts legados de infraestrutura (`Dockerfile`, `.dockerignore`, `docker-compose.yml` e `deploy.sh`).
* Sanitizacao total dos arquivos de configuracao `ClyvoVetChallenge.Api/appsettings.json` e `ClyvoVetChallenge.Api/appsettings.Development.json`, removendo quaisquer credenciais, strings de conexao e chaves JWT hardcoded.
* Limpeza rigorosa de comentarios e caracteres nao padronizados (zero emojis e zero comentarios de codigo) em todos os arquivos `.cs`, `.ps1`, `.yml`, `.sql` e `.md` do repositorio.
* Configuracao do `ClyvoVetChallenge.Api/Program.cs` para:
  * Expor o Swagger UI (`/swagger/index.html`) tanto em ambiente de desenvolvimento quanto em producao (`Production`) no Azure App Service;
  * Expor o endpoint raiz (`/`) com metadados de status da API;
  * Expor o endpoint `/wellcome` para validacao instantanea de deploy continuo;
  * Expor o endpoint `/health` com verificacao ativa de conectividade com o banco de dados em nuvem;
  * Suportar resolucao dinamica de provedor de banco de dados (PostgreSQL via `Npgsql`, Oracle via `UseOracle` ou `InMemory` para testes) a partir da string de conexao injetada pelo Azure App Service.

#### 2. Como foi feito
* Os projetos foram copiados preservando a arquitetura em camadas (Clean Architecture / DDD: `Domain` -> `Application` -> `Infrastructure` -> `Api`), descartando pastas transitorias (`bin/`, `obj/`, `.vs/`).
* Nos arquivos `appsettings.json` e `appsettings.Development.json`, todas as chaves sensiveis (`ConnectionStrings:OracleConnection`, `Jwt:Key`, `ApiKeyAttribute`) foram substituidas por strings vazias (`""`).
* No `Program.cs`, a logica de inicializacao do `ClyvoVetDbContext` foi configurada para inspecionar a string de conexao recebida via variavel de ambiente (`ConnectionStrings__OracleConnection` ou `ORACLE_CONNECTION_STRING`): quando contem `Host=` ou `postgres`, ativa `options.UseNpgsql(connectionString)`; quando contem `Data Source=`, ativa `options.UseOracle(connectionString)`.
* Foi executado um script automatizado de auditoria sintatica em C#/PowerShell para varrer recursivamente todos os 147 arquivos do repositorio e garantir `0` ocorrencias de emojis ou comentarios residuais.

#### 3. Por que foi feito
* **Transicao de Containers (IaaS/CaaS) para PaaS Nativo**: O escopo da Sprint 4 exige implantacao nativa em plataforma gerenciada (**Azure App Service Web App**), tornando `Dockerfile` e `docker-compose.yml` desnecessarios e conflitantes com o modelo de entrega via pacote `.zip` (`ZipDeploy`).
* **Conformidade DevSecOps (Zero Secrets in Git)**: Manter senhas de banco de dados ou chaves de assinatura JWT em arquivos versionados no Git representa uma vulnerabilidade critica de seguranca (vazamento de credenciais no historico de commits).
* **Observabilidade em Nuvem**: Em ambientes PaaS avaliados externamente, o Swagger UI precisa estar acessivel em producao para permitir inspecao imediata dos contratos OpenAPI e execucao de testes manuais pelo avaliador.

#### 4. Como isso impacta o projeto
* **Seguranca de Producao**: O codigo-fonte pode ser compartilhado entre multiplos repositorios (GitHub e Azure Repos) sem risco de exposicao de credenciais do Azure Database for PostgreSQL.
* **Desacoplamento de Ambiente**: O mesmo binario compilado no pipeline roda localmente, no agente de CI (com banco em memoria) e no Azure App Service (conectado ao PostgreSQL PaaS) apenas trocando variaveis de ambiente externas.
* **Verificabilidade Imediata**: Qualquer mudanca publicada pela esteira CI/CD pode ser verificada em segundos atraves das rotas `/wellcome`, `/health` e `/swagger/index.html`.

---

### Etapa 2 — Suite de Testes Automatizados (Unitarios e Integracao) e Build Local

#### 1. O que foi feito
* Validacao e expansao da suite de testes automatizados com **xUnit**, **Moq**, **FluentAssertions** e **Microsoft.AspNetCore.Mvc.Testing** (`WebApplicationFactory<Program>`).
* Inclusao de teste de integracao dedicado para a rota `/wellcome` em `ClyvoVetChallenge.Tests.Integration/StatusApiTests.cs`, validando HTTP `200 OK` e o conteudo textual retornado pela API.
* Execucao completa de `dotnet restore`, `dotnet build --configuration Release` e `dotnet test --configuration Release`, totalizando **140 testes automatizados aprovados (`0 Failed`)**:
  * **104 Testes Unitarios** (`ClyvoVetChallenge.Tests.Unit`): Regras de negocio de dominio, servicos de aplicacao (`DonoService`, `AnimalService`, `ConsultaService`, `ClinicaService`, `VeterinarioService`), validadores FluentValidation e autenticacao.
  * **36 Testes de Integracao** (`ClyvoVetChallenge.Tests.Integration`): Fluxos HTTP completos nos controllers (`DonoController`, `AnimalController`, `ConsultaController`, `ClinicaController`, `VeterinarioController`, `AuthController`), HATEOAS, paginacao, tratamento de erros (`ProblemDetails`) e rotas de status (`/`, `/wellcome`, `/health`).

#### 2. Como foi feito
* Utilizou-se o `CustomWebApplicationFactory` nos testes de integracao para substituir o banco de dados de producao por um banco isolado em memoria (`UseInMemoryDatabase`) e substituir o health check externo por um check controlado em memoria, garantindo que os testes de integracao nao dependam de rede externa durante a execucao no pipeline CI.
* A compilacao foi validada em modo `Release` (`dotnet build --configuration Release`), assegurando `0 Error(s)`.

#### 3. Por que foi feito
* Em uma arquitetura moderna de Integracao Continua (CI), nenhum codigo deve avancar para o estagio de Deploy (CD) sem antes passar por uma bateria automatizada de testes que comprove a integridade das regras de negocio e dos contratos HTTP da API.
* O isolamento dos testes via `WebApplicationFactory` garante execucao deterministica, rapida (~5 segundos para 140 testes) e imune a instabilidades de rede durante o build.

#### 4. Como isso impacta o projeto
* **Quality Gate Automatizado**: Caso qualquer desenvolvedor introduza uma regressao em uma entidade, servico ou endpoint REST, a task `DotNetCoreCLI@2 (test)` falha no estagio `BuildTestes` e bloqueia imediatamente o deploy no Azure Web App, protegendo o ambiente de producao.
* **Confianca em Refatoracoes**: A cobertura de 140 testes permitiu migrar e higienizar toda a base de codigo com garantia matematica de que nenhuma funcionalidade de negocio foi quebrada.

---

### Etapa 3 — Modelagem Relacional, Script SQL (`script_bd.sql`) e Execucao no Banco PaaS

#### 1. O que foi feito
* Elaboracao do script SQL completo em `script_bd.sql` (na raiz do repositorio) e `sql/script_bd.sql`.
* O script contempla:
  * Limpeza idempotente de objetos pre-existentes (`DROP TABLE IF EXISTS ... CASCADE`);
  * Criacao DDL de todas as tabelas relacionais da solucao: `"TB_DONO"`, `"TB_ANIMAL"`, `"TB_CONSULTA"`, `"TB_CLINICA"`, `"TB_VETERINARIO"`, `"TB_PROCEDIMENTO"`, `"TB_EVENTO_CLINICO"`, `"TB_LEMBRETE"`, `"TB_EXAME_ANEXO"`, `"TB_MODELO_DOCUMENTO"` e `"TB_AUDIT_LOG"`;
  * Definicao de chaves primarias (`PRIMARY KEY`), chaves estrangeiras (`FOREIGN KEY`) com integridade referencial (`ON DELETE RESTRICT` / `ON DELETE CASCADE`), restricoes de unicidade (`UNIQUE`) para CPF, E-mail, CNPJ e CRMV, e indices de performance;
  * Metadados de dicionario de dados (`COMMENT ON TABLE` e `COMMENT ON COLUMN`) documentando o proposito de cada tabela e coluna no catalogo do PostgreSQL;
  * Carga inicial (`INSERT INTO`) com **2 registros reais e consistentes** em cada tabela principal (`TB_DONO`, `TB_ANIMAL`, `TB_CONSULTA`, `TB_CLINICA`, `TB_VETERINARIO`);
  * Criacao de Stored Procedures (`sp_registrar_dono`, `sp_agendar_consulta`, `sp_atualizar_status_consulta`);
  * Consultas `SELECT` de verificacao e auditoria cruzando tutores, pets e consultas agendadas via `INNER JOIN`.
* Execucao direta do `script_bd.sql` no banco de dados em nuvem **Azure Database for PostgreSQL Flexible Server** (`pg-clyvo-sprint4.postgres.database.azure.com`, database `db_clyvovet`).

#### 2. Como foi feito
* Os identificadores de tabelas e colunas foram delimitados com aspas duplas (ex.: `"TB_DONO"`, `"Id"`, `"DonoId"`) para preservar exatamente o case-sensitivity mapeado pelo Entity Framework Core (`ClyvoVetDbContext`).
* O script foi executado remotamente contra o servidor PaaS no Azure utilizando conexao criptografada (`SslMode=Require`) na porta `5432`, validando os 4 conjuntos de resultados (`Result Sets`) retornados pelas queries `SELECT` finais.

#### 3. Por que foi feito
* O banco de dados da aplicacao nao pode residir localmente na maquina do desenvolvedor nem em containers efemeros; ele precisa estar provisionado como servico gerenciado em nuvem (PaaS), estruturado com o esquema oficial da aplicacao e pre-populado para permitir testes imediatos de leitura e relacionamento.
* A padronizacao entre o `script_bd.sql` e o mapeamento do Entity Framework Core evita erros de runtime como `42P01: relation does not exist` ao realizar operacoes CRUD pela API.

#### 4. Como isso impacta o projeto
* **Persistencia Real em Nuvem**: Todos os dados manipulados pelo Azure Web App sao armazenados de forma duravel, transacional e relacional no Azure Database for PostgreSQL.
* **Reprodutibilidade de Esquema**: Qualquer novo ambiente de homologacao ou producao pode ter seu banco de dados integralmente reconstruido e populado em segundos executando um unico arquivo (`script_bd.sql`).

---

### Etapa 4 — Provisionamento de Infraestrutura em Nuvem no Microsoft Azure (IaC)

#### 1. O que foi feito
* Criacao do script de Infraestrutura como Codigo (IaC) em `infra/criar-infra.ps1` utilizando Azure CLI.
* Provisionamento efetivo de toda a infraestrutura na assinatura estudiantil FIAP (`2026-2TDSPJ-JOAO-H-BATISTA-LEAL-RM564361` — ID `d90cf087-7b89-4b9a-a7a8-73a45f2fa6dc`) na regiao `canadacentral`:
  * **Resource Group**: `rg-clyvo-sprint4`
  * **App Service Plan**: `plan-clyvo-sprint4` (SKU `F1` Free Tier)
  * **Azure Web App**: `clyvo-sprint4-rm564361` (`https://clyvo-sprint4-rm564361.azurewebsites.net`, Runtime `.NET 9`, Estado: `Running`)
  * **Servidor de Banco de Dados PaaS**: `pg-clyvo-sprint4` (`pg-clyvo-sprint4.postgres.database.azure.com` — Azure Database for PostgreSQL Flexible Server, Tier `Burstable Standard_B1ms`, PostgreSQL 16, Storage 32 GB)
  * **Banco de Dados Relacional**: `db_clyvovet`
  * **Regras de Firewall do Banco**: Liberacao de acesso para servicos internos do Azure (`0.0.0.0`) e regra de conectividade externa (`AllowAllAzureAndClient` `0.0.0.0` a `255.255.255.255`) para permitir auditoria e testes.

#### 2. Como foi feito
* Foi registrado o Resource Provider `Microsoft.DBforPostgreSQL` na assinatura Azure (`az provider register --namespace Microsoft.DBforPostgreSQL`) ate atingir o estado `Registered`.
* Em seguida, os recursos foram criados via Azure CLI (`az group create`, `az appservice plan create`, `az webapp create`, `az postgres flexible-server create`, `az postgres flexible-server db create` e `az postgres flexible-server firewall-rule create`), e todos os comandos utilizados foram consolidados de forma parametrizada no script `infra/criar-infra.ps1`.

#### 3. Por que foi feito
* A adocao de **Infraestrutura como Codigo (IaC)** elimina a criacao manual ("ClickOps") sujeita a erros humanos no Portal do Azure, documentando exatamente a topologia de nuvem da aplicacao.
* A escolha da regiao `canadacentral` atendeu as politicas de cota da assinatura Azure for Students, garantindo provisionamento estavel tanto para o App Service quanto para o PostgreSQL Flexible Server.

#### 4. Como isso impacta o projeto
* **Disponibilidade Publica (HTTPS)**: A API passou a contar com um endpoint publico seguro com certificado TLS gerenciado pela Microsoft (`https://clyvo-sprint4-rm564361.azurewebsites.net`).
* **Governanca e Controle de Custos**: Todos os recursos estao agrupados sob um unico Resource Group (`rg-clyvo-sprint4`), facilitando o monitoramento de custos, auditoria de permissoes (RBAC) e gerenciamento do ciclo de vida do ambiente.

---

### Etapa 5 — Construcao do Pipeline Multi-Stage (`azure-pipelines.yml`)

#### 1. O que foi feito
* Criacao do arquivo `azure-pipelines.yml` na raiz do repositorio estruturado em **2 Stages independentes e sequenciais**:
  * **Stage 1 — `BuildTestes` (`CI - Build e Testes`)**:
    1. `checkout: self`
    2. `UseDotNet@2`: Instala e seleciona o SDK do `.NET 9.x`
    3. `DotNetCoreCLI@2 (restore)`: Restaura os pacotes NuGet de toda a solucao (`**/*.sln`)
    4. `DotNetCoreCLI@2 (build)`: Compila o projeto da API em modo `Release`
    5. `DotNetCoreCLI@2 (test)`: Executa os 140 testes automatizados (`**/*Tests*.csproj`) e publica os resultados de teste na aba **Tests** do Azure DevOps
    6. `DotNetCoreCLI@2 (publish)`: Gera os binarios otimizados de producao
    7. `ArchiveFiles@2`: Compacta os binarios no pacote `$(Build.ArtifactStagingDirectory)/app.zip`
    8. `PublishPipelineArtifact@1`: Publica o artefato `app` no Azure DevOps
  * **Stage 2 — `Deploy` (`CD - Deploy no Azure App Service`)**:
    1. Depende de `BuildTestes` (`dependsOn: BuildTestes`) e so executa se o estagio anterior tiver sucesso (`condition: succeeded()`)
    2. `DownloadPipelineArtifact@2`: Baixa o artefato `app` gerado na fase de CI
    3. `AzureAppServiceSettings@1`: Injeta de forma segura as Application Settings (`ASPNETCORE_ENVIRONMENT`, `ConnectionStrings__OracleConnection`, `ORACLE_CONNECTION_STRING`, `Jwt__Key` e `JWT_SECRET`) no Azure Web App usando a Service Connection `azure-clyvo-sprint4`
    4. `AzureWebApp@1`: Realiza o deploy automatizado do pacote `app.zip` via `zipDeploy` no Web App `$(NOME_WEBAPP)`.

#### 2. Como foi feito
* O arquivo YAML foi configurado com gatilho automatico (`trigger`) na branch `master` e filtro de exclusao (`paths.exclude`) para arquivos puramente documentais (`README.md`, `PROGRESS.md`, `ENTREGA_PROJETO.md`, `docs/*`), evitando builds desnecessarios quando apenas documentacao e alterada.
* A injecao de configuracoes via `AzureAppServiceSettings@1` foi mapeada para consumir as variaveis secretas configuradas no cofre da pipeline do Azure DevOps (`$(OracleConnection)` e `$(JWT_SECRET)`).

#### 3. Por que foi feito
* Separar **CI (Build/Test)** e **CD (Deploy)** em estagios distintos com artefato imutavel (`app.zip`) garante o principio de *Build Once, Deploy Anywhere*: o exato binario que foi validado pelos testes automatizados e o que segue para producao, sem recompilacao.
* A injecao automatizada de `appSettings` via pipeline elimina a necessidade de configurar variaveis manualmente no Portal do Azure.

#### 4. Como isso impacta o projeto
* **Automacao Zero-Touch**: Qualquer alteracao de codigo enviada para a branch `master` percorre todo o ciclo de compilacao, validacao por 140 testes, empacotamento, configuracao de segredos e publicacao em nuvem sem nenhuma intervencao humana.
* **Rastreabilidade de Qualidade**: Cada execucao gera relatorios detalhados de testes (aba *Tests*) e artefatos versionados no Azure DevOps.

---

### Etapa 6 — Diagrama de Arquitetura Numerado e Documentacao Executiva

#### 1. O que foi feito
* Criacao do diagrama visual de arquitetura de ponta a ponta em `docs/arquitetura.png` (e copia em `docs/architecture/azure_architecture.png`), contendo o fluxo completo numerado de **1 a 12** (Developer -> Git Push -> GitHub & Azure Repos -> Trigger CI -> Restore/Build/Test/Publish/Artifact -> Trigger CD -> Service Connection & Secret Variables -> Deploy no Azure Web App -> Persistencia no Azure Database for PostgreSQL -> Resposta HTTPS e Validacao Swagger/CRUD).
* Elaboracao do `README.md` completo na raiz do repositorio (sem emojis, com sumario navegavel, tabela de tecnologias, arquitetura em camadas, explicacao dos passos `1` a `12` do diagrama, guia de execucao local, documentacao da infraestrutura Azure, detalhes da pipeline CI/CD e catálogo de endpoints).
* Elaboracao do documento formal de entrega `ENTREGA_PROJETO.md` e geracao do arquivo PDF `docs/Entrega_DevOps_Sprint4_ClyvoVet.pdf` com todos os links oficiais, identificadores de recursos e checklist de evidencias.

#### 2. Como foi feito
* O diagrama de arquitetura foi gerado programaticamente em alta resolucao (2200x1320 px) com paleta visual corporativa Azure DevOps / Microsoft Azure, conectores direcionais e badges numerados de `1` a `12`.
* O PDF de entrega foi compilado a partir de um template HTML/CSS estruturado utilizando renderizacao headless do Microsoft Edge (`--headless --print-to-pdf`), garantindo formatacao limpa, tabelas alinhadas e diagrama incorporado.

#### 3. Por que foi feito
* Documentacao arquitetural precisa e um pilar essencial de DevOps: permite que novos engenheiros, auditores e avaliadores compreendam instantaneamente como o codigo sai da maquina do desenvolvedor, atravessa as esteiras de qualidade e atinge o banco de dados em nuvem.

#### 4. Como isso impacta o projeto
* **Clareza Arquitetural**: O fluxo numerado de 1 a 12 elimina ambiguidades sobre o papel de cada componente (Git, Azure Repos, Pipeline CI, Pipeline CD, Service Connection, App Service e PostgreSQL PaaS).
* **Prontidao para Avaliacao**: Todos os documentos exigidos pela banca avaliadora estao centralizados e formatados no repositorio e em PDF.

---

### Etapa 7 — Governanca Git (`master`), Azure DevOps, Dual-Push e Permissoes do Avaliador

#### 1. O que foi feito
* Padronizacao da branch principal para **`master`** localmente, no **GitHub** (`https://github.com/JoaoHBatistaLeal/clyvo-sprint-4-devops.git`) e no **Azure Repos** (`https://dev.azure.com/OrgJJEGG/Sprint%204%20-%20Azure%20DevOps/_git/Sprint%204%20-%20Azure%20DevOps`).
* Configuracao de **Dual-Push** no remote `origin` do Git local, permitindo que um unico comando `git push origin master` publique simultaneamente os commits no GitHub e no Azure Repos.
* Configuracao da organizacao `OrgJJEGG` e do projeto **`Sprint 4 - Azure DevOps`** (Visibilidade: `Private`, Controle de Versao: `Git`, Processo: `Agile`).
* Inclusao e configuracao de permissoes do professor avaliador **<NOME_DO_PROFESSOR>** (`<EMAIL_DO_PROFESSOR>`):
  * Nivel de Acesso (Access Level) na Organizacao `OrgJJEGG`: **Basic (`express`)**;
  * Grupo de Seguranca no Projeto `Sprint 4 - Azure DevOps`: **Project Administrators** e **Contributors**;
  * Inclusao dos 5 alunos integrantes do grupo no grupo **Project Administrators**.

#### 2. Como foi feito
* A branch default do GitHub foi alterada para `master` via API antes da remocao de qualquer branch secundaria (`main`), garantindo que apenas `refs/heads/master` exista nos dois servidores remotos.
* No Azure DevOps, como a conta institucional do professor no Entra ID da FIAP possuia UPN distinto do alias de e-mail (`<EMAIL_DO_PROFESSOR>`), foi realizada a resolucao do `originId` (`2c6661b3-2e04-4eee-b4cd-8b997426c8bb`) via API IdentityPicker do Azure DevOps e o provisionamento direto do User Entitlement com licenca `express` (Basic) e alocacao no grupo `Project Administrators` via API Graph.

#### 3. Por que foi feito
* A sincronizacao automatica entre GitHub e Azure Repos (Dual-Push) evita divergencia de codigo entre os dois repositorios avaliados na entrega.
* A atribuicao de licenca **Basic** e papel de **Project Administrator** ao professor avaliador e obrigatoria para que ele possa visualizar o codigo no Azure Repos, inspecionar as variaveis secretas, auditar a Service Connection e consultar os logs das runs da pipeline.

#### 4. Como isso impacta o projeto
* **Consistencia de Versionamento**: GitHub e Azure Repos permanecem 100% identicos no mesmo hash de commit na branch `master`.
* **Auditabilidade Total**: O professor avaliador possui acesso administrativo irrestrito a todos os recursos do projeto no Azure DevOps.

---

### Etapa 8 — Service Connection, Variaveis Secretas, Self-Hosted Agent e Execucao da Pipeline

#### 1. O que foi feito
* Criacao e autorizacao da **Service Connection** `azure-clyvo-sprint4` (Azure Resource Manager com Workload Identity Federation automática) vinculada a assinatura `2026-2TDSPJ-JOAO-H-BATISTA-LEAL-RM564361` e ao Resource Group `rg-clyvo-sprint4`.
* Criacao da pipeline oficial **`ClyvoVet-CI-CD`** (Definition ID `1`) apontando para `azure-pipelines.yml` na branch `master`.
* Configuracao das 4 variaveis de ambiente na pipeline `ClyvoVet-CI-CD`:
  * `NOME_WEBAPP` = `clyvo-sprint4-rm564361` (Texto aberto)
  * `ASPNETCORE_ENVIRONMENT` = `Production` (Texto aberto)
  * `OracleConnection` = String de conexao completa do PostgreSQL PaaS (**Secret / Cadeado fechado**: `isSecret: true`)
  * `JWT_SECRET` = Chave criptografica de assinatura JWT (**Secret / Cadeado fechado**: `isSecret: true`)
* Provisionamento e ativacao do **Self-Hosted Agent** (`agent-clyvo-sprint4`) no Agent Pool `Default` para execucao imediata dos jobs de CI e CD.
* Execucao completa da **Build #1 (`20261031.1`)**, obtendo status **`succeeded` (100% verde)** nos estagios `CI - Build e Testes` e `CD - Deploy no Azure App Service`.

#### 2. Como foi feito
* Como organizacoes recem-criadas no Azure DevOps possuem paralelismo gratuito `0` em agentes Microsoft-hosted ate aprovacao manual de formulario pela Microsoft, foi instalado e registrado o agente oficial do Azure Pipelines (`vsts-agent-win-x64-4.269.0`) em `C:\azagent` conectado ao pool `Default` da organizacao `OrgJJEGG`.
* As variaveis secretas foram registradas na definicao da pipeline com a propriedade `isSecret: true`, fazendo com que o Azure DevOps mascare qualquer ocorrencia de seus valores nos logs de console como `***`.

#### 3. Por que foi feito
* A utilizacao de Workload Identity Federation na Service Connection `azure-clyvo-sprint4` elimina a necessidade de gerenciar senhas de Service Principal com data de expiracao.
* A configuracao do Self-Hosted Agent desbloqueou a capacidade de execucao imediata da pipeline sem depender do prazo de liberacao de paralelismo hospedado da Microsoft.

#### 4. Como isso impacta o projeto
* **Execucao Continua Garantida**: A esteira CI/CD executa os estagios de Build, Testes (140 testes) e Deploy em menos de 2 minutos com disponibilidade imediata.
* **Protecao de Credenciais nos Logs**: Mesmo que um usuario inspecione os logs detalhados da task `AzureAppServiceSettings@1`, os valores de `OracleConnection` e `JWT_SECRET` permanecem criptografados e ocultos (`***`).

---

### Etapa 9 — Testes Fim a Fim na Nuvem (Smoke Test, Gatilho CI/CD e CRUD Real no Banco PaaS)

#### 1. O que foi feito
Execucao e comprovacao da bateria de **3 Testes Fim a Fim (End-to-End)** diretamente no ambiente de producao no Azure:
1. **Teste 1 — Smoke Test de Disponibilidade e Saude da API na Nuvem**:
   * `GET https://clyvo-sprint4-rm564361.azurewebsites.net/wellcome` -> HTTP `200 OK`
   * `GET https://clyvo-sprint4-rm564361.azurewebsites.net/` -> HTTP `200 OK`
   * `GET https://clyvo-sprint4-rm564361.azurewebsites.net/swagger/index.html` -> HTTP `200 OK`
   * `GET https://clyvo-sprint4-rm564361.azurewebsites.net/health` -> HTTP `200 OK` (`{"status":"Healthy"}`, comprovando conexao viva entre o Azure Web App e o Azure Database for PostgreSQL).
2. **Teste 2 — Comprovacao de Gatilho Automatico de CI/CD (`individualCI`)**:
   * Alteracao da mensagem de retorno do endpoint `/wellcome` em `ClyvoVetChallenge.Api/Program.cs` para `"ClyvoVet Sprint 4 - Deploy Automatico Verificado v2"`, seguida de `git commit` e `git push origin master`.
   * Disparo automatico da **Build #2 (`20261031.2`, `reason: individualCI`)** no Azure Pipelines sem intervencao manual.
   * Conclusao da Build #2 com `status: completed` e `result: succeeded` nos estagios CI e CD, e confirmacao imediata do novo texto na URL publica `https://clyvo-sprint4-rm564361.azurewebsites.net/wellcome`.
3. **Teste 3 — Persistencia Real (Ciclo CRUD Completo na API em Nuvem + `SELECT` Direto no Banco PaaS)**:
   * **Create (`POST /api/Dono` e `POST /api/Animal`)**: Criacao de tutor (`Id: ce288140-a2ed-4fad-9187-f332d0ff7355`) e pet (`Id: 7486d0a2-7dfb-4fe3-a985-ad09ba1204f6`) via chamadas HTTP `POST` na URL publica do Azure Web App (retornando HTTP `201 Created`), seguida de consulta `SELECT ... INNER JOIN` diretamente no servidor PostgreSQL PaaS confirmando a gravacao fisica dos registros nas tabelas `"TB_DONO"` e `"TB_ANIMAL"`.
   * **Read (`GET /api/Dono/{id}` e `GET /api/Animal/{id}`)**: Consulta dos registros recem-criados pela API em nuvem (HTTP `200 OK`) com retorno de links HATEOAS.
   * **Update (`PUT /api/Dono/{id}` e `PUT /api/Animal/{id}`)**: Atualizacao de nome, e-mail, endereco e peso via chamadas HTTP `PUT` (HTTP `200 OK`), seguida de `SELECT` direto no PostgreSQL PaaS confirmando a alteracao persistida no disco do banco em nuvem (`Peso: 30.20`, `Nome: Thor Cloud Atualizado`).
   * **Delete (`DELETE /api/Animal/{id}` e `DELETE /api/Dono/{id}`)**: Exclusao dos registros de teste via HTTP `DELETE` (HTTP `204 No Content`), seguida de `SELECT COUNT(*)` no banco PaaS confirmando a remocao (`0` registros de teste restantes) e a preservacao intacta da carga inicial (`Carlos Eduardo Silva`, `Mariana Ferreira Costa`, `Mia`, `Rex`).

#### 2. Como foi feito
* Os testes foram executados combinando requisicoes HTTP reais contra `https://clyvo-sprint4-rm564361.azurewebsites.net` e consultas SQL diretas via driver `Npgsql` conectado ao host `pg-clyvo-sprint4.postgres.database.azure.com` (`Database=db_clyvovet`), cruzando o estado retornado pela camada HTTP da API com o estado fisico armazenado nas tabelas do banco em nuvem.

#### 3. Por que foi feito
* Validar apenas que o build compilou nao garante que a aplicacao esteja funcional em producao. A bateria de testes Fim a Fim comprova empiricamente que a rede, o firewall do Azure, a injecao de connection string secreta, o mapeamento ORM do Entity Framework Core e o gatilho de automacao CI/CD funcionam de forma integrada no mundo real.

#### 4. Como isso impacta o projeto
* **Garantia de Funcionamento Fim a Fim**: Elimina qualquer risco de falha silenciosa em producao (como erros de autenticacao no banco, falha de SSL/TLS, tabela inexistente ou variaveis de ambiente ausentes).
* **Entrega Pronta para Producao**: O ecossistema ClyvoVet encontra-se 100% operacional, documentado, testado e automatizado na nuvem Microsoft Azure.

---

### Matriz Resumo de Impacto e Entregaveis

| Componente / Etapa | Artefato / Recurso Oficial | Status Final | Impacto Principal no Projeto |
| :--- | :--- | :--- | :--- |
| **Codigo & Arquitetura** | `ClyvoVetChallenge.sln` (`.NET 9`) | Concluido | Arquitetura limpa em 4 camadas, sem Docker, sem segredos hardcoded e com Swagger em producao |
| **Testes Automatizados** | `Tests.Unit` (104) + `Tests.Integration` (36) | 140 Passed (`0 Failed`) | Bloqueio automatico de regressoes na esteira de Integracao Continua (CI) |
| **Banco de Dados SQL** | `script_bd.sql` / `sql/script_bd.sql` | Executado no PaaS | Esquema relacional completo (`TB_DONO`, `TB_ANIMAL`, `TB_CONSULTA`, etc.) com PKs, FKs, procedures e carga inicial |
| **Infraestrutura Azure (IaC)** | `infra/criar-infra.ps1` (`rg-clyvo-sprint4`) | Online (`Running`) | Ambiente PaaS reprodutivel no Azure (`clyvo-sprint4-rm564361` + `pg-clyvo-sprint4`) |
| **Pipeline CI/CD** | `azure-pipelines.yml` (`ClyvoVet-CI-CD`) | Build #1 e #2 `Succeeded` | Build, testes xUnit, publicacao de artefato `.zip`, injecao de segredos e deploy automatico |
| **Documentacao e Diagrama** | `README.md`, `PROGRESS.md`, `docs/arquitetura.png`, PDF | Concluido | Rastreabilidade completa do fluxo DevOps (passos 1 a 12) e guia tecnico detalhado |
| **Governanca & Acessos** | Branch `master` (Dual-Push) + `<EMAIL_DO_PROFESSOR>` | Sincronizado e Ativo | Paridade total GitHub/Azure Repos e acesso Basic + Project Administrator para o avaliador |
| **Validacao End-to-End** | Smoke Test + Trigger CI/CD + CRUD PaaS | 100% Verificado | Comprovacao real de persistencia e deploy continuo na URL publica do Azure |
