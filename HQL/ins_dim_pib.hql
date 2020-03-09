USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_pib
SELECT DISTINCT
c_digo_do_munic_pio                                     AS keymunicipio,
ano                                                     AS num_anoexercicio,
sigla_da_unidade_da_federa__o                           AS sgl_uf,
c_digo_do_munic_pio                                     AS cod_municipio,
nome_do_munic_pio                                       AS nom_municipio,
c_digo_da_microrregi_o                                  AS cod_microrregiao,
nome_da_microrregi_o                                    AS nom_microrregiao,
c_digo_da_mesorregi_o                                   AS cod_mesorregiao,
nome_da_mesorregi_o                                     AS nom_mesorregiao,
produto_interno_bruto__a_pre_os_correntes__r__1_000_    AS vlr_pib,
popula__o__n__de_habitantes_                            AS nr_habitantes,
produto_interno_bruto_per_capita__r__1_00_              AS vlr_pib_percapita
FROM  tcc_pbergo_ods.ods_munpib 
WHERE ods_munpib.sigla_da_unidade_da_federa__o='MG'
