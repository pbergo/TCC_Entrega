USE tcc_pbergo;
CREATE TABLE tcc_pbergo.dim_orgao
(keyorgao STRING,
seq_orgao STRING, 
num_anoexercicio STRING, 
cod_orgao STRING, 
nom_orgao STRING, 
cod_municipio STRING, 
nom_municipio STRING, 
nom_uf STRING, 
sgl_uf STRING, 
num_versaoarq STRING, 
dsc_regiaoplanejamento STRING
)
STORED AS PARQUET;


