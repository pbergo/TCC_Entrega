USE tcc_pbergo;
INSERT INTO tcc_pbergo.dim_produto
SELECT DISTINCT
produto AS keyproduto,
produto
FROM tcc_pbergo_ods.ods_precos;
INSERT INTO tcc_pbergo.dim_produto VALUES ('OUTROS', 'OUTROS');
