USE tcc_pbergo;
CREATE TABLE tcc_pbergo.dim_pib 
(keymunicipio STRING,
num_anoexercicio STRING, 
sgl_uf STRING, 
cod_municipio STRING, 
nom_municipio STRING, 
cod_mesorregiao STRING, 
nom_mesorregiao STRING, 
cod_microrregiao STRING, 
nom_microrregiao STRING, 
vlr_pib DOUBLE, 
nr_habitantes DOUBLE, 
vlr_pib_percapita DOUBLE
)
STORED AS PARQUET;
