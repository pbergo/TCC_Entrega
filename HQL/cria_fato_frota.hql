USE tcc_pbergo;
CREATE TABLE tcc_pbergo.fato_frota 
(pk_frota STRING,
keyempenho STRING,
keydata STRING,
idfrota STRING,
seq_orgao STRING, 
cod_unidade STRING, 
cod_subunidade STRING, 
num_empenho STRING, 
dat_empenho STRING, 
num_anoexercicio STRING, 
num_mesexercicio STRING, 
keymunicipio STRING,
cod_municipio STRING,
keyveiculo STRING,
keytipodeslocamento STRING,
keytipogasto STRING,
keyorigemgasto STRING,
keypecasservicos STRING,
qtd_inicial DOUBLE,
qtd_utilizada DOUBLE,
qtd_final DOUBLE,
vlr_gasto DOUBLE,
vlr_gasto_unit DOUBLE
)
STORED AS PARQUET;
