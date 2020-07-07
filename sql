create table `dev-anbima-bi-fundos.raw.fake_dim_fundos` as  (
WITH
  group_fundo_novo AS (
    SELECT
      lfn.codfundo_origem,
      ARRAY_AGG(STRUCT(
        lfn.codfundo_destino,
        lfn.datahora
        )
      ORDER BY
        lfn.datahora DESC ) [OFFSET (0)] 
        AS ultimo_destino
    FROM
      `dev-anbima-bi-fundos.raw.log_fundo_novo` lfn
    GROUP BY
      lfn.codfundo_origem ),
  group_alt_status_perdahis AS (
    SELECT
      lfns.codfundo_origem,
      ARRAY_AGG(STRUCT(
        lfns.codfundo_destino,
        lfns.datahora)
      ORDER BY
        lfns.datahora DESC ) [OFFSET(0)] AS ultimo_destino
    FROM
      `dev-anbima-bi-fundos.raw.log_alt_status_perdahist` lfns
    GROUP BY
      lfns.codfundo_origem )
SELECT
  trim(f.codfundo) AS fundo_codigo,
  trim(f.razaosoc) AS fundo_racao_socail,
  trim(f.fantasiac) AS fundo_fantasia,
  trim(f.cgc) AS fundo_cnpj,
  f.dataini AS fundo_data_inicio,
  f.datafim AS fundo_data_fim,
  CASE
    WHEN f.datafim IS NOT NULL THEN 'N'
  ELSE
    'S'
  END
  AS indicador_fundo_ativo,
  trim(f.cota_abertura) AS fundo_cota_abertura,
  f.carencia_ciclica AS fundo_carencia_ciclica,
  f.carencia_universal AS fundo_carencia_universal,
  f.datainfo AS fundo_data_informacao,
  f.periodo_divulg AS fundo_periodo_divulgacao,
  f.datahora AS fundo_data_atualizacao,
  trim(f.aberto) AS fundo_aberto,
  trim(f.divulg) AS fundo_divulgado_emprensa,
  trim(f.inv_qualif) AS fundo_investidor_qualificado,
  f.datadiv AS fundo_data_divulgacao,
  trim(f.control_ativos) AS fundo_control_ativos,
  trim(f.status_cap) AS fundo_status_cap,
  trim(f.codinfo) AS fundo_codigo_info,
  NULLIF(gfn.ultimo_destino.codfundo_destino,
    gfasp.ultimo_destino.codfundo_destino ) fundo_codigo_novo,
  CASE
    WHEN f.gestor IS NULL AND f.codtipo IN ( SELECT e.codtipo FROM `dev-anbima-bi-fundos.raw.fundos_estrut_tipoSemGestor` e) 
    THEN ('S')
    ELSE ('N')
  END AS fundo_sem_gestor,
  f.prazo_pgto_resg AS fundo_pagamento_semresgate
FROM
  `dev-anbima-bi-fundos.raw.fundos` f
LEFT JOIN
  group_fundo_novo AS gfn
ON
  (f.codfundo = gfn.codfundo_origem)
LEFT JOIN
  group_alt_status_perdahis AS gfasp
ON
  (f.codfundo = gfasp.codfundo_origem)
)