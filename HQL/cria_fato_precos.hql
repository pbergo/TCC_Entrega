USE tcc_pbergo;
CREATE TABLE tcc_pbergo.fato_precos 
(keyprecos STRING,
anomes STRING, 
sgl_uf STRING, 
nom_municipio STRING, 
nr_postos_pesquisados DOUBLE,
unidade_de_medida STRING,
preco_revenda DOUBLE,
desv_padrao DOUBLE,
preco_minimo DOUBLE,
perco_maximo DOUBLE
)
STORED AS PARQUET;
