USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_orgao
SELECT DISTINCT
seq_orgao	AS keyorgao,
seq_orgao, 
num_anoexercicio, 
cod_orgao, 
nom_orgao, 
cod_municipio, 
nom_municipio, 
nom_uf, 
sgl_uf, 
num_versaoarq, 
dsc_regiaoplanejamento
FROM tcc_pbergo_ods.ods_orgao;
