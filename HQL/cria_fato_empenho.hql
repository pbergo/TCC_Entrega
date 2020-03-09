USE tcc_pbergo;
CREATE TABLE tcc_pbergo.fato_empenho
(keyempenho STRING,
seq_empenho STRING,
cod_municipio STRING,
seq_orgao STRING,
cod_unidade STRING,
cod_subunidade STRING,
seq_licitacao STRING,
seq_dispensa STRING,
seq_convenio STRING,
seq_contrato STRING,
seq_termo_aditivo STRING,
num_anoexercicio STRING,
num_mesexercicio STRING,
dsc_funcao STRING,
dsc_subfuncao STRING,
dsc_naturezadespesa STRING,
dsc_programa STRING,
dsc_acao STRING,
dsc_subacao STRING,
dsc_fonterecurso STRING,
num_empenho STRING,
dat_empenho STRING,
vlr_empenhado DOUBLE,
vlr_reforco DOUBLE,
vlr_anulempenho DOUBLE,
vlr_liquidacao DOUBLE,
vlr_anulliquidacao DOUBLE,
vlr_pagamento DOUBLE,
vlr_anulpagamento DOUBLE,
vlr_outrasbaixas DOUBLE,
vlr_anuloutrasbaixas DOUBLE,
vlr_rspprocessado DOUBLE,
vlr_rspnaoprocessado DOUBLE
)
STORED AS PARQUET;
