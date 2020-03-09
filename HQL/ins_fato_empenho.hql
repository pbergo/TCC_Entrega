INSERT INTO TABLE tcc_pbergo.fato_empenho
SELECT 
CONCAT_WS("/",	emp.seq_orgao,
		emp.cod_unidade, emp.cod_subunidade, emp.num_empenho, emp.dat_empenho,
		emp.num_anoexercicio, emp.cod_municipio) AS keyempenho,
emp.seq_empenho,
emp.cod_municipio,
emp.seq_orgao,
emp.cod_unidade,
emp.cod_subunidade,
emp.seq_licitacao,
emp.seq_dispensa,
emp.seq_convenio,
emp.seq_contrato,
emp.seq_termo_aditivo,
emp.num_anoexercicio,
emp.num_mesexercicio,
emp.dsc_funcao,
emp.dsc_subfuncao,
emp.dsc_naturezadespesa,
emp.dsc_programa,
emp.dsc_acao,
emp.dsc_subacao,
emp.dsc_fonterecurso,
emp.num_empenho,
emp.dat_empenho,
emp.vlr_empenhado,
emp.vlr_reforco,
emp.vlr_anulempenho,
emp.vlr_liquidacao,
emp.vlr_anulliquidacao,
emp.vlr_pagamento,
emp.vlr_anulpagamento,
emp.vlr_outrasbaixas,
emp.vlr_anuloutrasbaixas,
emp.vlr_rspprocessado,
emp.vlr_rspnaoprocessado
FROM tcc_pbergo_ods.ods_frota frota
JOIN tcc_pbergo_ods.ods_empenho emp 
ON (
emp.seq_orgao  = frota.seq_orgao AND
emp.cod_unidade = frota.cod_unidade AND
emp.cod_subunidade = frota.cod_subunidade AND
emp.num_empenho = frota.num_empenho AND
emp.dat_empenho = frota.dat_empenho AND
emp.num_anoexercicio = frota.num_anoexercicio AND
emp.cod_municipio = frota.cod_municipio
)
WHERE frota.dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)');

