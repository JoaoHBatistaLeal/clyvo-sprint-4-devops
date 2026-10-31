CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_CLINICA" (
        "Id" uuid NOT NULL,
        "Cnpj" character varying(18) NOT NULL,
        "Email" character varying(150) NOT NULL,
        "Telefone" character varying(20) NOT NULL,
        "Endereco" character varying(255) NOT NULL,
        "HorarioFuncionamento" character varying(100) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_CLINICA" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_DONO" (
        "Id" uuid NOT NULL,
        "Nome" character varying(150) NOT NULL,
        "Cpf" character varying(14) NOT NULL,
        "Email" character varying(150) NOT NULL,
        "Telefone" character varying(20) NOT NULL,
        "DataNascimento" date NOT NULL,
        "Endereco" character varying(255) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_DONO" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_SINTOMA_CATALOGO" (
        "Id" uuid NOT NULL,
        "Nome" character varying(100) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_SINTOMA_CATALOGO" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_VETERINARIO" (
        "Id" uuid NOT NULL,
        "Nome" character varying(150) NOT NULL,
        "Crmv" character varying(20) NOT NULL,
        "Especialidade" character varying(100) NOT NULL,
        "Telefone" character varying(20) NOT NULL,
        "Email" character varying(150) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_VETERINARIO" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_ANIMAL" (
        "Id" uuid NOT NULL,
        "DonoId" uuid NOT NULL,
        "Nome" character varying(100) NOT NULL,
        "Especie" character varying(50) NOT NULL,
        "Raca" character varying(50) NOT NULL,
        "Sexo" character varying(20) NOT NULL,
        "DataNascimento" date NOT NULL,
        "Peso" numeric(5,2) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_ANIMAL" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_ANIMAL_TB_DONO_DonoId" FOREIGN KEY ("DonoId") REFERENCES "TB_DONO" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_CONSULTA" (
        "Id" uuid NOT NULL,
        "AnimalId" uuid NOT NULL,
        "VeterinarioId" uuid NOT NULL,
        "ClinicaId" uuid NOT NULL,
        "DataConsulta" date NOT NULL,
        "HoraConsulta" time without time zone NOT NULL,
        "Motivo" character varying(500) NOT NULL,
        "Diagnostico" character varying(1000),
        "Observacoes" character varying(1000),
        "Status" character varying(20) NOT NULL,
        "Tipo" character varying(50) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_CONSULTA" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_CONSULTA_TB_ANIMAL_AnimalId" FOREIGN KEY ("AnimalId") REFERENCES "TB_ANIMAL" ("Id") ON DELETE RESTRICT,
        CONSTRAINT "FK_TB_CONSULTA_TB_CLINICA_ClinicaId" FOREIGN KEY ("ClinicaId") REFERENCES "TB_CLINICA" ("Id") ON DELETE RESTRICT,
        CONSTRAINT "FK_TB_CONSULTA_TB_VETERINARIO_VeterinarioId" FOREIGN KEY ("VeterinarioId") REFERENCES "TB_VETERINARIO" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_DIARIO" (
        "Id" uuid NOT NULL,
        "AnimalId" uuid NOT NULL,
        "DataRegistro" date NOT NULL,
        "HoraRegistro" time without time zone NOT NULL,
        "ObservacaoLivre" character varying(1000) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_DIARIO" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_DIARIO_TB_ANIMAL_AnimalId" FOREIGN KEY ("AnimalId") REFERENCES "TB_ANIMAL" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_HISTORICO" (
        "Id" uuid NOT NULL,
        "AnimalId" uuid NOT NULL,
        "ConsultaId" uuid NOT NULL,
        "DataRegistro" timestamp with time zone NOT NULL,
        "Descricao" character varying(500) NOT NULL,
        "TipoEvento" character varying(50) NOT NULL,
        "Resultado" character varying(500) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_HISTORICO" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_HISTORICO_TB_ANIMAL_AnimalId" FOREIGN KEY ("AnimalId") REFERENCES "TB_ANIMAL" ("Id") ON DELETE RESTRICT,
        CONSTRAINT "FK_TB_HISTORICO_TB_CONSULTA_ConsultaId" FOREIGN KEY ("ConsultaId") REFERENCES "TB_CONSULTA" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_PRESCRICAO" (
        "Id" uuid NOT NULL,
        "ConsultaId" uuid NOT NULL,
        "Medicamento" character varying(150) NOT NULL,
        "Dosagem" character varying(50) NOT NULL,
        "Frequencia" character varying(50) NOT NULL,
        "DuracaoDias" integer NOT NULL,
        "Observacao" character varying(500) NOT NULL,
        "DataPrescricao" timestamp with time zone NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_PRESCRICAO" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_PRESCRICAO_TB_CONSULTA_ConsultaId" FOREIGN KEY ("ConsultaId") REFERENCES "TB_CONSULTA" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE TABLE "TB_DIARIO_SINTOMA" (
        "Id" uuid NOT NULL,
        "DiarioId" uuid NOT NULL,
        "SintomaId" uuid NOT NULL,
        "Intensidade" character varying(50) NOT NULL,
        "CreatedAt" timestamp with time zone NOT NULL,
        "Active" boolean NOT NULL,
        CONSTRAINT "PK_TB_DIARIO_SINTOMA" PRIMARY KEY ("Id"),
        CONSTRAINT "FK_TB_DIARIO_SINTOMA_TB_DIARIO_DiarioId" FOREIGN KEY ("DiarioId") REFERENCES "TB_DIARIO" ("Id") ON DELETE CASCADE,
        CONSTRAINT "FK_TB_DIARIO_SINTOMA_TB_SINTOMA_CATALOGO_SintomaId" FOREIGN KEY ("SintomaId") REFERENCES "TB_SINTOMA_CATALOGO" ("Id") ON DELETE RESTRICT
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260910182414_InitialPostgreMigration') THEN
    CREATE INDEX "IX_TB_ANIMAL_DonoId" ON "TB_ANIMAL" ("DonoId");
    CREATE UNIQUE INDEX "IX_TB_CLINICA_Cnpj" ON "TB_CLINICA" ("Cnpj");
    CREATE INDEX "IX_TB_CONSULTA_AnimalId" ON "TB_CONSULTA" ("AnimalId");
    CREATE INDEX "IX_TB_CONSULTA_ClinicaId" ON "TB_CONSULTA" ("ClinicaId");
    CREATE INDEX "IX_TB_CONSULTA_VeterinarioId" ON "TB_CONSULTA" ("VeterinarioId");
    CREATE INDEX "IX_TB_DIARIO_AnimalId" ON "TB_DIARIO" ("AnimalId");
    CREATE INDEX "IX_TB_DIARIO_SINTOMA_DiarioId" ON "TB_DIARIO_SINTOMA" ("DiarioId");
    CREATE INDEX "IX_TB_DIARIO_SINTOMA_SintomaId" ON "TB_DIARIO_SINTOMA" ("SintomaId");
    CREATE UNIQUE INDEX "IX_TB_DONO_Cpf" ON "TB_DONO" ("Cpf");
    CREATE UNIQUE INDEX "IX_TB_DONO_Email" ON "TB_DONO" ("Email");
    CREATE INDEX "IX_TB_HISTORICO_AnimalId" ON "TB_HISTORICO" ("AnimalId");
    CREATE INDEX "IX_TB_HISTORICO_ConsultaId" ON "TB_HISTORICO" ("ConsultaId");
    CREATE INDEX "IX_TB_PRESCRICAO_ConsultaId" ON "TB_PRESCRICAO" ("ConsultaId");
    CREATE UNIQUE INDEX "IX_TB_SINTOMA_CATALOGO_Nome" ON "TB_SINTOMA_CATALOGO" ("Nome");
    CREATE UNIQUE INDEX "IX_TB_VETERINARIO_Crmv" ON "TB_VETERINARIO" ("Crmv");
    CREATE UNIQUE INDEX "IX_TB_VETERINARIO_Email" ON "TB_VETERINARIO" ("Email");
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260910182414_InitialPostgreMigration', '9.0.0');
    END IF;
END $EF$;
COMMIT;

COMMENT ON TABLE "TB_DONO" IS 'Tabela responsavel pelo armazenamento dos dados cadastrais dos tutores (donos) dos animais.';
COMMENT ON COLUMN "TB_DONO"."Id" IS 'Identificador unico do tutor (UUID gerado automaticamente).';
COMMENT ON COLUMN "TB_DONO"."Nome" IS 'Nome completo do tutor.';
COMMENT ON COLUMN "TB_DONO"."Cpf" IS 'Numero de CPF do tutor (unico, max 14 caracteres).';
COMMENT ON COLUMN "TB_DONO"."Email" IS 'Endereco de e-mail do tutor (unico, max 150 caracteres).';
COMMENT ON COLUMN "TB_DONO"."Telefone" IS 'Numero de telefone/contato do tutor.';
COMMENT ON COLUMN "TB_DONO"."DataNascimento" IS 'Data de nascimento do tutor (DateOnly / date).';
COMMENT ON COLUMN "TB_DONO"."Endereco" IS 'Endereco residencial completo do tutor.';
COMMENT ON COLUMN "TB_DONO"."CreatedAt" IS 'Data e hora da criacao do registro (timestamp with time zone).';
COMMENT ON COLUMN "TB_DONO"."Active" IS 'Indicador booleano de registro ativo no sistema.';

COMMENT ON TABLE "TB_ANIMAL" IS 'Tabela responsavel pelo cadastro dos pacientes/animais vinculados a um tutor.';
COMMENT ON COLUMN "TB_ANIMAL"."Id" IS 'Identificador unico do animal (UUID gerado automaticamente).';
COMMENT ON COLUMN "TB_ANIMAL"."DonoId" IS 'Chave estrangeira vinculando o animal ao tutor correspondente em TB_DONO.';
COMMENT ON COLUMN "TB_ANIMAL"."Nome" IS 'Nome do animal (max 100 caracteres).';
COMMENT ON COLUMN "TB_ANIMAL"."Especie" IS 'Especie do animal (ex: Canina, Felina, Ave).';
COMMENT ON COLUMN "TB_ANIMAL"."Raca" IS 'Raca do animal (max 50 caracteres).';
COMMENT ON COLUMN "TB_ANIMAL"."Sexo" IS 'Sexo biologico do animal (ex: Macho, Femea).';
COMMENT ON COLUMN "TB_ANIMAL"."DataNascimento" IS 'Data de nascimento do animal (DateOnly / date).';
COMMENT ON COLUMN "TB_ANIMAL"."Peso" IS 'Peso do animal em quilogramas (numeric(5,2)).';
COMMENT ON COLUMN "TB_ANIMAL"."CreatedAt" IS 'Data e hora da criacao do registro (timestamp with time zone).';
COMMENT ON COLUMN "TB_ANIMAL"."Active" IS 'Indicador booleano de registro ativo no sistema.';

COMMENT ON TABLE "TB_CLINICA" IS 'Tabela responsavel pelo cadastro das clinicas e unidades veterinarias.';
COMMENT ON COLUMN "TB_CLINICA"."Id" IS 'Identificador unico da clinica.';
COMMENT ON COLUMN "TB_CLINICA"."Cnpj" IS 'CNPJ unico da unidade clinica.';
COMMENT ON TABLE "TB_VETERINARIO" IS 'Tabela de medicos veterinarios com CRMV e especialidade.';
COMMENT ON COLUMN "TB_VETERINARIO"."Id" IS 'Identificador unico do medico veterinario.';
COMMENT ON COLUMN "TB_VETERINARIO"."Crmv" IS 'Registro profissional CRMV unico do veterinario.';
COMMENT ON TABLE "TB_CONSULTA" IS 'Tabela de consultas e agendamentos veterinarios vinculando animal, veterinario e clinica.';
COMMENT ON COLUMN "TB_CONSULTA"."Id" IS 'Identificador unico da consulta veterinaria.';
COMMENT ON COLUMN "TB_CONSULTA"."AnimalId" IS 'Chave estrangeira para o paciente em TB_ANIMAL.';
COMMENT ON COLUMN "TB_CONSULTA"."VeterinarioId" IS 'Chave estrangeira para o veterinario em TB_VETERINARIO.';
COMMENT ON COLUMN "TB_CONSULTA"."ClinicaId" IS 'Chave estrangeira para a clinica em TB_CLINICA.';
COMMENT ON TABLE "TB_HISTORICO" IS 'Tabela de historico medico e prontuario de evolucao dos pacientes.';
COMMENT ON TABLE "TB_PRESCRICAO" IS 'Tabela de prescricoes medicamentosas vinculadas a consultas.';
COMMENT ON TABLE "TB_DIARIO" IS 'Tabela de registros do diario de saude dos animais.';
COMMENT ON TABLE "TB_DIARIO_SINTOMA" IS 'Tabela associativa entre diarios de saude e catalogo de sintomas observados.';
COMMENT ON TABLE "TB_SINTOMA_CATALOGO" IS 'Catalogo padronizado de sintomas clinicos veterinarios.';

DO $$
DECLARE
    v_dono1_id uuid := gen_random_uuid();
    v_dono2_id uuid := gen_random_uuid();
    v_clinica1_id uuid := gen_random_uuid();
    v_clinica2_id uuid := gen_random_uuid();
    v_vet1_id uuid := gen_random_uuid();
    v_vet2_id uuid := gen_random_uuid();
    v_animal1_id uuid := gen_random_uuid();
    v_animal2_id uuid := gen_random_uuid();
    v_consulta1_id uuid := gen_random_uuid();
    v_consulta2_id uuid := gen_random_uuid();
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "TB_DONO" WHERE "Cpf" = '12345678901') THEN
        INSERT INTO "TB_DONO" ("Id", "Nome", "Cpf", "Email", "Telefone", "DataNascimento", "Endereco", "CreatedAt", "Active")
        VALUES (v_dono1_id, 'Carlos Eduardo Silva', '12345678901', 'carlos.silva@clyvovet.com', '11987654321', '1985-04-12', 'Av. Paulista, 1000 - Bela Vista, Sao Paulo - SP', NOW(), true);
    ELSE
        SELECT "Id" INTO v_dono1_id FROM "TB_DONO" WHERE "Cpf" = '12345678901';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_DONO" WHERE "Cpf" = '98765432100') THEN
        INSERT INTO "TB_DONO" ("Id", "Nome", "Cpf", "Email", "Telefone", "DataNascimento", "Endereco", "CreatedAt", "Active")
        VALUES (v_dono2_id, 'Mariana Ferreira Costa', '98765432100', 'mariana.costa@clyvovet.com', '11912345678', '1990-09-25', 'Rua Augusta, 500 - Consolacao, Sao Paulo - SP', NOW(), true);
    ELSE
        SELECT "Id" INTO v_dono2_id FROM "TB_DONO" WHERE "Cpf" = '98765432100';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_CLINICA" WHERE "Cnpj" = '12345678000190') THEN
        INSERT INTO "TB_CLINICA" ("Id", "Cnpj", "Email", "Telefone", "Endereco", "HorarioFuncionamento", "CreatedAt", "Active")
        VALUES (v_clinica1_id, '12345678000190', 'contato@clyvovet.com', '1133334444', 'Av. Paulista, 1500 - Sao Paulo - SP', '24 Horas', NOW(), true);
    ELSE
        SELECT "Id" INTO v_clinica1_id FROM "TB_CLINICA" WHERE "Cnpj" = '12345678000190';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_CLINICA" WHERE "Cnpj" = '98765432000110') THEN
        INSERT INTO "TB_CLINICA" ("Id", "Cnpj", "Email", "Telefone", "Endereco", "HorarioFuncionamento", "CreatedAt", "Active")
        VALUES (v_clinica2_id, '98765432000110', 'unidade.sul@clyvovet.com', '1155556666', 'Av. Ibirapuera, 2000 - Sao Paulo - SP', '08:00 as 20:00', NOW(), true);
    ELSE
        SELECT "Id" INTO v_clinica2_id FROM "TB_CLINICA" WHERE "Cnpj" = '98765432000110';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_VETERINARIO" WHERE "Crmv" = 'CRMV-SP-10234') THEN
        INSERT INTO "TB_VETERINARIO" ("Id", "Nome", "Crmv", "Especialidade", "Telefone", "Email", "CreatedAt", "Active")
        VALUES (v_vet1_id, 'Dr. Roberto Almeida', 'CRMV-SP-10234', 'Clinica Geral e Cirurgia', '11977778888', 'roberto.almeida@clyvovet.com', NOW(), true);
    ELSE
        SELECT "Id" INTO v_vet1_id FROM "TB_VETERINARIO" WHERE "Crmv" = 'CRMV-SP-10234';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_VETERINARIO" WHERE "Crmv" = 'CRMV-SP-20456') THEN
        INSERT INTO "TB_VETERINARIO" ("Id", "Nome", "Crmv", "Especialidade", "Telefone", "Email", "CreatedAt", "Active")
        VALUES (v_vet2_id, 'Dra. Camila Mendes', 'CRMV-SP-20456', 'Felinos e Dermatologia', '11966665555', 'camila.mendes@clyvovet.com', NOW(), true);
    ELSE
        SELECT "Id" INTO v_vet2_id FROM "TB_VETERINARIO" WHERE "Crmv" = 'CRMV-SP-20456';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_ANIMAL" WHERE "DonoId" = v_dono1_id AND "Nome" = 'Rex') THEN
        INSERT INTO "TB_ANIMAL" ("Id", "DonoId", "Nome", "Especie", "Raca", "Sexo", "DataNascimento", "Peso", "CreatedAt", "Active")
        VALUES (v_animal1_id, v_dono1_id, 'Rex', 'Canina', 'Golden Retriever', 'Macho', '2021-06-15', 32.50, NOW(), true);
    ELSE
        SELECT "Id" INTO v_animal1_id FROM "TB_ANIMAL" WHERE "DonoId" = v_dono1_id AND "Nome" = 'Rex';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_ANIMAL" WHERE "DonoId" = v_dono2_id AND "Nome" = 'Mia') THEN
        INSERT INTO "TB_ANIMAL" ("Id", "DonoId", "Nome", "Especie", "Raca", "Sexo", "DataNascimento", "Peso", "CreatedAt", "Active")
        VALUES (v_animal2_id, v_dono2_id, 'Mia', 'Felina', 'Siames', 'Femea', '2022-03-20', 4.10, NOW(), true);
    ELSE
        SELECT "Id" INTO v_animal2_id FROM "TB_ANIMAL" WHERE "DonoId" = v_dono2_id AND "Nome" = 'Mia';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_CONSULTA" WHERE "AnimalId" = v_animal1_id AND "Motivo" = 'Check-up preventivo anual e vacinacao') THEN
        INSERT INTO "TB_CONSULTA" ("Id", "AnimalId", "VeterinarioId", "ClinicaId", "DataConsulta", "HoraConsulta", "Motivo", "Diagnostico", "Observacoes", "Status", "Tipo", "CreatedAt", "Active")
        VALUES (v_consulta1_id, v_animal1_id, v_vet1_id, v_clinica1_id, '2026-11-10', '10:00:00', 'Check-up preventivo anual e vacinacao', 'Paciente saudavel', 'Retorno em 12 meses', 'Agendada', 'Presencial', NOW(), true);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM "TB_CONSULTA" WHERE "AnimalId" = v_animal2_id AND "Motivo" = 'Avaliacao dermatologica de rotina') THEN
        INSERT INTO "TB_CONSULTA" ("Id", "AnimalId", "VeterinarioId", "ClinicaId", "DataConsulta", "HoraConsulta", "Motivo", "Diagnostico", "Observacoes", "Status", "Tipo", "CreatedAt", "Active")
        VALUES (v_consulta2_id, v_animal2_id, v_vet2_id, v_clinica2_id, '2026-11-12', '14:30:00', 'Avaliacao dermatologica de rotina', 'Pelagem integra', 'Manter escovacao', 'Agendada', 'Presencial', NOW(), true);
    END IF;
END $$;

CREATE OR REPLACE PROCEDURE sp_cancelar_consultas_antigas(p_dias integer)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "TB_CONSULTA"
    SET "Status" = 'Cancelada'
    WHERE "Status" = 'Agendada'
      AND "DataConsulta" < CURRENT_DATE - p_dias;
END;
$$;

CREATE OR REPLACE FUNCTION sp_obter_resumo_consultas_animal(p_animal_id uuid)
RETURNS TABLE (
    "TotalConsultas" bigint,
    "UltimaConsulta" date,
    "StatusUltimaConsulta" varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::bigint AS "TotalConsultas",
        MAX(c."DataConsulta") AS "UltimaConsulta",
        COALESCE((SELECT c2."Status"::varchar FROM "TB_CONSULTA" c2 WHERE c2."AnimalId" = p_animal_id ORDER BY c2."DataConsulta" DESC, c2."HoraConsulta" DESC LIMIT 1), 'Nenhuma')::varchar AS "StatusUltimaConsulta"
    FROM "TB_CONSULTA" c
    WHERE c."AnimalId" = p_animal_id;
END;
$$ LANGUAGE plpgsql;

SELECT "Id", "Nome", "Cpf", "Email", "Telefone", "DataNascimento", "Endereco", "CreatedAt", "Active" FROM "TB_DONO" ORDER BY "CreatedAt" DESC;
SELECT "Id", "DonoId", "Nome", "Especie", "Raca", "Sexo", "DataNascimento", "Peso", "CreatedAt", "Active" FROM "TB_ANIMAL" ORDER BY "CreatedAt" DESC;
SELECT "Id", "AnimalId", "VeterinarioId", "ClinicaId", "DataConsulta", "HoraConsulta", "Motivo", "Diagnostico", "Status", "Tipo" FROM "TB_CONSULTA" ORDER BY "CreatedAt" DESC;
SELECT a."Id" AS "AnimalId", a."Nome" AS "NomePet", a."Especie", a."Raca", a."Peso", d."Id" AS "TutorId", d."Nome" AS "NomeTutor", d."Cpf", d."Email" FROM "TB_ANIMAL" a INNER JOIN "TB_DONO" d ON a."DonoId" = d."Id" ORDER BY a."CreatedAt" DESC;
