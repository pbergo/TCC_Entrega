USE tcc_pbergo;
INSERT INTO tcc_pbergo.fato_precos
SELECT DISTINCT
m_s                             AS anomes,
produto                         AS keyproduto,
'MG'                            AS sgl_uf,
munic_pio                       AS nom_municipio,
n_mero_de_postos_pesquisados    AS nr_postos_pesquisados,
unidade_de_medida               AS unidade_de_medida,
pre_o_m_dio_revenda             AS preco_revenda,
desvio_padr_o_revenda           AS dev_padrao,
pre_o_m_nimo_revenda            AS preco_minimo,
pre_o_m_ximo_revenda            AS preco_maximo
FROM tcc_pbergo_ods.ods_precos
WHERE estado IN ('MINAS GERAIS');
