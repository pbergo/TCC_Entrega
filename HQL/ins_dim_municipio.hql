USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_municipio
SELECT DISTINCT
c_digo_do_munic_pio                                     AS keymunicipio,
c_digo_do_munic_pio                                     AS cod_municipio,
nome_do_munic_pio                                       AS nom_municipio,
sigla_da_unidade_da_federa__o                           AS sgl_uf,
c_digo_da_microrregi_o                                  AS cod_microrregiao,
nome_da_microrregi_o                                    AS nom_microrregiao,
c_digo_da_mesorregi_o                                   AS cod_mesorregiao,
nome_da_mesorregi_o                                     AS nom_mesorregiao
FROM  tcc_pbergo_ods.ods_munpib 
WHERE ods_munpib.sigla_da_unidade_da_federa__o='MG'
