USE tcc_pbergo;
CREATE TABLE tcc_pbergo.fato_frota_classe 
(pk_frota STRING,
classe STRING,
keydata STRING,
keymunicipio STRING,
cod_municipio STRING,
keyveiculo STRING,
keytipogasto STRING,
cod_veiculo STRING,
dsc_veiculo STRING,
dsc_marca STRING,
dsc_modelo STRING,
num_anofabricacao STRING,
dsc_num_placa STRING,
dsc_numchassi STRING,
num_renavam STRING,
dsc_numserie STRING,
dsc_situacaoveiculo STRING,
num_docproprietario STRING,
vlr_gasto_unit DOUBLE
)
STORED AS PARQUET;
