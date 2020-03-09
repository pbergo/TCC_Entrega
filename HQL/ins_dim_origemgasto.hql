USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_origemgasto
SELECT DISTINCT
dsc_origemgasto AS keyorigemgasto,
dsc_origemgasto
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)');

