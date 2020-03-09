USE tcc_pbergo;
DROP TABLE dim_municipio;
CREATE TABLE tcc_pbergo.dim_municipio
(keymunicipio STRING,
cod_municipio STRING, 
nom_municipio STRING, 
sgl_uf STRING,
cod_microrregiao STRING,
nom_microrregiao STRING,
cod_mesorregiao STRING,
nom_mesorregiao STRING
)
STORED AS PARQUET;

