USE tcc_pbergo;
INSERT INTO TABLE tcc_pbergo.fato_frota
SELECT
row_number() over() AS pk_frota,
CONCAT_WS("/",seq_orgao,cod_unidade,cod_subunidade,num_empenho,dat_empenho,num_anoexercicio,cod_municipio) AS keyempenho,
CONCAT_WS("/","01",num_mesexercicio,num_anoexercicio) AS keydata,
row_number() over() AS idfrota,
seq_orgao,
cod_unidade, 
cod_subunidade, 
num_empenho, 
dat_empenho, 
num_anoexercicio, 
num_mesexercicio, 
cod_municipio AS KeyMunicipio, 
cod_municipio, 
(dsc_num_placa) AS keyveiculo,
(dsc_tipdeslocamento) AS keytipodeslocamento,
(dsc_tipgasto) AS keytipogasto,
(dsc_origemgasto) AS keyorigemgasto,
(dsc_pecasservicos) AS keypecassericos,
qtd_inicial, 
if(qtd_utilizada<1, qtd_final - qtd_inicial, qtd_utilizada) AS qtd_utilizada, 
qtd_final, 
vlr_gasto,
vlr_gasto /  if(if(qtd_utilizada<1, if((qtd_final - qtd_inicial)=0,1, (qtd_inicial - qtd_final)), qtd_utilizada)<1,1,qtd_utilizada) AS vlr_gasto_unit
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)');
