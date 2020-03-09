USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_pecasservicos
SELECT DISTINCT
dsc_pecasservicos AS keypecasservicos,
dsc_pecasservicos
FROM tcc_pbergo_ods.ods_frota
WHERE dsc_tipgasto IN ('1 - ÁLCOOL (LITRO)','2 - GASOLINA (LITRO)','3 - GÁS NATURAL (M³)','4 - DIESEL (LITRO)');

