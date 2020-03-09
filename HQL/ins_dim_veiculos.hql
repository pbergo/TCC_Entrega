USE tcc_pbergo;
INSERT INTO TABLE tcc_pbergo.dim_veiculo
SELECT distinct
CONCAT_WS("/",cod_veiculo,dsc_num_placa) AS keyveiculo,
cod_veiculo,
dsc_veiculo,
dsc_marca,
dsc_modelo,
num_anofabricacao,
dsc_num_placa,
dsc_numchassi,
num_renavam,
dsc_numserie,
dsc_situacaoveiculo,
num_docproprietario
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)');

