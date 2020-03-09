USE tcc_pbergo;
INSERT INTO TABLE tcc_pbergo.dim_veiculo
SELECT distinct
regexp_replace(dsc_num_placa," |-|:|_","") AS keyveiculo,
cod_veiculo,
dsc_veiculo,
dsc_marca,
dsc_modelo,
num_anofabricacao,
regexp_replace(dsc_num_placa," |-|:|_","") AS dsc_num_placa,
dsc_numchassi,
num_renavam,
dsc_numserie,
dsc_situacaoveiculo,
num_docproprietario
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)')
        AND dsc_veiculo NOT LIKE '%BALSA%' 
        AND dsc_veiculo NOT LIKE '%BARCO%'
        AND dsc_veiculo NOT LIKE '%LANCHA%'
        AND dsc_veiculo NOT LIKE '%FLUVIAL%'
        AND dsc_num_placa NOT LIKE '-1';