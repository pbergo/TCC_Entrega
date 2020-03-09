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
regexp_replace(dsc_num_placa," |-|:|_","") AS keyveiculo,
(dsc_tipdeslocamento) AS keytipodeslocamento,
(dsc_tipgasto) AS keytipogasto,
(dsc_origemgasto) AS keyorigemgasto,
(dsc_pecasservicos) AS keypecassericos,
cod_veiculo,
dsc_veiculo,
dsc_marca,
dsc_modelo,
num_anofabricacao,
regexp_replace(dsc_num_placa," |-|:|_","")     AS dsc_num_placa,
dsc_numchassi,
num_renavam,
dsc_numserie,
dsc_situacaoveiculo,
num_docproprietario,
qtd_inicial, 
if(qtd_utilizada<1, qtd_final - qtd_inicial, qtd_utilizada) AS qtd_utilizada, 
qtd_final, 
vlr_gasto,
vlr_gasto /  if(if(qtd_utilizada<1, if((qtd_final - qtd_inicial)=0,1, (qtd_inicial - qtd_final)), qtd_utilizada)<1,1,qtd_utilizada) AS vlr_gasto_unit
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)')
        AND dsc_veiculo NOT LIKE '%BALSA%' 
        AND dsc_veiculo NOT LIKE '%BARCO%'
        AND dsc_veiculo NOT LIKE '%LANCHA%'
        AND dsc_veiculo NOT LIKE '%FLUVIAL%'
        AND dsc_num_placa NOT LIKE '-1';
        

